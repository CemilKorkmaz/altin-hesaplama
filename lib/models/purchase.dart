import 'gold_asset.dart';

class Purchase {
  const Purchase({
    required this.id,
    required this.type,
    required this.quantity,
    required this.unitPrice,
    required this.purchasedAt,
  });

  final String id;
  final GoldType type;
  final double quantity;
  final double unitPrice;
  final DateTime purchasedAt;

  double get totalCost => quantity * unitPrice;
  double get totalGrams => quantity * type.gramsPerUnit;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'purchasedAt': purchasedAt.toIso8601String(),
      };

  factory Purchase.fromJson(Map<String, dynamic> json) {
    final quantity = (json['quantity'] as num?)?.toDouble() ?? 0;
    final unitPrice = (json['unitPrice'] as num?)?.toDouble() ?? 0;
    if (quantity <= 0 || unitPrice < 0) {
      throw const FormatException('Geçersiz alış kaydı');
    }
    return Purchase(
      id: json['id'] as String? ?? '',
      type: GoldType.fromName(json['type'] as String? ?? ''),
      quantity: quantity,
      unitPrice: unitPrice,
      purchasedAt: DateTime.tryParse(json['purchasedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

class SaleCalculation {
  const SaleCalculation({
    required this.type,
    required this.quantity,
    required this.saleUnitPrice,
    required this.revenue,
    required this.allocatedCost,
    required this.profit,
    required this.remainingQuantity,
  });

  final GoldType type;
  final double quantity;
  final double saleUnitPrice;
  final double revenue;
  final double allocatedCost;
  final double profit;
  final double remainingQuantity;
}
