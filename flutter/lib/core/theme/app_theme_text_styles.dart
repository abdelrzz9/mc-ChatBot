import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'design_tokens.dart';

abstract final class AppThemeTextStyles {
  AppThemeTextStyles._();

  static TextStyle get appBarTitleStyle => GoogleFonts.raleway(
    fontSize: DesignTokens.fontSize20,
    fontWeight: DesignTokens.fontWeightSemiBold,
  );

  static TextStyle get buttonTextStyle => GoogleFonts.raleway(
    fontSize: DesignTokens.fontSize16,
    fontWeight: DesignTokens.fontWeightSemiBold,
    letterSpacing: DesignTokens.letterSpacingWide,
  );

  static TextStyle get inputHintStyle => GoogleFonts.montserrat(
    fontSize: DesignTokens.fontSize14,
  );

  static TextStyle get inputLabelStyle => GoogleFonts.raleway(
    fontSize: DesignTokens.fontSize14,
    fontWeight: DesignTokens.fontWeightMedium,
  );

  static TextStyle get splashLargeText => GoogleFonts.playfairDisplay(
    fontSize: DesignTokens.fontSize48,
    height: DesignTokens.lineHeightTight,
    fontWeight: DesignTokens.fontWeightRegular,
    fontStyle: FontStyle.italic,
  );

  static TextStyle get splashMediumText => GoogleFonts.playfairDisplay(
    fontSize: DesignTokens.fontSize18,
    height: DesignTokens.lineHeightRelaxed,
    fontStyle: FontStyle.italic,
  );

  static TextStyle get onboardingLargeText => GoogleFonts.publicSans(
    fontSize: DesignTokens.fontSize36,
    fontStyle: FontStyle.normal,
  );

  static TextStyle get onboardingMediumText => GoogleFonts.publicSans(
    fontSize: DesignTokens.fontSize18,
    fontStyle: FontStyle.normal,
  );

  static TextTheme get textTheme => TextTheme(
    displayLarge: GoogleFonts.raleway(
      fontSize: DesignTokens.fontSize57,
      fontWeight: DesignTokens.fontWeightBold,
      height: DesignTokens.lineHeightNormal,
      letterSpacing: DesignTokens.letterSpacingTight,
    ),
    displayMedium: GoogleFonts.raleway(
      fontSize: DesignTokens.fontSize45,
      fontWeight: DesignTokens.fontWeightBold,
      height: DesignTokens.lineHeightNormal,
    ),
    displaySmall: GoogleFonts.raleway(
      fontSize: DesignTokens.fontSize36,
      fontWeight: DesignTokens.fontWeightBold,
      height: DesignTokens.lineHeightNormal,
    ),
    headlineLarge: GoogleFonts.raleway(
      fontSize: DesignTokens.fontSize32,
      fontWeight: DesignTokens.fontWeightSemiBold,
      height: DesignTokens.lineHeightNormal,
    ),
    headlineMedium: GoogleFonts.raleway(
      fontSize: DesignTokens.fontSize28,
      fontWeight: DesignTokens.fontWeightSemiBold,
      height: DesignTokens.lineHeightNormal,
    ),
    headlineSmall: GoogleFonts.raleway(
      fontSize: DesignTokens.fontSize24,
      fontWeight: DesignTokens.fontWeightSemiBold,
      height: DesignTokens.lineHeightNormal,
    ),
    titleLarge: GoogleFonts.raleway(
      fontSize: DesignTokens.fontSize22,
      fontWeight: DesignTokens.fontWeightSemiBold,
      height: DesignTokens.lineHeightNormal,
    ),
    titleMedium: GoogleFonts.raleway(
      fontSize: DesignTokens.fontSize16,
      fontWeight: DesignTokens.fontWeightSemiBold,
      height: DesignTokens.lineHeightRelaxed,
    ),
    titleSmall: GoogleFonts.raleway(
      fontSize: DesignTokens.fontSize14,
      fontWeight: DesignTokens.fontWeightSemiBold,
      height: DesignTokens.lineHeightRelaxed,
    ),
    bodyLarge: GoogleFonts.montserrat(
      fontSize: DesignTokens.fontSize16,
      fontWeight: DesignTokens.fontWeightRegular,
      height: DesignTokens.lineHeightRelaxed,
    ),
    bodyMedium: GoogleFonts.montserrat(
      fontSize: DesignTokens.fontSize14,
      fontWeight: DesignTokens.fontWeightRegular,
      height: DesignTokens.lineHeightRelaxed,
    ),
    bodySmall: GoogleFonts.montserrat(
      fontSize: DesignTokens.fontSize12,
      fontWeight: DesignTokens.fontWeightRegular,
      height: DesignTokens.lineHeightRelaxed,
    ),
    labelLarge: GoogleFonts.raleway(
      fontSize: DesignTokens.fontSize14,
      fontWeight: DesignTokens.fontWeightMedium,
      letterSpacing: DesignTokens.letterSpacingNormal,
    ),
    labelMedium: GoogleFonts.raleway(
      fontSize: DesignTokens.fontSize12,
      fontWeight: DesignTokens.fontWeightMedium,
      letterSpacing: DesignTokens.letterSpacingWide,
    ),
    labelSmall: GoogleFonts.raleway(
      fontSize: DesignTokens.fontSize11,
      fontWeight: DesignTokens.fontWeightMedium,
      letterSpacing: DesignTokens.letterSpacingWide,
    ),
  );
}
