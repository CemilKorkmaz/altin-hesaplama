import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/gold_asset.dart';

abstract interface class PriceProvider {
  String get sourceName;
  Future<Map<GoldType, GoldQuote>> fetchQuotes();
}

class GoldPriceService implements PriceProvider {
  GoldPriceService({http.Client? client, String? apiKey})
      : _client = client ?? http.Client(),
        _apiKey = apiKey ??
            const String.fromEnvironment('ALTINAPI_KEY', defaultValue: '');

  static const altinApiEndpoints = [
    'https://haremapi.tr/api/prices',
    'https://altinapi.com/api/prices',
  ];
  static const fallbackEndpoint = 'https://api.genelpara.com/json/?list=altin';
  static const _altinApiSymbols = <GoldType, List<String>>{
    GoldType.gram: ['ALTIN'],
    GoldType.quarter: ['CEYREK_YENI'],
    GoldType.half: ['YARIM_YENI'],
    GoldType.full: ['TAM_YENI'],
    GoldType.republic: ['CUMHURIYET_YENI', 'CUMHURIYET'],
    GoldType.bracelet22: ['AYAR22'],
    GoldType.gold18: ['AYAR18'],
    GoldType.gold14: ['AYAR14'],
  };

  final http.Client _client;
  final String _apiKey;
  String _sourceName = 'Genel Para';

  @override
  String get sourceName => _sourceName;

  @override
  Future<Map<GoldType, GoldQuote>> fetchQuotes() async {
    if (_apiKey.isNotEmpty) {
      for (final endpoint in altinApiEndpoints) {
        try {
          final response = await _client
              .get(
                Uri.parse(endpoint),
                headers: {
                  'Accept': 'application/json',
                  'x-api-key': _apiKey,
                },
              )
              .timeout(const Duration(seconds: 12));
          if (response.statusCode != 200) {
            throw Exception('Fiyat API’si ${response.statusCode} yanıtı verdi.');
          }
          final quotes = parseAltinApiResponse(
            jsonDecode(utf8.decode(response.bodyBytes)),
          );
          if (quotes.isEmpty) {
            throw const FormatException('Fiyat API’si fiyatları alınamadı.');
          }
          _sourceName = endpoint.contains('haremapi.tr')
              ? 'HaremAPI'
              : 'Altın API';
          return quotes;
        } on Object {
          // Aynı anahtar biçimini kullanan diğer sağlayıcıyı dene.
        }
      }
    }

    final response = await _client
        .get(Uri.parse(fallbackEndpoint), headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 12));
    if (response.statusCode != 200) {
      throw Exception('Fiyat servisi ${response.statusCode} yanıtı verdi.');
    }
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Beklenmeyen fiyat yanıtı.');
    }
    final quotes = parseResponse(decoded);
    if (quotes.isEmpty) {
      throw const FormatException('Fiyatlar şu anda alınamıyor.');
    }
    _sourceName = 'Genel Para';
    return quotes;
  }

  static Map<GoldType, GoldQuote> parseAltinApiResponse(dynamic decoded) {
    if (decoded is Map && decoded['stale'] == true) {
      throw const FormatException('Altın API verisi güncel değil.');
    }
    final data = decoded is Map ? decoded['data'] : decoded;
    if (data is! List) {
      throw const FormatException('Beklenmeyen Altın API yanıtı.');
    }
    final prices = <String, Map>{};
    for (final item in data) {
      if (item is Map && item['symbol'] is String) {
        prices[item['symbol'] as String] = item;
      }
    }

    final result = <GoldType, GoldQuote>{};
    for (final entry in _altinApiSymbols.entries) {
      for (final symbol in entry.value) {
        final item = prices[symbol];
        if (item == null) continue;
        final buy = parseApiNumber(item['bid']);
        final sell = parseApiNumber(item['ask']);
        if (buy == null || sell == null || buy < 0 || sell < 0) continue;
        result[entry.key] = GoldQuote(
          type: entry.key,
          buy: buy,
          sell: sell,
        );
        break;
      }
    }
    return result;
  }

  static Map<GoldType, GoldQuote> parseResponse(Map<String, dynamic> json) {
    final result = <GoldType, GoldQuote>{};
    for (final type in GoldType.values) {
      final data = json[type.apiCode];
      if (data is! Map) continue;
      final buy = parseApiNumber(data['alis']);
      final sell = parseApiNumber(data['satis']);
      if (buy == null || sell == null || buy < 0 || sell < 0) continue;
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
