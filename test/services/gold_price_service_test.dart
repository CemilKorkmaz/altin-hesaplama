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

  test('Altın API veri paketini uygulama türlerine dönüştürür', () {
    final quotes = GoldPriceService.parseAltinApiResponse({
      'stale': false,
      'data': [
        {'symbol': 'ALTIN', 'bid': 6611.16, 'ask': 6639.34},
        {'symbol': 'CEYREK_YENI', 'bid': 10800.0, 'ask': 11000.0},
        {'symbol': 'YARIM_YENI', 'bid': 21600.0, 'ask': 22000.0},
        {'symbol': 'TEK_YENI', 'bid': 43200.0, 'ask': 44000.0},
        {'symbol': 'ATA_YENI', 'bid': 47000.0, 'ask': 48000.0},
        {'symbol': 'AYAR22', 'bid': 6000.0, 'ask': 6150.0},
        {'symbol': 'AYAR14', 'bid': 3800.0, 'ask': 3950.0},
      ],
    });

    expect(quotes[GoldType.gram]!.buy, 6611.16);
    expect(quotes[GoldType.gram]!.sell, 6639.34);
    expect(quotes[GoldType.quarter]!.sell, 11000);
    expect(quotes[GoldType.half]!.sell, 22000);
    expect(quotes[GoldType.full]!.sell, 44000);
    expect(quotes[GoldType.republic]!.sell, 48000);
    expect(quotes[GoldType.bracelet22]!.sell, 6150);
    expect(quotes[GoldType.gold14]!.sell, 3950);
  });

  test('Altın API verisi eskiyse canlı fiyat olarak kabul etmez', () {
    expect(
      () => GoldPriceService.parseAltinApiResponse({'stale': true, 'data': []}),
      throwsFormatException,
    );
  });

  test('eksik veya geçersiz fiyatı olan türü atlar', () {
    final quotes = GoldPriceService.parseResponse({
      'GA': {'alis': 'hatalı', 'satis': '5.950,20'},
      'C': {'alis': '9.500,00'},
    });
    expect(quotes, isEmpty);
  });
}
