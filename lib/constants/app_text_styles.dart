import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Text styles following the MyChart design system
/// Supports language-specific sizing and fonts for English, Arabic, and Kurdish
class AppTextStyles {
  // Prevent instantiation
  AppTextStyles._();

  // Font family logic
  static String getHeaderFontFamily(String languageCode) {
    if (languageCode == 'ar') return 'Cairo';
    if (languageCode == 'ku') return 'Rabar';
    return 'SF Pro Display'; // or 'Inter'
  }

  static String getBodyFontFamily(String languageCode) {
    if (languageCode == 'ar') return 'BM Plex Arabic'; // User requested IBM Plex Arabic for Body
    if (languageCode == 'ku') return 'Rabar';
    return 'Roboto'; // or 'Inter'
  }

  // Headers (H1) - EN: 26-30px, AR: 28-32px
  static TextStyle h1({String languageCode = 'en', Color? color}) {
    final fontSize = languageCode == 'ar' || languageCode == 'ku' ? 30.0 : 28.0;
    return TextStyle(
      fontFamily: getHeaderFontFamily(languageCode),
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: color ?? AppColors.primaryText,
      height: 1.2,
    );
  }

  // Subtitle headers (H2) - EN: 22-24px, AR: 24-26px
  static TextStyle h2({String languageCode = 'en', Color? color}) {
    final fontSize = languageCode == 'ar' || languageCode == 'ku' ? 25.0 : 23.0;
    return TextStyle(
      fontFamily: getHeaderFontFamily(languageCode),
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: color ?? AppColors.primaryText,
      height: 1.3,
    );
  }

  // Section headers (H3) - EN: 18-20px, AR: 20-22px
  static TextStyle h3({String languageCode = 'en', Color? color}) {
    final fontSize = languageCode == 'ar' || languageCode == 'ku' ? 21.0 : 19.0;
    return TextStyle(
      fontFamily: getHeaderFontFamily(languageCode),
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: color ?? AppColors.primaryText,
      height: 1.4,
    );
  }

  // Body text - EN: 14-16px, AR: 16-18px
  static TextStyle body({String languageCode = 'en', Color? color}) {
    final fontSize = languageCode == 'ar' || languageCode == 'ku' ? 17.0 : 15.0;
    return TextStyle(
      fontFamily: getBodyFontFamily(languageCode),
      fontSize: fontSize,
      fontWeight: FontWeight.normal,
      color: color ?? AppColors.primaryText,
      height: 1.5,
    );
  }

  // Body text medium
  static TextStyle bodyMedium({String languageCode = 'en', Color? color}) {
    final fontSize = languageCode == 'ar' || languageCode == 'ku' ? 17.0 : 15.0;
    return TextStyle(
      fontFamily: getBodyFontFamily(languageCode),
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      color: color ?? AppColors.primaryText,
      height: 1.5,
    );
  }

  // Secondary/Caption text - EN: 12-14px, AR: 14-16px
  static TextStyle caption({String languageCode = 'en', Color? color}) {
    final fontSize = languageCode == 'ar' || languageCode == 'ku' ? 15.0 : 13.0;
    return TextStyle(
      fontFamily: getBodyFontFamily(languageCode),
      fontSize: fontSize,
      fontWeight: FontWeight.normal,
      color: color ?? AppColors.secondaryText,
      height: 1.4,
    );
  }

  // Button text - EN: 16-18px, AR: 18-20px
  static TextStyle button({String languageCode = 'en', Color? color}) {
    final fontSize = languageCode == 'ar' || languageCode == 'ku' ? 19.0 : 17.0;
    return TextStyle(
      fontFamily: getBodyFontFamily(languageCode), // Using Body font for buttons
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: color ?? AppColors.buttonTextLight,
      height: 1.2,
    );
  }

  // Small button text
  static TextStyle buttonSmall({String languageCode = 'en', Color? color}) {
    final fontSize = languageCode == 'ar' || languageCode == 'ku' ? 16.0 : 14.0;
    return TextStyle(
      fontFamily: getBodyFontFamily(languageCode),
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: color ?? AppColors.buttonTextLight,
      height: 1.2,
    );
  }

  // Label text
  static TextStyle label({String languageCode = 'en', Color? color}) {
    final fontSize = languageCode == 'ar' || languageCode == 'ku' ? 15.0 : 13.0;
    return TextStyle(
      fontFamily: getBodyFontFamily(languageCode),
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      color: color ?? AppColors.secondaryText,
      height: 1.3,
    );
  }

  // Overline text
  static TextStyle overline({String languageCode = 'en', Color? color}) {
    final fontSize = languageCode == 'ar' || languageCode == 'ku' ? 13.0 : 11.0;
    return TextStyle(
      fontFamily: getBodyFontFamily(languageCode),
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      color: color ?? AppColors.secondaryText,
      letterSpacing: 0.5,
      height: 1.2,
    );
  }
}
