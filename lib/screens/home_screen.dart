import 'package:flutter/cupertino.dart';

import '../app.dart';
import '../models/gold_asset.dart';
import '../models/purchase.dart';
import '../state/portfolio_controller.dart';
import '../utils/formatters.dart';
import '../widgets/common.dart';
import 'add_purchase_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.controller});

  final PortfolioController controller;

  @override
  Widget build(BuildContext context) {
    final portfolio = controller.portfolio;
    final profit = portfolio.profit(controller.market);
    return CupertinoPageScaffold(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: const Text('Altın Defterim'),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => openAddPurchase(context, controller),
              child: const Icon(CupertinoIcons.add_circled_solid, size: 28),
            ),
          ),
          CupertinoSliverRefreshControl(onRefresh: controller.refreshPrices),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 110),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      controller.market.updatedAt == null
                          ? 'Portföy özeti'
                          : 'Güncelleme ${formatTime(controller.market.updatedAt!)}',
                      style: const TextStyle(fontSize: 13, color: CupertinoColors.systemGrey),
                    ),
                    PriceStatus(isLive: controller.market.isLive, compact: true),
                  ],
                ),
                const SizedBox(height: 12),
                _PortfolioHero(
                  value: portfolio.currentValue(controller.market),
                  cost: portfolio.totalCost,
                  profit: profit,
                  profitPercent: portfolio.profitPercent(controller.market),
                ),
                if (!controller.market.isLive) ...[
                  const SizedBox(height: 12),
                  Text(
                    controller.market.message ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: CupertinoColors.systemGrey),
                  ),
                ],
                const SizedBox(height: 26),
                const SectionHeading('Varlıklarım'),
                const SizedBox(height: 12),
                if (portfolio.purchases.isEmpty)
                  _EmptyPortfolio(onAdd: () => openAddPurchase(context, controller))
                else
                  ...GoldType.values
                      .where((type) => portfolio.quantityOf(type) > 0)
                      .map((type) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _HoldingCard(
                              type: type,
                              quantity: portfolio.quantityOf(type),
                              value: portfolio.valueOf(type, controller.market),
                              averageCost: portfolio.averageCostOf(type),
                              quote: controller.market.quoteFor(type),
                            ),
                          )),
                if (portfolio.purchases.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  const SectionHeading('Alış Geçmişi'),
                  const SizedBox(height: 12),
                  ...portfolio.purchases.map((purchase) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _PurchaseRow(
                          purchase: purchase,
                          onDelete: () => _confirmDelete(context, purchase),
                        ),
                      )),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Purchase purchase) async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Alış kaydı silinsin mi?'),
        content: Text('${purchase.type.label} kaydı portföyden kaldırılacak.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Vazgeç'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (confirmed == true) await controller.removePurchase(purchase.id);
  }
}

class _PortfolioHero extends StatelessWidget {
  const _PortfolioHero({
    required this.value,
    required this.cost,
    required this.profit,
    required this.profitPercent,
  });

  final double value;
  final double cost;
  final double profit;
  final double profitPercent;

  @override
  Widget build(BuildContext context) {
    final positive = profit >= 0;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF27241D), Color(0xFF403923)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(CupertinoIcons.sparkles, color: Color(0xFFE9C979), size: 17),
              SizedBox(width: 7),
              Text('TOPLAM DEĞER', style: TextStyle(color: Color(0xFFD8D2C3), fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            formatCurrency(value),
            style: const TextStyle(color: CupertinoColors.white, fontSize: 34, fontWeight: FontWeight.w700, letterSpacing: -1),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(color: const Color(0x1FFFFFFF), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Icon(positive ? CupertinoIcons.arrow_up_right : CupertinoIcons.arrow_down_right, color: positive ? const Color(0xFF82DDB1) : const Color(0xFFFF9999), size: 20),
                const SizedBox(width: 7),
                Text(
                  '${formatSignedCurrency(profit)}  ·  ${formatPercent(profitPercent)}',
                  style: TextStyle(color: positive ? const Color(0xFF82DDB1) : const Color(0xFFFF9999), fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text('Toplam maliyet  ${formatCurrency(cost)}', style: const TextStyle(color: Color(0xFFBEB8AA), fontSize: 13)),
        ],
      ),
    );
  }
}

class _HoldingCard extends StatelessWidget {
  const _HoldingCard({
    required this.type,
    required this.quantity,
    required this.value,
    required this.averageCost,
    required this.quote,
  });

  final GoldType type;
  final double quantity;
  final double value;
  final double averageCost;
  final GoldQuote? quote;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(color: AppColors.goldLight, shape: BoxShape.circle),
            child: const Icon(CupertinoIcons.circle_fill, color: AppColors.gold, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(type.label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 4),
                Text('${formatQuantity(quantity)} ${type.unit} · Ort. ${formatCurrency(averageCost)}', style: const TextStyle(fontSize: 12, color: CupertinoColors.systemGrey)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(formatCurrency(value), style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(quote == null ? 'Fiyat yok' : 'Satış ${formatCurrency(quote!.sell)}', style: const TextStyle(fontSize: 11, color: CupertinoColors.systemGrey)),
            ],
          ),
        ],
      ),
    );
  }
}

class _PurchaseRow extends StatelessWidget {
  const _PurchaseRow({required this.purchase, required this.onDelete});

  final Purchase purchase;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${formatQuantity(purchase.quantity)} ${purchase.type.unit} ${purchase.type.label}', style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('${formatDate(purchase.purchasedAt)} · ${formatCurrency(purchase.unitPrice)} / ${purchase.type.unit}', style: const TextStyle(fontSize: 12, color: CupertinoColors.systemGrey)),
              ],
            ),
          ),
          Text(formatCurrency(purchase.totalCost), style: const TextStyle(fontWeight: FontWeight.w600)),
          CupertinoButton(
            padding: const EdgeInsets.only(left: 8),
            onPressed: onDelete,
            child: const Icon(CupertinoIcons.trash, size: 18, color: CupertinoColors.systemGrey),
          ),
        ],
      ),
    );
  }
}

class _EmptyPortfolio extends StatelessWidget {
  const _EmptyPortfolio({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      child: Column(
        children: [
          const Icon(CupertinoIcons.plus_square_on_square, size: 38, color: AppColors.gold),
          const SizedBox(height: 12),
          const Text('İlk altın alışını ekle', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 7),
          const Text('Türü, miktarı ve alış fiyatını gir; piyasa değerini ve kâr/zararını burada takip et.', textAlign: TextAlign.center, style: TextStyle(color: CupertinoColors.systemGrey, height: 1.35)),
          const SizedBox(height: 18),
          CupertinoButton.filled(onPressed: onAdd, child: const Text('Alış Ekle')),
        ],
      ),
    );
  }
}
