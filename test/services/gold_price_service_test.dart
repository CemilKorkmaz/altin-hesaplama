import 'package:altin_hesaplama/models/gold_asset.dart';
import 'package:altin_hesaplama/services/gold_price_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GoldPriceService.parseApiNumber', () {
    test('Türkçe ve İngilizce sayı biçimlerini çözer', () {
      expect(GoldPriceService.parseApiNumber('5.987,45'), 5987.45);
      expect(GoldPriceService.parseApiNumber('5,987.45'), 5987.45);
      expect(GoldPriceService.parseApiNumber('%0,42'), 0.42);
      expect(GoldPriceService.parseApiNumber(5987.45), 5987.45);
      expect(GoldPriceService.parseApiNumber('1.250.500,10'), 1250500.10);
      expect(GoldPriceService.parseApiNumber('geçersiz'), isNull);
    });
  });

  test('Truncgil v4 yanıtındaki bütün altın türlerini dönüştürür', () {
    final quotes = GoldPriceService.parseTruncgilResponse({
      'GRA': {'Buying': 6435.07, 'Selling': 6435.96, 'Change': -0.01},
      'CEYREKALTIN': {'Buying': 10482, 'Selling': 10567, 'Change': 0.2},
      'YARIMALTIN': {'Buying': 20989, 'Selling': 21127},
      'TAMALTIN': {'Buying': 41850, 'Selling': 42098},
      'CUMHURIYETALTINI': {'Buying': 42977, 'Selling': 43223},
      'YIA': {'Buying': 5857, 'Selling': 6055.79},
      '18AYARALTIN': {'Buying': 4428, 'Selling': 5170},
      '14AYARALTIN': {'Buying': 3515.54, 'Selling': 4701.34},
    });

    expect(quotes.length, GoldType.values.length);
    expect(quotes[GoldType.gram]!.buy, 6435.07);
    expect(quotes[GoldType.gram]!.sell, 6435.96);
    expect(quotes[GoldType.gram]!.changePercent, -0.01);
    expect(quotes[GoldType.quarter]!.sell, 10567);
    expect(quotes[GoldType.half]!.sell, 21127);
    expect(quotes[GoldType.full]!.sell, 42098);
    expect(quotes[GoldType.republic]!.sell, 43223);
    expect(quotes[GoldType.bracelet22]!.sell, 6055.79);
    expect(quotes[GoldType.gold18]!.sell, 5170);
    expect(quotes[GoldType.gold14]!.sell, 4701.34);
  });

  test('Truncgil klasik today.json Türkçe alanlarını da destekler', () {
    final quotes = GoldPriceService.parseTruncgilResponse({
      'gram-altin': {'Alış': '6.436,43', 'Satış': '6.437,34', 'Değişim': '%0,01'},
      'ceyrek-altin': {'Alış': '10.484,00', 'Satış': '10.569,00'},
    });

    expect(quotes[GoldType.gram]!.buy, 6436.43);
    expect(quotes[GoldType.gram]!.sell, 6437.34);
    expect(quotes[GoldType.gram]!.changePercent, 0.01);
    expect(quotes[GoldType.quarter]!.sell, 10569);
  });

  test('Truncgil kaynak güncelleme zamanını Türkiye saat dilimiyle okur', () {
    final date = GoldPriceService.parseTruncgilUpdatedAt(
      '2026-11-12 00:19:01',
    );
    expect(date, isNotNull);
    expect(date!.toUtc().toIso8601String(), '2026-11-11T21:19:01.000Z');
    expect(GoldPriceService.parseTruncgilUpdatedAt(null), isNull);
  });

  test('Genel Para yedek yanıtındaki bilinen türleri dönüştürür', () {
    final quotes = GoldPriceService.parseGenelParaResponse({
      'GA': {'alis': '5.900,10', 'satis': '5.950,20', 'degisim': '%0,35'},
      'C': {'alis': '9.500,00', 'satis': '9.650,00', 'degisim': '-0,20'},
      'bilinmeyen': {'alis': '1', 'satis': '2'},
    });

    expect(quotes.length, 2);
    expect(quotes[GoldType.gram]!.buy, 5900.10);
    expect(quotes[GoldType.gram]!.sell, 5950.20);
    expect(quotes[GoldType.gram]!.changePercent, 0.35);
    expect(quotes[GoldType.quarter]!.changePercent, -0.20);
  });

  test('eksik, sıfır veya geçersiz fiyatı olan türü atlar', () {
    final quotes = GoldPriceService.parseTruncgilResponse({
      'GRA': {'Buying': 'hatalı', 'Selling': 6435.96},
      'CEYREKALTIN': {'Buying': 0, 'Selling': 10567},
      'YARIMALTIN': {'Buying': 20989},
    });
    expect(quotes, isEmpty);
  });
}
