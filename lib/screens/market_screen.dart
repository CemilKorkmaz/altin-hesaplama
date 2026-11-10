import 'package:flutter/cupertino.dart';

import '../app.dart';
import '../models/gold_asset.dart';
import '../state/portfolio_controller.dart';
import '../utils/formatters.dart';
import '../widgets/common.dart';

class MarketScreen extends StatelessWidget {
  const MarketScreen({super.key, required this.controller});

  final PortfolioController controller;

  @override
  Widget build(BuildContext context) {
    final market = controller.market;
    return CupertinoPageScaffold(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: const Text('Piyasalar'),
            trailing: controller.isRefreshing
                ? const CupertinoActivityIndicator()
                : CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: controller.refreshPrices,
                    child: const Icon(CupertinoIcons.refresh, size: 24),
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
                    Expanded(
                      child: Text(
                        market.updatedAt == null
                            ? 'Fiyat kaynağı: Genel Para'
                            : 'Son güncelleme ${formatTime(market.updatedAt!)}',
                        style: const TextStyle(fontSize: 13, color: CupertinoColors.systemGrey),
                      ),
                    ),
                    PriceStatus(isLive: market.isLive, compact: true),
                  ],
                ),
                const SizedBox(height: 12),
                if (!market.isLive)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppColors.goldLight, borderRadius: BorderRadius.circular(14)),
                    child: Text(market.message ?? '', style: const TextStyle(fontSize: 13, height: 1.35)),
                  ),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(child: Text('ALTIN TÜRÜ', style: TextStyle(fontSize: 11, color: CupertinoColors.systemGrey, fontWeight: FontWeight.w600))),
                      SizedBox(width: 75, child: Text('ALIŞ', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, color: CupertinoColors.systemGrey, fontWeight: FontWeight.w600))),
                      SizedBox(width: 90, child: Text('SATIŞ', textAlign: TextAlign.right, style: TextStyle(fontSize: 11, color: CupertinoColors.systemGrey, fontWeight: FontWeight.w600))),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                SurfaceCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (var index = 0; index < GoldType.values.length; index++) ...[
                        _MarketRow(type: GoldType.values[index], quote: market.quoteFor(GoldType.values[index])),
                        if (index != GoldType.values.length - 1)
                          Container(height: 1, margin: const EdgeInsets.symmetric(horizontal: 16), color: const Color(0xFFECEAE4)),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Portföy değeri, satış fiyatı üzerinden hesaplanır. Fiyatlar bilgilendirme amaçlıdır; kuyumcu ve banka fiyatları farklılık gösterebilir.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, height: 1.4, color: CupertinoColors.systemGrey),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _MarketRow extends StatelessWidget {
  const _MarketRow({required this.type, required this.quote});

  final GoldType type;
  final GoldQuote? quote;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(type.label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                if (type.unit == 'adet')
                  Text('${formatQuantity(type.gramsPerUnit)} gram', style: const TextStyle(fontSize: 11, color: CupertinoColors.systemGrey)),
              ],
            ),
          ),
          SizedBox(
            width: 75,
            child: Text(quote == null ? '—' : formatCurrency(quote!.buy), textAlign: TextAlign.right, style: const TextStyle(fontSize: 13)),
          ),
          SizedBox(
            width: 90,
            child: Text(quote == null ? '—' : formatCurrency(quote!.sell), textAlign: TextAlign.right, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.gold)),
          ),
        ],
      ),
    );
  }
}
