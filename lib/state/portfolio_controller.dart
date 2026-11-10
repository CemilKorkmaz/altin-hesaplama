import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/gold_asset.dart';
import '../models/portfolio.dart';
import '../models/purchase.dart';
import '../services/gold_price_service.dart';
import '../services/portfolio_store.dart';

class PortfolioController extends ChangeNotifier {
  PortfolioController({
    PriceProvider? priceProvider,
    PurchaseStore? store,
    bool autoRefresh = true,
  })  : _priceProvider = priceProvider ?? GoldPriceService(),
        _store = store ?? LocalPurchaseStore() {
    _market = fallbackMarket();
    if (autoRefresh) {
      _timer = Timer.periodic(const Duration(minutes: 1), (_) => refreshPrices());
    }
  }

  final PriceProvider _priceProvider;
  final PurchaseStore _store;
  Timer? _timer;
  List<Purchase> _purchases = [];
  late MarketSnapshot _market;
  bool _isLoading = true;
  bool _isRefreshing = false;

  List<Purchase> get purchases => List.unmodifiable(_purchases);
  Portfolio get portfolio => Portfolio(_purchases);
  MarketSnapshot get market => _market;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;

  Future<void> initialize() async {
    _purchases = await _store.load();
    _purchases.sort((a, b) => b.purchasedAt.compareTo(a.purchasedAt));
    _isLoading = false;
    notifyListeners();
    await refreshPrices();
  }

  Future<void> refreshPrices() async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    notifyListeners();
    try {
      final quotes = await _priceProvider.fetchQuotes();
      _market = MarketSnapshot(
        quotes: quotes,
        isLive: true,
        updatedAt: DateTime.now(),
        source: _priceProvider.sourceName,
      );
    } on Object {
      _market = MarketSnapshot(
        quotes: _market.quotes,
        isLive: false,
        updatedAt: _market.updatedAt,
        source: _market.source,
        message: _market.updatedAt == null
            ? 'Canlı fiyata ulaşılamadı. Örnek fiyatlar kullanılıyor.'
            : 'Bağlantı kurulamadı. Son alınan fiyatlar gösteriliyor.',
      );
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  Future<void> addPurchase({
    required GoldType type,
    required double quantity,
    required double unitPrice,
    required DateTime purchasedAt,
  }) async {
    if (quantity <= 0) throw ArgumentError('Miktar sıfırdan büyük olmalı.');
    if (unitPrice < 0) throw ArgumentError('Alış fiyatı negatif olamaz.');
    final purchase = Purchase(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      type: type,
      quantity: quantity,
      unitPrice: unitPrice,
      purchasedAt: purchasedAt,
    );
    _purchases = [..._purchases, purchase]
      ..sort((a, b) => b.purchasedAt.compareTo(a.purchasedAt));
    notifyListeners();
    await _store.save(_purchases);
  }

  Future<void> removePurchase(String id) async {
    _purchases = _purchases.where((purchase) => purchase.id != id).toList();
    notifyListeners();
    await _store.save(_purchases);
  }

  @override
  void dispose() {
    _timer?.cancel();
    if (_priceProvider is GoldPriceService) {
      _priceProvider.dispose();
    }
    super.dispose();
  }
}
