import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;

import 'l10n/app_localizations.dart';
import 'screens/home_screen.dart';
import 'screens/market_screen.dart';
import 'screens/simulation_screen.dart';
import 'state/portfolio_controller.dart';
import 'state/settings_controller.dart';
import 'utils/formatters.dart';

class AppColors {
  static const gold = Color(0xFFB88925);
  static const goldLight = Color(0xFFF4E9CF);
  static const ink = Color(0xFF1D1C19);
  static const background = Color(0xFFF7F6F2);
  static const positive = Color(0xFF23845B);
  static const negative = Color(0xFFC64343);

  static bool _isDark(BuildContext context) =>
      CupertinoTheme.brightnessOf(context) == Brightness.dark;

  static Color surface(BuildContext context) =>
      _isDark(context) ? const Color(0xFF24231F) : CupertinoColors.white;

  static Color field(BuildContext context) =>
      _isDark(context) ? const Color(0xFF34322C) : const Color(0xFFF5F4F0);

  static Color softGold(BuildContext context) =>
      _isDark(context) ? const Color(0xFF3B3220) : goldLight;

  static Color border(BuildContext context) =>
      _isDark(context) ? const Color(0xFF3B3932) : const Color(0xFFE9E6DE);

  static Color tabBackground(BuildContext context) =>
      _isDark(context) ? const Color(0xF71C1C1A) : const Color(0xF7FFFFFF);
}

class GoldPortfolioApp extends StatefulWidget {
  const GoldPortfolioApp({super.key, this.controller, this.settings});

  final PortfolioController? controller;
  final SettingsController? settings;

  @override
  State<GoldPortfolioApp> createState() => _GoldPortfolioAppState();
}

class _GoldPortfolioAppState extends State<GoldPortfolioApp> {
  late final PortfolioController _controller;
  late final SettingsController _settings;
  late final bool _ownsController;
  late final bool _ownsSettings;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _ownsSettings = widget.settings == null;
    _controller = widget.controller ?? PortfolioController();
    _settings = widget.settings ?? SettingsController();
    _settings.initialize();
    _controller.initialize();
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    if (_ownsSettings) _settings.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _settings,
      builder: (context, _) {
        setFormattingLocale(_settings.locale);
        final brightness = _settings.isDark ? Brightness.dark : Brightness.light;
        return CupertinoApp(
          title: 'Altın Defterim',
          locale: _settings.locale,
          supportedLocales: const [Locale('tr'), Locale('en')],
          localizationsDelegates: const [
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          debugShowCheckedModeBanner: false,
          theme: CupertinoThemeData(
            brightness: brightness,
            primaryColor: AppColors.gold,
            scaffoldBackgroundColor: _settings.isDark
                ? const Color(0xFF171715)
                : AppColors.background,
            barBackgroundColor: _settings.isDark
                ? const Color(0xF2171715)
                : const Color(0xF2F7F6F2),
            textTheme: CupertinoTextThemeData(
              textStyle: TextStyle(
                fontFamily: '.SF Pro Text',
                color: _settings.isDark ? const Color(0xFFF3F0E8) : AppColors.ink,
                letterSpacing: -0.2,
              ),
            ),
          ),
          home: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => CupertinoTabScaffold(
              tabBar: CupertinoTabBar(
                activeColor: AppColors.gold,
                inactiveColor: CupertinoColors.systemGrey,
                backgroundColor: AppColors.tabBackground(context),
                items: [
                  BottomNavigationBarItem(
                    icon: const Icon(CupertinoIcons.house),
                    activeIcon: const Icon(CupertinoIcons.house_fill),
                    label: context.l10n.text('overview'),
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(CupertinoIcons.chart_bar),
                    activeIcon: const Icon(CupertinoIcons.chart_bar_fill),
                    label: context.l10n.text('markets'),
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(CupertinoIcons.arrow_2_squarepath),
                    label: context.l10n.text('saleSimulation'),
                  ),
                ],
              ),
              tabBuilder: (context, index) => CupertinoTabView(
                builder: (context) => switch (index) {
                  0 => HomeScreen(controller: _controller, settings: _settings),
                  1 => MarketScreen(controller: _controller),
                  _ => SimulationScreen(controller: _controller),
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
