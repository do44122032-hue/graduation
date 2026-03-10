import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Language service for managing app localization
class LanguageService extends ChangeNotifier {
  String _currentLanguage = 'en'; // Default to English

  String get currentLanguage => _currentLanguage;

  LanguageService() {
    _loadLanguage();
  }

  /// Load saved language from local storage
  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentLanguage = prefs.getString('language') ?? 'en';
      notifyListeners();
    } catch (e) {
      // If error, keep default language
      _currentLanguage = 'en';
    }
  }

  /// Change app language
  Future<void> changeLanguage(String languageCode) async {
    if (_currentLanguage == languageCode) return;

    _currentLanguage = languageCode;
    notifyListeners();

    // Save to local storage
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', languageCode);
    } catch (e) {
      // Handle error silently
    }
  }

  /// Get text direction based on language
  TextDirection get textDirection {
    return (_currentLanguage == 'ar' || _currentLanguage == 'ku')
        ? TextDirection.rtl
        : TextDirection.ltr;
  }

  /// Check if current language is RTL
  bool get isRTL => _currentLanguage == 'ar' || _currentLanguage == 'ku';
}
