import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/gold_asset.dart';

abstract interface class PriceProvider {
  String get sourceName;
  DateTime? get lastUpdatedAt;
  Future<Map<GoldType, GoldQuote>> fetchQuotes();
}

class GoldPriceService implements PriceProvider {
  GoldPriceService({http.Client? client}) : _client = client ?? http.Client();

  static const primaryEndpoint = 'https://finans.truncgil.com/v4/today.json';
  static const fallbackEndpoint = 'https://api.genelpara.com/json/?list=altin';
  static const _truncgilSymbols = <GoldType, String>{
    GoldType.gram: 'GRA',
    GoldType.quarter: 'CEYREKALTIN',
    GoldType.half: 'YARIMALTIN',
    GoldType.full: 'TAMALTIN',
    GoldType.republic: 'CUMHURIYETALTINI',
    GoldType.bracelet22: 'YIA',
    GoldType.gold18: '18AYARALTIN',
    GoldType.gold14: '14AYARALTIN',
  };

  final http.Client _client;
  String _sourceName = 'Truncgil Finans';
  DateTime? _lastUpdatedAt;

  @override
  String get sourceName => _sourceName;

  @override
  DateTime? get lastUpdatedAt => _lastUpdatedAt;

  @override
  Future<Map<GoldType, GoldQuote>> fetchQuotes() async {
    try {
      final decoded = await _getJson(primaryEndpoint);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Beklenmeyen Truncgil yanıtı.');
      }
      final quotes = parseTruncgilResponse(decoded);
      if (quotes.length < GoldType.values.length) {
        throw const FormatException('Truncgil bazı altın fiyatlarını göndermedi.');
      }
      _sourceName = 'Truncgil Finans';
      _lastUpdatedAt = parseTruncgilUpdatedAt(decoded['Update_Date']);
      return quotes;
    } on Object {
      // Ana kaynak erişilemezse anahtarsız yedek servisi dene.
    }

    final decoded = await _getJson(fallbackEndpoint);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Beklenmeyen yedek fiyat yanıtı.');
    }
    final quotes = parseGenelParaResponse(decoded);
    if (quotes.isEmpty) {
      throw const FormatException('Fiyatlar şu anda alınamıyor.');
    }
    _sourceName = 'Genel Para';
    _lastUpdatedAt = null;
    return quotes;
  }

  Future<dynamic> _getJson(String endpoint) async {
    final response = await _client
        .get(Uri.parse(endpoint), headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 12));
    if (response.statusCode != 200) {
      throw Exception('Fiyat servisi ${response.statusCode} yanıtı verdi.');
    }
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  static Map<GoldType, GoldQuote> parseTruncgilResponse(
    Map<String, dynamic> json,
  ) {
    final result = <GoldType, GoldQuote>{};
    for (final entry in _truncgilSymbols.entries) {
      final data = json[entry.value];
      if (data is! Map) continue;
      final buy = parseApiNumber(data['Buying']);
      final sell = parseApiNumber(data['Selling']);
      if (buy == null || sell == null || buy <= 0 || sell <= 0) continue;
      result[entry.key] = GoldQuote(
        type: entry.key,
        buy: buy,
        sell: sell,
        changePercent: parseApiNumber(data['Change']),
      );
    }
    return result;
  }

  static DateTime? parseTruncgilUpdatedAt(dynamic raw) {
    if (raw is! String || raw.isEmpty) return null;
    final normalized = raw.trim().replaceFirst(' ', 'T');
    final local = DateTime.tryParse('$normalized+03:00');
    return local?.toLocal();
  }

  static Map<GoldType, GoldQuote> parseGenelParaResponse(
    Map<String, dynamic> json,
  ) {
    final result = <GoldType, GoldQuote>{};
    for (final type in GoldType.values) {
      final data = json[type.apiCode];
      if (data is! Map) continue;
      final buy = parseApiNumber(data['alis']);
      final sell = parseApiNumber(data['satis']);
      if (buy == null || sell == null || buy <= 0 || sell <= 0) continue;
      result[type] = GoldQuote(
        type: type,
        buy: buy,
        sell: sell,
        changePercent: parseApiNumber(data['degisim']),
      );
    }
    return result;
  }

  static double? parseApiNumber(dynamic raw) {
    if (raw is num) return raw.toDouble();
    if (raw is! String) return null;
    var value = raw
        .trim()
        .replaceAll('%', '')
        .replaceAll('₺', '')
        .replaceAll('TL', '')
        .replaceAll(' ', '');
    if (value.isEmpty) return null;

    final comma = value.lastIndexOf(',');
    final dot = value.lastIndexOf('.');
    if (comma >= 0 && dot >= 0) {
      if (comma > dot) {
        value = value.replaceAll('.', '').replaceAll(',', '.');
      } else {
        value = value.replaceAll(',', '');
      }
    } else if (comma >= 0) {
      value = value.replaceAll('.', '').replaceAll(',', '.');
    } else if (dot >= 0 && value.indexOf('.') != dot) {
      value = value.replaceAll('.', '');
    }
    return double.tryParse(value);
  }

  void dispose() => _client.close();
}

MarketSnapshot fallbackMarket([String? message]) {
  const prices = <GoldType, List<double>>{
    GoldType.gram: [5850, 5900],
    GoldType.quarter: [9450, 9650],
    GoldType.half: [18900, 19300],
    GoldType.full: [37800, 38600],
    GoldType.republic: [39000, 39900],
    GoldType.bracelet22: [5300, 5450],
    GoldType.gold18: [4200, 4400],
    GoldType.gold14: [3250, 3450],
  };
  return MarketSnapshot(
    quotes: prices.map(
      (type, values) => MapEntry(
        type,
        GoldQuote(type: type, buy: values[0], sell: values[1]),
      ),
    ),
    isLive: false,
    source: 'Örnek veri',
    message: message ?? 'Örnek fiyatlar gösteriliyor. Yenilemeyi deneyin.',
  );
}
