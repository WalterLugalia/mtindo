import 'package:flutter/material.dart';

/// Color tokens for Mtindo, derived from the approved design mockups:
/// warm ivory background, deep burgundy as the primary accent.
class AppColors {
  AppColors._();

  // Backgrounds
  static const Color background = Color(0xFFF5F1EA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFEFEAE1);

  // Brand / accent
  static const Color primary = Color(0xFF7A2E3A);
  static const Color primaryDark = Color(0xFF5E1F28);
  static const Color primaryLight = Color(0xFF9B4A56);

  // Text
  static const Color textPrimary = Color(0xFF1C1B1A);
  static const Color textSecondary = Color(0xFF6B6058);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF9C9289);

  // Status
  static const Color error = Color(0xFFB3261E);
  static const Color success = Color(0xFF3A7D5C);
  static const Color warning = Color(0xFFB8793A);

  // Borders / dividers
  static const Color border = Color(0xFFE2DBCF);
  static const Color divider = Color(0xFFE8E2D7);
}