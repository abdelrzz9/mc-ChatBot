import 'package:flutter/material.dart';

abstract final class DesignTokens {
  DesignTokens._();

  // Brand colors - seed for ColorScheme
  static const Color primarySeed = Color(0xFFD4872F);
  static const Color secondarySeed = Color(0xFF4A90D9);
  static const Color tertiarySeed = Color(0xFF7C4DFF);

  // Neutral colors
  static const Color neutralWhite = Color(0xFFFFFBFE);
  static const Color neutralBlack = Color(0xFF1C1B1F);
  static const Color neutralGray50 = Color(0xFFF8F9FA);
  static const Color neutralGray100 = Color(0xFFF1F3F5);
  static const Color neutralGray200 = Color(0xFFE9ECEF);
  static const Color neutralGray300 = Color(0xFFDEE2E6);
  static const Color neutralGray400 = Color(0xFFCED4DA);
  static const Color neutralGray500 = Color(0xFFADB5BD);
  static const Color neutralGray600 = Color(0xFF6C757D);
  static const Color neutralGray700 = Color(0xFF495057);
  static const Color neutralGray800 = Color(0xFF343A40);
  static const Color neutralGray900 = Color(0xFF212529);

  // Semantic colors
  static const Color errorLight = Color(0xFFBA1A1A);
  static const Color errorDark = Color(0xFFFFB4AB);
  static const Color successLight = Color(0xFF2E7D32);
  static const Color successDark = Color(0xFF81C784);
  static const Color warningLight = Color(0xFFF57F17);
  static const Color warningDark = Color(0xFFFFB74D);
  static const Color infoLight = Color(0xFF1565C0);
  static const Color infoDark = Color(0xFF64B5F6);

  // Utility colors
  static const Color utilityHighlight = Color(0xFFFFEB3B);
  static const Color utilityGoogle = Color(0xFF4285F4);
  static const Color utilityOverlay = Color(0x80000000);

  // Sizes
  static const double sizeStatusDot = 10;
  static const double sizeNotifDot = 8;
  static const double sizeIcon = 24;

  // Spacing
  static const double space2 = 2;
  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space20 = 20;
  static const double space24 = 24;
  static const double space32 = 32;
  static const double space40 = 40;
  static const double space48 = 48;
  static const double space56 = 56;
  static const double space64 = 64;

  // Border radius
  static const double radiusXs = 4;
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;
  static const double radiusFull = 999;

  // Elevation
  static const double elevation0 = 0;
  static const double elevation1 = 1;
  static const double elevation2 = 2;
  static const double elevation3 = 4;
  static const double elevation4 = 8;
  static const double elevation5 = 12;
  static const double elevation6 = 16;

  // Duration
  static const Duration durationQuick = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);
  static const Duration durationPageTransition = Duration(milliseconds: 350);

  // Opacity
  static const double opacityDisabled = 0.38;
  static const double opacityMedium = 0.6;
  static const double opacityHigh = 0.87;

  // Font sizes
  static const double fontSize10 = 10;
  static const double fontSize11 = 11;
  static const double fontSize12 = 12;
  static const double fontSize14 = 14;
  static const double fontSize16 = 16;
  static const double fontSize18 = 18;
  static const double fontSize20 = 20;
  static const double fontSize22 = 22;
  static const double fontSize24 = 24;
  static const double fontSize28 = 28;
  static const double fontSize32 = 32;
  static const double fontSize36 = 36;
  static const double fontSize40 = 40;
  static const double fontSize45 = 45;
  static const double fontSize48 = 48;
  static const double fontSize57 = 57;

  // Font weights
  static const FontWeight fontWeightLight = FontWeight.w300;
  static const FontWeight fontWeightRegular = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;

  // Line heights
  static const double lineHeightTight = 1.0;
  static const double lineHeightNormal = 1.2;
  static const double lineHeightRelaxed = 1.5;
  static const double lineHeightLoose = 1.75;

  // Letter spacing
  static const double letterSpacingTight = -0.25;
  static const double letterSpacingNormal = 0.0;
  static const double letterSpacingWide = 0.5;
  static const double letterSpacingWider = 1.0;
}
