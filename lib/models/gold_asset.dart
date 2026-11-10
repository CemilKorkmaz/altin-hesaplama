enum GoldType {
  gram('GA', 'Gram Altın', 'gram', 1),
  quarter('C', 'Çeyrek Altın', 'adet', 1.635),
  half('Y', 'Yarım Altın', 'adet', 3.27),
  full('T', 'Tam Altın', 'adet', 6.54),
  republic('CMR', 'Cumhuriyet Altını', 'adet', 7.20),
  bracelet22('22', '22 Ayar Bilezik', 'gram', 1),
  gold18('18', '18 Ayar Altın', 'gram', 1),
  gold14('14', '14 Ayar Altın', 'gram', 1);

  const GoldType(this.apiCode, this.label, this.unit, this.gramsPerUnit);

  final String apiCode;
  final String label;
  final String unit;
  final double gramsPerUnit;

  static GoldType fromName(String name) => GoldType.values.firstWhere(
        (type) => type.name == name,
        orElse: () => GoldType.gram,
      );
}

class GoldQuote {
  const GoldQuote({
    required this.type,
    required this.buy,
    required this.sell,
    this.changePercent,
  });

  final GoldType type;
  final double buy;
  final double sell;
  final double? changePercent;
}

class MarketSnapshot {
  const MarketSnapshot({
    required this.quotes,
    required this.isLive,
    this.updatedAt,
    this.message,
  });

  final Map<GoldType, GoldQuote> quotes;
  final bool isLive;
  final DateTime? updatedAt;
  final String? message;

  GoldQuote? quoteFor(GoldType type) => quotes[type];
}
