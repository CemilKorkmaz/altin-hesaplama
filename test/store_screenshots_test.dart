// Play Store ekran görüntülerini gerçek uygulama widget'larından üretir.
//
// Çalıştırma:
//   GENERATE_STORE_SCREENSHOTS=1 flutter test test/store_screenshots_test.dart
// Çıktı: store/screenshots/*.png — 1080x1920 (tam 9:16), PNG, 8 MB altı.
//
// Normal `flutter test` çalıştırmalarında bu dosya atlanır; yalnızca
// `store-screenshots` CI işinde üretim yapılır.

import 'dart:io';

import 'package:altin_hesaplama/app.dart';
import 'package:altin_hesaplama/models/gold_asset.dart';
import 'package:altin_hesaplama/models/purchase.dart';
import 'package:altin_hesaplama/services/gold_price_service.dart';
import 'package:altin_hesaplama/services/portfolio_store.dart';
import 'package:altin_hesaplama/state/portfolio_controller.dart';
import 'package:altin_hesaplama/state/settings_controller.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _captureKey = ValueKey<String>('store-capture');

/// 1080x1920 = tam 9:16. Play aralığı 320–3840 px.
const _physicalSize = Size(1080, 1920);

const _outputDirectory = 'store/screenshots';

final bool _enabled =
    Platform.environment['GENERATE_STORE_SCREENSHOTS'] == '1';

Map<GoldType, GoldQuote> _demoQuotes() => {
      GoldType.gram: const GoldQuote(
        type: GoldType.gram,
        buy: 4185,
        sell: 4196,
        changePercent: 0.82,
      ),
      GoldType.quarter: const GoldQuote(
        type: GoldType.quarter,
        buy: 6860,
        sell: 6905,
        changePercent: 0.74,
      ),
      GoldType.half: const GoldQuote(
        type: GoldType.half,
        buy: 13700,
        sell: 13790,
        changePercent: 0.71,
      ),
      GoldType.full: const GoldQuote(
        type: GoldType.full,
        buy: 27390,
        sell: 27560,
        changePercent: 0.70,
      ),
      GoldType.republic: const GoldQuote(
        type: GoldType.republic,
        buy: 27500,
        sell: 27690,
        changePercent: 0.68,
      ),
      GoldType.bracelet22: const GoldQuote(
        type: GoldType.bracelet22,
        buy: 3850,
        sell: 3900,
        changePercent: 0.79,
      ),
      GoldType.gold18: const GoldQuote(
        type: GoldType.gold18,
        buy: 3150,
        sell: 3230,
        changePercent: 0.64,
      ),
      GoldType.gold14: const GoldQuote(
        type: GoldType.gold14,
        buy: 2450,
        sell: 2540,
        changePercent: 0.61,
      ),
    };

List<Purchase> _demoPurchases() => [
      Purchase(
        id: '1',
        type: GoldType.bracelet22,
        quantity: 15,
        unitPrice: 2900,
        purchasedAt: DateTime(2026, 3, 18),
      ),
      Purchase(
        id: '2',
        type: GoldType.gram,
        quantity: 10,
        unitPrice: 3250,
        purchasedAt: DateTime(2026, 5, 6),
      ),
      Purchase(
        id: '3',
        type: GoldType.full,
        quantity: 2,
        unitPrice: 24800,
        purchasedAt: DateTime(2026, 8, 21),
      ),
      Purchase(
        id: '4',
        type: GoldType.quarter,
        quantity: 4,
        unitPrice: 6150,
        purchasedAt: DateTime(2026, 9, 14),
      ),
    ];

class _DemoPriceProvider implements PriceProvider {
  @override
  String get sourceName => 'Truncgil Finans';

  @override
  DateTime? get lastUpdatedAt => DateTime(2026, 11, 12, 10, 42);

  @override
  Future<Map<GoldType, GoldQuote>> fetchQuotes() async => _demoQuotes();
}

class _DemoStore implements PurchaseStore {
  _DemoStore(this._items);

  List<Purchase> _items;

  @override
  Future<List<Purchase>> load() async => _items;

  @override
  Future<void> save(List<Purchase> purchases) async => _items = purchases;
}

/// Test ortamının varsayılan yazı tipi her glifi kutu olarak çizdiği için
/// gerçek yazı tiplerini Flutter SDK ve pub cache içinden yükler.
///
/// Cupertino bileşenleri metni `.SF Pro Text`, `.SF Pro Display`,
/// `CupertinoSystemText` ve `CupertinoSystemDisplay` aile adlarıyla ister;
/// hepsine Roboto bağlanıyor. Simgeler için paketin kendi ikon fontu kullanılır.
const _textFamilies = <String>[
  '.SF Pro Text',
  '.SF Pro Display',
  'CupertinoSystemText',
  'CupertinoSystemDisplay',
  'Roboto',
  'Segoe UI',
];

Future<void> _loadRealFonts() async {
  final materialFonts = _materialFontsDirectory();
  if (materialFonts != null) {
    final roboto = <String>[
      'Roboto-Light.ttf',
      'Roboto-Regular.ttf',
      'Roboto-Medium.ttf',
      'Roboto-Bold.ttf',
      'Roboto-Black.ttf',
    ]
        .map((name) => File('${materialFonts.path}/$name'))
        .where((file) => file.existsSync())
        .toList();

    if (roboto.isNotEmpty) {
      for (final family in _textFamilies) {
        final loader = FontLoader(family);
        for (final file in roboto) {
          loader.addFont(_bytes(file));
        }
        await loader.load();
      }
    }

    final materialIcons = File('${materialFonts.path}/MaterialIcons-Regular.otf');
    if (materialIcons.existsSync()) {
      final loader = FontLoader('MaterialIcons')..addFont(_bytes(materialIcons));
      await loader.load();
    }
  }

  final icons = _iconFont();
  if (icons != null) {
    for (final family in const [
      'CupertinoIcons',
      'packages/cupertino_ui/CupertinoIcons',
      'packages/cupertino_icons/CupertinoIcons',
    ]) {
      final loader = FontLoader(family)..addFont(_bytes(icons));
      await loader.load();
    }
    debugPrint('ikon fontu: ${icons.path}');
  } else {
    debugPrint('UYARI: ikon fontu bulunamadı');
  }
}

Future<ByteData> _bytes(File file) async =>
    ByteData.view((await file.readAsBytes()).buffer);

Directory? _materialFontsDirectory() {
  final candidates = <Directory>[];
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot != null && flutterRoot.isNotEmpty) {
    candidates.add(Directory('$flutterRoot/bin/cache/artifacts/material_fonts'));
  }

  var dir = File(Platform.resolvedExecutable).parent;
  for (var depth = 0; depth < 9; depth++) {
    candidates.add(Directory('${dir.path}/bin/cache/artifacts/material_fonts'));
    candidates.add(Directory('${dir.path}/artifacts/material_fonts'));
    if (dir.parent.path == dir.path) break;
    dir = dir.parent;
  }

  for (final candidate in candidates) {
    if (candidate.existsSync()) return candidate;
  }
  return null;
}

/// pub cache içinden Cupertino ikon fontunu bulur.
File? _iconFont() {
  final home = Platform.environment['HOME'];
  if (home == null) return null;
  final cache = Directory('$home/.pub-cache/hosted');
  if (!cache.existsSync()) return null;

  final candidates = <File>[];
  for (final host in cache.listSync().whereType<Directory>()) {
    for (final package in host.listSync().whereType<Directory>()) {
      final name = package.path.split(Platform.pathSeparator).last;
      if (!name.startsWith('cupertino_')) continue;
      for (final file in package.listSync(recursive: true).whereType<File>()) {
        final lower = file.path.toLowerCase();
        if (!lower.endsWith('.ttf') && !lower.endsWith('.otf')) continue;
        if (lower.contains('cupertino')) candidates.add(file);
      }
    }
  }
  if (candidates.isEmpty) return null;
  candidates.sort((a, b) => a.path.compareTo(b.path));
  return candidates.first;
}

Future<void> _settle(WidgetTester tester, {int frames = 14}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 80));
  }
}

/// Telefon düzeni 432x768 mantıksal pikselde kurulur ve 2.5x ölçeklenerek
/// 1080x1920'ye oturtulur. Golden yakalama 1:1 çalıştığı için ölçekleme
/// `FittedBox` ile yapılıyor; metin ve vektörler keskin kalır.
const _logicalPhone = Size(432, 768);

Future<void> _pumpApp(WidgetTester tester, SettingsController settings) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = _physicalSize;
  addTearDown(tester.view.reset);
  // Kök yüzeyi tam hedef boyuta sabitle; aksi hâlde tuval alt öğeye küçülür.
  await tester.binding.setSurfaceSize(_physicalSize);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final controller = PortfolioController(
    priceProvider: _DemoPriceProvider(),
    store: _DemoStore(_demoPurchases()),
    autoRefresh: false,
  );

  await tester.pumpWidget(
    RepaintBoundary(
      key: _captureKey,
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: _logicalPhone.width,
          height: _logicalPhone.height,
          child: MediaQuery(
            data: const MediaQueryData(
              size: _logicalPhone,
              devicePixelRatio: 1,
              padding: EdgeInsets.only(top: 24),
            ),
            child: GoldPortfolioApp(controller: controller, settings: settings),
          ),
        ),
      ),
    ),
  );
  await _settle(tester);
}

/// Görüntüyü golden dosyası olarak yazar.
///
/// `RenderRepaintBoundary.toImage` sahte saat altında asılı kaldığı için
/// Flutter'ın kendi golden mekanizması kullanılıyor; `--update-goldens` ile
/// dosyalar doğrudan `store/screenshots` altına yazılır.
Future<void> _capture(WidgetTester tester, String fileName) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(find.byKey(_captureKey));
  debugPrint('yakalanıyor: $fileName (tuval: ${boundary.size})');
  await expectLater(
    find.byKey(_captureKey),
    matchesGoldenFile('../$_outputDirectory/$fileName'),
  );
  debugPrint('yazıldı: $_outputDirectory/$fileName');
}

Future<SettingsController> _newSettings() async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final settings = SettingsController();
  await settings.initialize();
  return settings;
}

/// Sonuç kartını görünür alana getirir.
Future<void> _revealResult(WidgetTester tester, String title) async {
  final scrollable = find.byType(Scrollable).first;
  await tester.scrollUntilVisible(find.text(title), 220, scrollable: scrollable);
  await _settle(tester);
  // Kartın üst kısmı ekranın biraz üstünde kalsın; altındaki satırlar görünsün.
  await tester.drag(scrollable, const Offset(0, 140));
  await _settle(tester);
}

void main() {
  setUpAll(() async {
    if (!_enabled) return;
    await _loadRealFonts();
    await Future.wait([
      initializeDateFormatting('tr_TR'),
      initializeDateFormatting('en_US'),
    ]);
  });

  group('Play mağaza ekran görüntüleri', () {
    testWidgets('Türkçe', timeout: const Timeout(Duration(minutes: 4)), (tester) async {
      final settings = await _newSettings();
      await _pumpApp(tester, settings);
      debugPrint('adım: tr özet');
      await _capture(tester, 'tr-01-portfoy.png');

      debugPrint('adım: tr piyasalar');
      await tester.tap(find.text('Piyasalar').first);
      await _settle(tester);
      await _capture(tester, 'tr-02-piyasalar.png');

      debugPrint('adım: tr simülasyon');
      await tester.tap(find.text('Satış Simülasyonu').first);
      await _settle(tester);
      await tester.tap(find.text('Tür seç').first);
      await _settle(tester);
      await tester.tap(find.text('Çeyrek Altın').first);
      await _settle(tester);

      await tester.enterText(find.byType(CupertinoTextField).first, '2');
      await _settle(tester);
      await tester.tap(find.text('Simülasyonu Hesapla').first);
      await _settle(tester);

      await _revealResult(tester, 'Simülasyon Sonucu');
      await _capture(tester, 'tr-03-satis-simulasyonu.png');

      await tester.tap(find.text('Özet').first);
      await _settle(tester);
      await settings.toggleDarkMode();
      await _settle(tester);
      await _capture(tester, 'tr-04-gece-modu.png');
      debugPrint('tr tamam');
    });

    testWidgets('İngilizce', timeout: const Timeout(Duration(minutes: 4)), (tester) async {
      final settings = await _newSettings();
      await _pumpApp(tester, settings);
      await settings.setLocale(const Locale('en'));
      await _settle(tester);
      debugPrint('adım: en özet');
      await _capture(tester, 'en-01-portfolio.png');

      debugPrint('adım: en piyasalar');
      await tester.tap(find.text('Markets').first);
      await _settle(tester);
      await _capture(tester, 'en-02-markets.png');

      debugPrint('adım: en simülasyon');
      await tester.tap(find.text('Sale Simulator').first);
      await _settle(tester);
      await tester.tap(find.text('Select type').first);
      await _settle(tester);
      await tester.tap(find.text('Quarter Gold').first);
      await _settle(tester);

      await tester.enterText(find.byType(CupertinoTextField).first, '2');
      await _settle(tester);
      await tester.tap(find.text('Calculate Simulation').first);
      await _settle(tester);

      await _revealResult(tester, 'Simulation Result');
      await _capture(tester, 'en-03-sale-simulation.png');

      await tester.tap(find.text('Overview').first);
      await _settle(tester);
      await settings.toggleDarkMode();
      await _settle(tester);
      await _capture(tester, 'en-04-dark-mode.png');
      debugPrint('en tamam');
    });
  }, skip: !_enabled);
}
