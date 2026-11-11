import 'package:cupertino_ui/cupertino_ui.dart';

import 'screens/home_screen.dart';
import 'screens/market_screen.dart';
import 'screens/simulation_screen.dart';
import 'state/portfolio_controller.dart';

class AppColors {
  static const gold = Color(0xFFB88925);
  static const goldLight = Color(0xFFF4E9CF);
  static const ink = Color(0xFF1D1C19);
  static const background = Color(0xFFF7F6F2);
  static const positive = Color(0xFF23845B);
  static const negative = Color(0xFFC64343);
}

class GoldPortfolioApp extends StatefulWidget {
  const GoldPortfolioApp({super.key, this.controller});

  final PortfolioController? controller;

  @override
  State<GoldPortfolioApp> createState() => _GoldPortfolioAppState();
}

class _GoldPortfolioAppState extends State<GoldPortfolioApp> {
  late final PortfolioController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? PortfolioController();
    _controller.initialize();
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Altın Defterim',
      debugShowCheckedModeBanner: false,
      theme: const CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: AppColors.gold,
        scaffoldBackgroundColor: AppColors.background,
        barBackgroundColor: Color(0xF2F7F6F2),
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(
            fontFamily: '.SF Pro Text',
            color: AppColors.ink,
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
            backgroundColor: const Color(0xF7FFFFFF),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.house),
                activeIcon: Icon(CupertinoIcons.house_fill),
                label: 'Özet',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.chart_bar),
                activeIcon: Icon(CupertinoIcons.chart_bar_fill),
                label: 'Piyasalar',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.arrow_2_squarepath),
                label: 'Satış Simülasyonu',
              ),
            ],
          ),
          tabBuilder: (context, index) => CupertinoTabView(
            builder: (context) => switch (index) {
              0 => HomeScreen(controller: _controller),
              1 => MarketScreen(controller: _controller),
              _ => SimulationScreen(controller: _controller),
            },
          ),
        ),
      ),
    );
  }
}
