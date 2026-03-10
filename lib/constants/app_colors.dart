import 'package:flutter/material.dart';

/// App color palette following the MyChart design system
class AppColors {
  // Prevent instantiation
  AppColors._();

  // Backgrounds
  static const Color primaryBackground = Color(0xFFFFFFFF);
  static const Color secondaryBackground = Color(0xFFF7F7F7);

  // Text Colors
  static const Color primaryText = Color(0xFF282828);
  static const Color secondaryText = Color(0xFF4A4A4A);
  static const Color disabledText = Color(0xFF9E9E9E);

  // Button Colors
  static const Color mainButton = Color(0xFFCBD77E); // Olive tone
  static const Color secondaryButton = Color(0xFFE6CA9A);
  static const Color buttonTextDark = Color(0xFF282828);
  static const Color buttonTextLight = Color(0xFFFFFFFF);

  // Card Colors
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardShadow = Color(0x14000000); // rgba(0,0,0,0.08)

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFA726);
  static const Color info = Color(0xFF29B6F6);

  // Emergency/Ambulance Colors
  static const Color emergency = Color(0xFFD32F2F);
  static const Color ambulanceAccent = Color(0xFFFF5252);

  // Training Module Colors
  static const Color trainingPrimary = Color(0xFF1976D2);
  static const Color trainingSecondary = Color(0xFF64B5F6);

  // Medical Colors
  static const Color medicalPrimary = Color(0xFF00897B);
  static const Color medicalSecondary = Color(0xFF4DB6AC);

  // Divider
  static const Color divider = Color(0xFFE0E0E0);

  // Overlay
  static const Color overlay = Color(0x80000000); // 50% black

  // Doctor Colors (Blue Theme)
  static const Color doctorPrimary = Color(
    0xFF5BA5CE,
  ); // Updated to requested shade
  static const Color doctorSecondary = Color(0xFF64B5F6); // Blue 300
  static const Color doctorBackground = Color(0xFFE3F2FD); // Blue 50

  // Patient Colors (Blue Theme - Matching Doctor for now as requested)
  static const Color patientPrimary = Color(0xFF1565C0); // Blue 800
  static const Color patientSecondary = Color(0xFF64B5F6); // Blue 300
  static const Color patientBackground = Color(0xFFE3F2FD); // Blue 50
}
