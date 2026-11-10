import 'gold_asset.dart';
import 'purchase.dart';

class Portfolio {
  const Portfolio(this.purchases);

  final List<Purchase> purchases;

  double get totalCost =>
      purchases.fold(0, (total, purchase) => total + purchase.totalCost);

  double quantityOf(GoldType type) => purchases
      .where((purchase) => purchase.type == type)
      .fold(0, (total, purchase) => total + purchase.quantity);

  double costOf(GoldType type) => purchases
      .where((purchase) => purchase.type == type)
      .fold(0, (total, purchase) => total + purchase.totalCost);

  double averageCostOf(GoldType type) {
    final quantity = quantityOf(type);
    return quantity == 0 ? 0 : costOf(type) / quantity;
  }

  double currentValue(MarketSnapshot market) => purchases.fold(
        0,
        (total, purchase) =>
            total +
            purchase.quantity *
                (market.quoteFor(purchase.type)?.sell ?? purchase.unitPrice),
      );

  double valueOf(GoldType type, MarketSnapshot market) =>
      quantityOf(type) *
      (market.quoteFor(type)?.sell ?? averageCostOf(type));

  double profit(MarketSnapshot market) => currentValue(market) - totalCost;

  double profitPercent(MarketSnapshot market) {
    if (totalCost == 0) return 0;
    return profit(market) / totalCost * 100;
  }

  SaleCalculation calculateSale({
    required GoldType type,
    required double quantity,
    required double saleUnitPrice,
  }) {
    final owned = quantityOf(type);
    if (quantity <= 0) {
      throw ArgumentError('Satış miktarı sıfırdan büyük olmalı.');
    }
    if (saleUnitPrice < 0) {
      throw ArgumentError('Satış fiyatı negatif olamaz.');
    }
    if (quantity > owned + 0.0000001) {
      throw ArgumentError('Satış miktarı portföydeki miktardan fazla olamaz.');
    }
    final allocatedCost = averageCostOf(type) * quantity;
    final revenue = saleUnitPrice * quantity;
    return SaleCalculation(
      type: type,
      quantity: quantity,
      saleUnitPrice: saleUnitPrice,
      revenue: revenue,
      allocatedCost: allocatedCost,
      profit: revenue - allocatedCost,
      remainingQuantity: (owned - quantity).clamp(0.0, owned).toDouble(),
    );
  }
}
