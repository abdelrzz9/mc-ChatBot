import 'package:flutter/material.dart';

import 'design_tokens.dart';
import 'app_component_themes.dart';
import 'app_theme_text_styles.dart';
import 'theme_extensions.dart';

abstract final class AppThemeData {
  AppThemeData._();

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: DesignTokens.primarySeed,
      brightness: Brightness.light,
    );

    return _buildThemeData(colorScheme, AppThemeTextStyles.textTheme, BrandColors.light);
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: DesignTokens.primarySeed,
      brightness: Brightness.dark,
    );

    return _buildThemeData(colorScheme, AppThemeTextStyles.textTheme, BrandColors.dark);
  }

  static ThemeData _buildThemeData(
    ColorScheme colorScheme,
    TextTheme textTheme,
    BrandColors brandColors,
  ) {
    return ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: colorScheme.surface,
      primaryColor: colorScheme.primary,

      appBarTheme: AppComponentThemes.appBarTheme(colorScheme),
      elevatedButtonTheme: AppComponentThemes.elevatedButtonTheme(colorScheme),
      outlinedButtonTheme: AppComponentThemes.outlinedButtonTheme(colorScheme),
      textButtonTheme: AppComponentThemes.textButtonTheme(colorScheme),
      inputDecorationTheme: AppComponentThemes.inputDecorationTheme(colorScheme),
      cardTheme: AppComponentThemes.cardTheme(colorScheme),
      dialogTheme: AppComponentThemes.dialogTheme(colorScheme),
      navigationBarTheme: AppComponentThemes.navigationBarTheme(colorScheme),
      navigationRailTheme: AppComponentThemes.navigationRailTheme(colorScheme),
      bottomAppBarTheme: AppComponentThemes.bottomAppBarTheme(colorScheme),
      dividerTheme: AppComponentThemes.dividerTheme(colorScheme),
      progressIndicatorTheme: AppComponentThemes.progressIndicatorTheme(colorScheme),
      snackBarTheme: AppComponentThemes.snackBarTheme(colorScheme),
      chipTheme: AppComponentThemes.chipTheme(colorScheme),
      iconTheme: AppComponentThemes.iconTheme(colorScheme),
      switchTheme: AppComponentThemes.switchTheme(colorScheme),
      checkboxTheme: AppComponentThemes.checkboxTheme(colorScheme),
      radioTheme: AppComponentThemes.radioTheme(colorScheme),
      tooltipTheme: AppComponentThemes.tooltipTheme(colorScheme),
      floatingActionButtonTheme: AppComponentThemes.floatingActionButtonTheme(colorScheme),
      menuTheme: AppComponentThemes.menuTheme(colorScheme),
      bottomSheetTheme: AppComponentThemes.bottomSheetTheme(colorScheme),
      datePickerTheme: AppComponentThemes.datePickerTheme(colorScheme),
      timePickerTheme: AppComponentThemes.timePickerTheme(colorScheme),
      searchBarTheme: AppComponentThemes.searchBarTheme(colorScheme),

      extensions: [
        brandColors,
        AppDurations.standard,
      ],
    );
  }
}
