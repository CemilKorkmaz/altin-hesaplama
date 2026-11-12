import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/formatters.dart';

class SettingsController extends ChangeNotifier {
  static const _darkKey = 'settings_dark_mode';
  static const _localeKey = 'settings_locale';

  bool _isDark = false;
  Locale _locale = const Locale('tr');

  bool get isDark => _isDark;
  Locale get locale => _locale;

  Future<void> initialize() async {
    final preferences = await SharedPreferences.getInstance();
    _isDark = preferences.getBool(_darkKey) ?? false;
    _locale = Locale(preferences.getString(_localeKey) ?? 'tr');
    setFormattingLocale(_locale);
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDark = !_isDark;
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_darkKey, _isDark);
  }

  Future<void> setLocale(Locale locale) async {
    if (locale.languageCode != 'tr' && locale.languageCode != 'en') return;
    _locale = locale;
    setFormattingLocale(locale);
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_localeKey, locale.languageCode);
  }
}
