import 'package:cupertino_ui/cupertino_ui.dart';

import '../app.dart';
import '../models/gold_asset.dart';
import '../state/portfolio_controller.dart';
import '../utils/formatters.dart';
import '../widgets/common.dart';
import '../widgets/number_field.dart';

Future<void> openAddPurchase(BuildContext context, PortfolioController controller) {
  return Navigator.of(context).push(
    CupertinoPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => AddPurchaseScreen(controller: controller),
    ),
  );
}

class AddPurchaseScreen extends StatefulWidget {
  const AddPurchaseScreen({super.key, required this.controller});

  final PortfolioController controller;

  @override
  State<AddPurchaseScreen> createState() => _AddPurchaseScreenState();
}

class _AddPurchaseScreenState extends State<AddPurchaseScreen> {
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  GoldType _type = GoldType.gram;
  DateTime _date = DateTime.now();
  bool _isSaving = false;

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Yeni Alış'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: const Text('Vazgeç'),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(18, 22, 18, 30 + MediaQuery.viewInsetsOf(context).bottom),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.goldLight, borderRadius: BorderRadius.circular(16)),
              child: const Row(
                children: [
                  Icon(CupertinoIcons.info_circle_fill, color: AppColors.gold),
                  SizedBox(width: 10),
                  Expanded(child: Text('Aldığın ürünün birim fiyatını gir. Kayıtlar yalnızca bu cihazda saklanır.', style: TextStyle(fontSize: 13, height: 1.35))),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SelectField(label: 'Altın türü', value: _type.label, onTap: _selectType),
            const SizedBox(height: 20),
            NumberField(
              label: 'Miktar',
              controller: _quantityController,
              placeholder: '0',
              suffix: _type.unit,
            ),
            const SizedBox(height: 20),
            NumberField(
              label: 'Birim alış fiyatı',
              controller: _priceController,
              placeholder: '0,00',
              suffix: '₺ / ${_type.unit}',
            ),
            const SizedBox(height: 20),
            SelectField(label: 'Alış tarihi', value: formatDate(_date), onTap: _selectDate),
            const SizedBox(height: 28),
            CupertinoButton.filled(
              onPressed: _isSaving ? null : _save,
              child: _isSaving ? const CupertinoActivityIndicator(color: CupertinoColors.white) : const Text('Portföye Ekle'),
            ),
          ],
        ),
      ),
    );
  }

  void _selectType() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Altın türünü seç'),
        actions: GoldType.values
            .map((type) => CupertinoActionSheetAction(
                  onPressed: () {
                    setState(() => _type = type);
                    Navigator.pop(context);
                  },
                  child: Text(type.label),
                ))
            .toList(),
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Vazgeç'),
        ),
      ),
    );
  }

  void _selectDate() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => Container(
        height: 300,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: CupertinoButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Bitti'),
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: _date,
                  maximumDate: DateTime.now(),
                  onDateTimeChanged: (date) => _date = date,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final quantity = parseDecimal(_quantityController.text);
    final price = parseDecimal(_priceController.text);
    if (quantity == null || quantity <= 0) {
      return showAppMessage(context, 'Miktarı kontrol et', 'Sıfırdan büyük geçerli bir miktar gir.');
    }
    if (price == null || price < 0) {
      return showAppMessage(context, 'Fiyatı kontrol et', 'Geçerli bir birim alış fiyatı gir.');
    }
    setState(() => _isSaving = true);
    try {
      await widget.controller.addPurchase(
        type: _type,
        quantity: quantity,
        unitPrice: price,
        purchasedAt: _date,
      );
      if (mounted) Navigator.pop(context);
    } on Object {
      if (mounted) {
        setState(() => _isSaving = false);
        showAppMessage(context, 'Kaydedilemedi', 'Kayıt saklanırken bir sorun oluştu. Tekrar dene.');
      }
    }
  }
}
