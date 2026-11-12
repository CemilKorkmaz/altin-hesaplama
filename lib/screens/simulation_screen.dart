import 'package:cupertino_ui/cupertino_ui.dart';

import '../app.dart';
import '../l10n/app_localizations.dart';
import '../models/gold_asset.dart';
import '../models/purchase.dart';
import '../state/portfolio_controller.dart';
import '../utils/formatters.dart';
import '../widgets/common.dart';
import '../widgets/number_field.dart';
import 'add_purchase_screen.dart';

class SimulationScreen extends StatefulWidget {
  const SimulationScreen({super.key, required this.controller});

  final PortfolioController controller;

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen> {
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  GoldType? _type;
  SaleCalculation? _result;

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ownedTypes = GoldType.values.where((type) => widget.controller.portfolio.quantityOf(type) > 0).toList();
    if (_type != null && !ownedTypes.contains(_type)) {
      _type = null;
      _result = null;
    }
    return CupertinoPageScaffold(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          CupertinoSliverNavigationBar(largeTitle: Text(context.l10n.text('saleSimulation'))),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 110),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.softGold(context), borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(CupertinoIcons.shield_fill, color: AppColors.gold, size: 21),
                      const SizedBox(width: 10),
                      Expanded(child: Text(context.l10n.text('simulationInfo'), style: const TextStyle(fontSize: 13, height: 1.35))),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (ownedTypes.isEmpty)
                  SurfaceCard(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      children: [
                        const Icon(CupertinoIcons.arrow_2_squarepath, size: 38, color: AppColors.gold),
                        const SizedBox(height: 12),
                        Text(context.l10n.text('addFirstForSale'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Text(context.l10n.text('saleUsesAverage'), textAlign: TextAlign.center, style: const TextStyle(color: CupertinoColors.systemGrey)),
                        const SizedBox(height: 16),
                        CupertinoButton.filled(
                          onPressed: () => openAddPurchase(context, widget.controller),
                          child: Text(context.l10n.text('addPurchase')),
                        ),
                      ],
                    ),
                  )
                else ...[
                  SurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SelectField(
                          label: context.l10n.text('goldToSell'),
                          value: _type == null ? context.l10n.text('selectType') : context.l10n.typeLabel(_type!),
                          onTap: () => _selectType(ownedTypes),
                        ),
                        if (_type != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            '${context.l10n.text('available')}: ${formatQuantity(widget.controller.portfolio.quantityOf(_type!))} ${context.l10n.unit(_type!)}',
                            style: const TextStyle(fontSize: 12, color: CupertinoColors.systemGrey),
                          ),
                        ],
                        const SizedBox(height: 20),
                        NumberField(
                          label: context.l10n.text('saleQuantity'),
                          controller: _quantityController,
                          placeholder: '0',
                          suffix: _type == null ? context.l10n.text('quantity') : context.l10n.unit(_type!),
                          onChanged: (_) => setState(() => _result = null),
                        ),
                        const SizedBox(height: 20),
                        NumberField(
                          label: context.l10n.text('unitSalePrice'),
                          controller: _priceController,
                          placeholder: '0,00',
                          suffix: '₺',
                          onChanged: (_) => setState(() => _result = null),
                        ),
                        if (_type != null) ...[
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: CupertinoButton(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.square(28),
                              onPressed: _useMarketPrice,
                              child: Text(context.l10n.text('useMarketPrice'), style: const TextStyle(fontSize: 12)),
                            ),
                          ),
                        ],
                        const SizedBox(height: 18),
                        CupertinoButton.filled(
                          onPressed: _type == null ? null : _calculate,
                          child: Text(context.l10n.text('calculateSimulation')),
                        ),
                      ],
                    ),
                  ),
                  if (_result != null) ...[
                    const SizedBox(height: 20),
                    _SaleResult(result: _result!),
                  ],
                  const SizedBox(height: 20),
                  Text(
                    context.l10n.text('costDisclaimer'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, height: 1.4, color: CupertinoColors.systemGrey),
                  ),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _selectType(List<GoldType> types) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(context.l10n.text('goldToSell')),
        actions: types
            .map((type) => CupertinoActionSheetAction(
                  onPressed: () {
                    setState(() {
                      _type = type;
                      _result = null;
                      _priceController.text = widget.controller.market.quoteFor(type)?.sell.toStringAsFixed(2) ?? '';
                    });
                    Navigator.pop(context);
                  },
                  child: Text(context.l10n.typeLabel(type)),
                ))
            .toList(),
        cancelButton: CupertinoActionSheetAction(onPressed: () => Navigator.pop(context), child: Text(context.l10n.text('cancel'))),
      ),
    );
  }

  void _useMarketPrice() {
    final quote = widget.controller.market.quoteFor(_type!);
    if (quote == null) {
      showAppMessage(context, context.l10n.text('priceNotFound'), context.l10n.text('manualPriceHint'));
      return;
    }
    setState(() {
      _priceController.text = quote.sell.toStringAsFixed(2);
      _result = null;
    });
  }

  void _calculate() {
    final quantity = parseDecimal(_quantityController.text);
    final price = parseDecimal(_priceController.text);
    if (quantity == null || quantity <= 0 || price == null || price < 0) {
      showAppMessage(context, context.l10n.text('checkFields'), context.l10n.text('validSaleFields'));
      return;
    }
    try {
      final result = widget.controller.portfolio.calculateSale(
        type: _type!,
        quantity: quantity,
        saleUnitPrice: price,
      );
      setState(() => _result = result);
    } on ArgumentError {
      showAppMessage(context, context.l10n.text('cannotCalculate'), context.l10n.text('saleTooLarge'));
    }
  }
}

class _SaleResult extends StatelessWidget {
  const _SaleResult({required this.result});

  final SaleCalculation result;

  @override
  Widget build(BuildContext context) {
    final positive = result.profit >= 0;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.text('simulationResult'), style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
          const SizedBox(height: 18),
          _ResultRow(label: context.l10n.text('saleRevenue'), value: formatCurrency(result.revenue)),
          _ResultRow(label: context.l10n.text('allocatedCost'), value: formatCurrency(result.allocatedCost)),
          _ResultRow(label: context.l10n.text('remainingQuantity'), value: '${formatQuantity(result.remainingQuantity)} ${context.l10n.unit(result.type)}'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: positive ? const Color(0xFFE4F4EB) : const Color(0xFFFBE8E8),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(context.l10n.text(positive ? 'estimatedProfit' : 'estimatedLoss'), style: TextStyle(fontWeight: FontWeight.w600, color: positive ? AppColors.positive : AppColors.negative)),
                Text(formatSignedCurrency(result.profit), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: positive ? AppColors.positive : AppColors.negative)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: CupertinoColors.systemGrey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
