import 'package:altin_hesaplama/app.dart';
import 'package:altin_hesaplama/models/gold_asset.dart';
import 'package:altin_hesaplama/models/purchase.dart';
import 'package:altin_hesaplama/services/gold_price_service.dart';
import 'package:altin_hesaplama/services/portfolio_store.dart';
import 'package:altin_hesaplama/state/portfolio_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

class TestStore implements PurchaseStore {
  final List<Purchase> purchases = [];
  @override
  Future<List<Purchase>> load() async => purchases;
  @override
  Future<void> save(List<Purchase> value) async {
    purchases
      ..clear()
      ..addAll(value);
  }
}

class TestPrices implements PriceProvider {
  @override
  Future<Map<GoldType, GoldQuote>> fetchQuotes() async => {
        GoldType.gram: const GoldQuote(type: GoldType.gram, buy: 1450, sell: 1500),
      };
}

void main() {
  testWidgets('alış ekleme ve satış simülasyonu uçtan uca çalışır', (tester) async {
    final controller = PortfolioController(
      store: TestStore(),
      priceProvider: TestPrices(),
      autoRefresh: false,
    );
    await tester.pumpWidget(GoldPortfolioApp(controller: controller));
    await tester.pumpAndSettle();

    expect(find.text('İlk altın alışını ekle'), findsOneWidget);
    await tester.tap(find.text('Alış Ekle'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(CupertinoTextField, '0').first, '2');
    await tester.enterText(find.widgetWithText(CupertinoTextField, '0,00'), '1000');
    await tester.tap(find.text('Portföye Ekle'));
    await tester.pumpAndSettle();

    expect(find.text('2 gram Gram Altın'), findsOneWidget);
    expect(find.textContaining('3.000'), findsWidgets);
    expect(find.textContaining('+₺1.000'), findsOneWidget);

    await tester.tap(find.text('Satış Simülasyonu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tür seç'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gram Altın').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(CupertinoTextField, '0'), '1');
    await tester.tap(find.text('Simülasyonu Hesapla'));
    await tester.pumpAndSettle();

    expect(find.text('Simülasyon Sonucu'), findsOneWidget);
    expect(find.text('Tahmini kâr'), findsOneWidget);
    expect(find.textContaining('+₺500'), findsOneWidget);
    expect(controller.purchases.length, 1, reason: 'Simülasyon alış kaydını değiştirmemeli');
    controller.dispose();
  });

  testWidgets('piyasa sekmesi canlı alış ve satış fiyatlarını gösterir', (tester) async {
    final controller = PortfolioController(
      store: TestStore(),
      priceProvider: TestPrices(),
      autoRefresh: false,
    );
    await tester.pumpWidget(GoldPortfolioApp(controller: controller));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Piyasalar'));
    await tester.pumpAndSettle();

    expect(find.text('Canlı piyasa'), findsOneWidget);
    expect(find.text('₺1.450,00'), findsOneWidget);
    expect(find.text('₺1.500,00'), findsOneWidget);
    controller.dispose();
  });
}
