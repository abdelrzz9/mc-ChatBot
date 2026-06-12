import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_theme_colors.dart';

abstract final class AppThemeTextStyles {
  AppThemeTextStyles._();

  static TextStyle get appBarTitleStyle => GoogleFonts.raleway(
    color: AppThemeColors.primaryText,
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get buttonTextStyle => GoogleFonts.raleway(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static TextStyle get inputHintStyle =>
      GoogleFonts.montserrat(color: AppThemeColors.hintText, fontSize: 14);

  static TextStyle get inputLabelStyle => GoogleFonts.raleway(
    color: AppThemeColors.secondaryText,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get splashLargeText => GoogleFonts.playfairDisplay(
    color: AppThemeColors.primaryText,
    fontSize: 48,
    height: 1.0,
    fontWeight: FontWeight.normal,
    fontStyle: FontStyle.italic,
  );

  static TextStyle get splashMediumText => GoogleFonts.playfairDisplay(
    color: AppThemeColors.subtitleText,
    fontSize: 18,
    height: 1.55,
    fontStyle: FontStyle.italic,
  );

  static TextStyle get onboardingLargeText => GoogleFonts.publicSans(
    color: AppThemeColors.primaryText,
    fontSize: 36,
    fontStyle: FontStyle.normal,
  );

  static TextStyle get onboardingMediumText => GoogleFonts.publicSans(
    color: AppThemeColors.subtitleText,
    fontSize: 18,
    fontStyle: FontStyle.normal,
  );

  static TextTheme get textTheme => TextTheme(
    displayLarge: GoogleFonts.raleway(
      color: AppThemeColors.primaryText,
      fontSize: 57,
      fontWeight: FontWeight.bold,
      height: 1.12,
    ),
    displayMedium: GoogleFonts.raleway(
      color: AppThemeColors.primaryText,
      fontSize: 45,
      fontWeight: FontWeight.bold,
      height: 1.16,
    ),
    displaySmall: GoogleFonts.raleway(
      color: AppThemeColors.primaryText,
      fontSize: 36,
      fontWeight: FontWeight.bold,
      height: 1.22,
    ),
    headlineLarge: GoogleFonts.raleway(
      color: AppThemeColors.primaryText,
      fontSize: 32,
      fontWeight: FontWeight.w600,
      height: 1.25,
    ),
    headlineMedium: GoogleFonts.raleway(
      color: AppThemeColors.primaryText,
      fontSize: 28,
      fontWeight: FontWeight.w600,
      height: 1.29,
    ),
    headlineSmall: GoogleFonts.raleway(
      color: AppThemeColors.primaryText,
      fontSize: 24,
      fontWeight: FontWeight.w600,
      height: 1.33,
    ),
    titleLarge: GoogleFonts.raleway(
      color: AppThemeColors.primaryText,
      fontSize: 22,
      fontWeight: FontWeight.w600,
      height: 1.27,
    ),
    titleMedium: GoogleFonts.raleway(
      color: AppThemeColors.primaryText,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.5,
    ),
    titleSmall: GoogleFonts.raleway(
      color: AppThemeColors.secondaryText,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.43,
    ),
    bodyLarge: GoogleFonts.montserrat(
      color: AppThemeColors.primaryText,
      fontSize: 16,
      fontWeight: FontWeight.normal,
      height: 1.5,
    ),
    bodyMedium: GoogleFonts.montserrat(
      color: AppThemeColors.primaryText,
      fontSize: 14,
      fontWeight: FontWeight.normal,
      height: 1.43,
    ),
    bodySmall: GoogleFonts.montserrat(
      color: AppThemeColors.secondaryText,
      fontSize: 12,
      fontWeight: FontWeight.normal,
      height: 1.33,
    ),
    labelLarge: GoogleFonts.raleway(
      color: AppThemeColors.primaryText,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    ),
    labelMedium: GoogleFonts.raleway(
      color: AppThemeColors.secondaryText,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
    labelSmall: GoogleFonts.raleway(
      color: AppThemeColors.hintText,
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
  );
}
