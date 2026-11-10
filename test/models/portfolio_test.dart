import 'package:altin_hesaplama/models/gold_asset.dart';
import 'package:altin_hesaplama/models/portfolio.dart';
import 'package:altin_hesaplama/models/purchase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final purchases = [
    Purchase(id: '1', type: GoldType.gram, quantity: 2, unitPrice: 1000, purchasedAt: DateTime(2026)),
    Purchase(id: '2', type: GoldType.gram, quantity: 1, unitPrice: 1200, purchasedAt: DateTime(2026, 2)),
    Purchase(id: '3', type: GoldType.quarter, quantity: 2, unitPrice: 1800, purchasedAt: DateTime(2026, 3)),
  ];
  final market = MarketSnapshot(
    isLive: true,
    quotes: {
      GoldType.gram: const GoldQuote(type: GoldType.gram, buy: 1450, sell: 1500),
      GoldType.quarter: const GoldQuote(type: GoldType.quarter, buy: 2400, sell: 2500),
    },
  );

  group('Portfolio', () {
    test('toplam maliyeti, ağırlıklı ortalamayı ve güncel değeri hesaplar', () {
      final portfolio = Portfolio(purchases);

      expect(portfolio.totalCost, 6800);
      expect(portfolio.quantityOf(GoldType.gram), 3);
      expect(portfolio.averageCostOf(GoldType.gram), closeTo(1066.6667, 0.001));
      expect(portfolio.currentValue(market), 9500);
      expect(portfolio.profit(market), 2700);
      expect(portfolio.profitPercent(market), closeTo(39.7059, 0.001));
    });

    test('fiyatı olmayan varlığı maliyetle değerler', () {
      final portfolio = Portfolio(purchases);
      final partialMarket = MarketSnapshot(
        isLive: true,
        quotes: {GoldType.gram: market.quotes[GoldType.gram]!},
      );
      expect(portfolio.currentValue(partialMarket), 8100);
    });

    test('satış simülasyonu gelir, maliyet, kâr ve kalan miktarı hesaplar', () {
      final result = Portfolio(purchases).calculateSale(
        type: GoldType.gram,
        quantity: 1.5,
        saleUnitPrice: 1600,
      );

      expect(result.revenue, 2400);
      expect(result.allocatedCost, closeTo(1600, 0.001));
      expect(result.profit, closeTo(800, 0.001));
      expect(result.remainingQuantity, 1.5);
    });

    test('satış simülasyonu portföyü değiştirmez', () {
      final portfolio = Portfolio(purchases);
      portfolio.calculateSale(type: GoldType.gram, quantity: 3, saleUnitPrice: 1600);
      expect(portfolio.quantityOf(GoldType.gram), 3);
      expect(portfolio.purchases.length, 3);
    });

    test('geçersiz satış miktarını ve negatif fiyatı reddeder', () {
      final portfolio = Portfolio(purchases);
      expect(
        () => portfolio.calculateSale(type: GoldType.gram, quantity: 4, saleUnitPrice: 1500),
        throwsArgumentError,
      );
      expect(
        () => portfolio.calculateSale(type: GoldType.gram, quantity: 0, saleUnitPrice: 1500),
        throwsArgumentError,
      );
      expect(
        () => portfolio.calculateSale(type: GoldType.gram, quantity: 1, saleUnitPrice: -1),
        throwsArgumentError,
      );
    });

    test('alış kaydı JSON olarak saklanıp geri okunur', () {
      final decoded = Purchase.fromJson(purchases.first.toJson());
      expect(decoded.id, purchases.first.id);
      expect(decoded.type, GoldType.gram);
      expect(decoded.quantity, 2);
      expect(decoded.unitPrice, 1000);
      expect(decoded.purchasedAt, purchases.first.purchasedAt);
    });
  });
}
