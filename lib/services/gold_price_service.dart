import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/gold_asset.dart';

abstract interface class PriceProvider {
  Future<Map<GoldType, GoldQuote>> fetchQuotes();
}

class GoldPriceService implements PriceProvider {
  GoldPriceService({http.Client? client}) : _client = client ?? http.Client();

  static const endpoint = 'https://api.genelpara.com/json/?list=altin';
  final http.Client _client;

  @override
  Future<Map<GoldType, GoldQuote>> fetchQuotes() async {
    final response = await _client
        .get(Uri.parse(endpoint), headers: {'Accept': 'application/json'})
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
    return quotes;
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
    message: message ?? 'Örnek fiyatlar gösteriliyor. Yenilemeyi deneyin.',
  );
}
