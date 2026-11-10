import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/purchase.dart';

abstract interface class PurchaseStore {
  Future<List<Purchase>> load();
  Future<void> save(List<Purchase> purchases);
}

class LocalPurchaseStore implements PurchaseStore {
  static const _key = 'gold_purchases_v1';

  @override
  Future<List<Purchase>> load() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map((item) {
            try {
              return Purchase.fromJson(Map<String, dynamic>.from(item));
            } on FormatException {
              return null;
            }
          })
          .whereType<Purchase>()
          .toList();
    } on FormatException {
      return [];
    }
  }

  @override
  Future<void> save(List<Purchase> purchases) async {
    final preferences = await SharedPreferences.getInstance();
    final raw = jsonEncode(purchases.map((item) => item.toJson()).toList());
    await preferences.setString(_key, raw);
  }
}
