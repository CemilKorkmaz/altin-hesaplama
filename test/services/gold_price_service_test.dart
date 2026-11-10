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

  test('servis yanıtındaki bilinen altın türlerini dönüştürür', () {
    final quotes = GoldPriceService.parseResponse({
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

  test('eksik veya geçersiz fiyatı olan türü atlar', () {
    final quotes = GoldPriceService.parseResponse({
      'GA': {'alis': 'hatalı', 'satis': '5.950,20'},
      'C': {'alis': '9.500,00'},
    });
    expect(quotes, isEmpty);
  });
}
