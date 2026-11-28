import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeLocaleProvider extends ChangeNotifier {
  static const String _themeKey = 'isDarkMode';
  static const String _localeKey = 'languageCode';

  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('en');

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  Locale get locale => _locale;
  bool get isBm => _locale.languageCode == 'ms';

  ThemeLocaleProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeKey) ?? false;
    final langCode = prefs.getString(_localeKey) ?? 'en';

    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    _locale = Locale(langCode);
    notifyListeners();
  }

  Future<void> toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
  }

  Future<void> setLocale(Locale newLocale) async {
    if (!['en', 'ms'].contains(newLocale.languageCode)) return;
    _locale = newLocale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, newLocale.languageCode);
  }
}