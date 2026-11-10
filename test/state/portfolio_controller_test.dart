import 'package:altin_hesaplama/models/gold_asset.dart';
import 'package:altin_hesaplama/models/purchase.dart';
import 'package:altin_hesaplama/services/gold_price_service.dart';
import 'package:altin_hesaplama/services/portfolio_store.dart';
import 'package:altin_hesaplama/state/portfolio_controller.dart';
import 'package:flutter_test/flutter_test.dart';

class MemoryStore implements PurchaseStore {
  MemoryStore([List<Purchase>? initial]) : purchases = initial ?? [];
  List<Purchase> purchases;

  @override
  Future<List<Purchase>> load() async => List.of(purchases);

  @override
  Future<void> save(List<Purchase> value) async => purchases = List.of(value);
}

class FakePrices implements PriceProvider {
  FakePrices({this.shouldFail = false});
  bool shouldFail;

  @override
  String get sourceName => 'Test';

  @override
  Future<Map<GoldType, GoldQuote>> fetchQuotes() async {
    if (shouldFail) throw Exception('Çevrimdışı');
    return {GoldType.gram: const GoldQuote(type: GoldType.gram, buy: 1450, sell: 1500)};
  }
}

void main() {
  test('kayıtları yükler, ekler, saklar ve siler', () async {
    final store = MemoryStore();
    final controller = PortfolioController(
      store: store,
      priceProvider: FakePrices(),
      autoRefresh: false,
    );
    await controller.initialize();
    await controller.addPurchase(
      type: GoldType.gram,
      quantity: 2,
      unitPrice: 1000,
      purchasedAt: DateTime(2026),
    );

    expect(controller.purchases.length, 1);
    expect(store.purchases.length, 1);
    expect(controller.market.isLive, isTrue);
    expect(controller.portfolio.currentValue(controller.market), 3000);

    await controller.removePurchase(controller.purchases.single.id);
    expect(controller.purchases, isEmpty);
    expect(store.purchases, isEmpty);
    controller.dispose();
  });

  test('fiyat hatasında örnek veriyi canlı olarak işaretlemez', () async {
    final controller = PortfolioController(
      store: MemoryStore(),
      priceProvider: FakePrices(shouldFail: true),
      autoRefresh: false,
    );
    await controller.initialize();

    expect(controller.market.isLive, isFalse);
    expect(controller.market.message, contains('Örnek'));
    controller.dispose();
  });
}
