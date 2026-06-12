import 'package:flutter/material.dart';

import 'design_tokens.dart';

abstract final class AppThemeColors {
  AppThemeColors._();

  static ColorScheme lightColorScheme() => ColorScheme.fromSeed(
    seedColor: DesignTokens.primarySeed,
    brightness: Brightness.light,
    secondary: DesignTokens.secondarySeed,
    tertiary: DesignTokens.tertiarySeed,
  );

  static ColorScheme darkColorScheme() => ColorScheme.fromSeed(
    seedColor: DesignTokens.primarySeed,
    brightness: Brightness.dark,
    secondary: DesignTokens.secondarySeed,
    tertiary: DesignTokens.tertiarySeed,
  );

  static Color get success => DesignTokens.successLight;
  static Color get error => DesignTokens.errorLight;
  static Color get warning => DesignTokens.warningLight;
  static Color get info => DesignTokens.infoLight;
  static Color get successDark => DesignTokens.successDark;
  static Color get errorDark => DesignTokens.errorDark;
  static Color get warningDark => DesignTokens.warningDark;
  static Color get infoDark => DesignTokens.infoDark;
}
