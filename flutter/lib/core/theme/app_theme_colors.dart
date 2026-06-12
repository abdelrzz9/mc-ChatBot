import 'package:flutter/material.dart';

abstract final class AppThemeColors {
  AppThemeColors._();

  static const Color primaryAccent = Color(0xFFD4872F);
  static const Color secondaryAccent = Color(0xFF4A90D9);
  static const Color accent = Color(0xFFFFB951);

  static const Color background = Color(0xFF1A1008);
  static const Color surface = Color(0xFF2A1E0F);
  static const Color card = Color(0xFF2A1E0F);
  static const Color onboardingBackground = Color(0xFF221610);
  static const Color splashBackground = Color(0xFF0F0E0D);
  static const Color readingBackground = Color(0xFF1A1008);

  static const Color activeCardBackground = Color(0xFF0F172A);
  static const Color activeCardBorder = Color(0xFF1E293B);
  static const Color archivedCardBackground = Color(0xFF0F172A);
  static const Color archivedCardBorder = Color(0xFF1E293B);
  static const Color cardDateText = Color(0xFF94A3B8);
  static const Color archivedTitle = Color(0xFF94A3B8);
  static const Color archivedDate = Color(0xFF64748B);

  static const double activeCardBackgroundOpacity = 0.4;
  static const double archivedCardBackgroundOpacity = 0.1;
  static const double archivedCardBorderOpacity = 0.4;

  static const Color primaryText = Color(0xFFFFFFFF);
  static const Color secondaryText = Color(0xFFB0A090);
  static const Color hintText = Color(0xFF7A6A5A);
  static const Color subtitleText = Color(0xFF94A3B8);

  static const Color gold = Color(0xFFE8A830);
  static const Color dividerText = Color(0xFF64748B);
  static const Color divider = Color(0xFF1E293B);
  static const Color gradientOverlay = Color(0x33D4872F);

  static const Color button = Color(0xFFD4872F);
  static const Color selected = Color(0xFF3A2A15);
  static const Color border = Color(0xFF3D2E1A);
  static const Color inputFill = Color(0xFF231809);
  static const Color inputBorder = Color(0xFF4A3820);
  static const Color formCard = Color(0x1AD4872F);

  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFFD4872F);
  static const Color activeEventDot = Color(0xFF22C55E);

  static const Color highlight = Color(0xFFFFEB3B);
  static const Color bookmark = Color(0xFFD4872F);
  static const Color google = Color(0xFF4285F4);
  static const Color apple = Color(0xFFFFFFFF);
  static const Color overlay = Color(0x80000000);
  static const Color shimmer = Color(0xFF3A2A15);
  static const Color photoSlot = Color(0xFF334155);
  static const Color tipsBackground = Color(0x1A64748B);
  static const Color enrollDisabled = Color(0x33EC5B13);

  static const Color tabUnselectedText = Color(0xFF94A3B8);
  static const Color tabDivider = Color.fromRGBO(255, 255, 255, 0.1);
}
