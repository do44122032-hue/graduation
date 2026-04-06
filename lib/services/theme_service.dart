import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static const String _themeKey = 'is_dark_mode';
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeService() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey(_themeKey)) {
        final isDark = prefs.getBool(_themeKey) ?? false;
        _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
        debugPrint('DEBUG ThemeService: Loaded saved theme: ${isDark ? "DARK" : "LIGHT"}');
      } else {
        debugPrint('DEBUG ThemeService: No saved theme found, defaulting to LIGHT');
      }
      notifyListeners();
    } catch (e) {
      debugPrint('DEBUG ThemeService: Error loading theme: $e');
    }
  }

  Future<void> toggleTheme() async {
    // 1. Calculate new state
    final nextIsDark = !isDarkMode;
    _themeMode = nextIsDark ? ThemeMode.dark : ThemeMode.light;
    
    // 2. Notify listeners immediately for best UX
    notifyListeners();
    debugPrint('DEBUG ThemeService: Toggling theme to: ${nextIsDark ? "DARK" : "LIGHT"}');

    // 3. Persist to storage
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, nextIsDark);
      debugPrint('DEBUG ThemeService: Saved preference successfully');
    } catch (e) {
      debugPrint('DEBUG ThemeService: Error saving theme: $e');
    }
  }
}
