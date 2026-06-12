import 'package:flutter/material.dart';

import 'design_tokens.dart';

abstract final class AppComponentThemes {
  AppComponentThemes._();

  static AppBarTheme appBarTheme(ColorScheme colorScheme) => AppBarTheme(
    backgroundColor: colorScheme.surface,
    foregroundColor: colorScheme.onSurface,
    elevation: DesignTokens.elevation0,
    centerTitle: false,
    titleSpacing: DesignTokens.space16,
    scrolledUnderElevation: DesignTokens.elevation3,
  );

  static ElevatedButtonThemeData elevatedButtonTheme(
    ColorScheme colorScheme,
  ) =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: DesignTokens.elevation0,
          padding: EdgeInsets.symmetric(
            horizontal: DesignTokens.space24,
            vertical: DesignTokens.space16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          ),
          textStyle: TextStyle(
            fontSize: DesignTokens.fontSize16,
            fontWeight: DesignTokens.fontWeightSemiBold,
            letterSpacing: DesignTokens.letterSpacingWide,
          ),
        ),
      );

  static OutlinedButtonThemeData outlinedButtonTheme(
    ColorScheme colorScheme,
  ) =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.outline, width: 1.5),
          padding: EdgeInsets.symmetric(
            horizontal: DesignTokens.space24,
            vertical: DesignTokens.space16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          ),
          textStyle: TextStyle(
            fontSize: DesignTokens.fontSize16,
            fontWeight: DesignTokens.fontWeightSemiBold,
            letterSpacing: DesignTokens.letterSpacingWide,
          ),
        ),
      );

  static TextButtonThemeData textButtonTheme(ColorScheme colorScheme) =>
      TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: EdgeInsets.symmetric(
            horizontal: DesignTokens.space16,
            vertical: DesignTokens.space12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
          ),
        ),
      );

  static InputDecorationTheme inputDecorationTheme(
    ColorScheme colorScheme,
  ) =>
      InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        contentPadding: EdgeInsets.symmetric(
          horizontal: DesignTokens.space16,
          vertical: DesignTokens.space16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        floatingLabelStyle: TextStyle(color: colorScheme.primary),
        prefixIconColor: colorScheme.onSurfaceVariant,
        suffixIconColor: colorScheme.onSurfaceVariant,
      );

  static CardThemeData cardTheme(ColorScheme colorScheme) => CardThemeData(
    color: colorScheme.surfaceContainer,
    elevation: DesignTokens.elevation1,
    shadowColor: colorScheme.shadow,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
    ),
    clipBehavior: Clip.antiAlias,
    margin: EdgeInsets.symmetric(horizontal: DesignTokens.space16),
  );

  static DialogThemeData dialogTheme(ColorScheme colorScheme) => DialogThemeData(
    backgroundColor: colorScheme.surfaceContainerHigh,
    elevation: DesignTokens.elevation4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
    ),
  );

  static NavigationBarThemeData navigationBarTheme(
    ColorScheme colorScheme,
  ) =>
      NavigationBarThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        indicatorColor: colorScheme.secondaryContainer,
        surfaceTintColor: colorScheme.surfaceTint,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colorScheme.onSecondaryContainer);
          }
          return IconThemeData(color: colorScheme.onSurfaceVariant);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              color: colorScheme.onSecondaryContainer,
              fontSize: DesignTokens.fontSize12,
              fontWeight: DesignTokens.fontWeightSemiBold,
            );
          }
          return TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: DesignTokens.fontSize12,
            fontWeight: DesignTokens.fontWeightMedium,
          );
        }),
      );

  static NavigationRailThemeData navigationRailTheme(
    ColorScheme colorScheme,
  ) =>
      NavigationRailThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.secondaryContainer,
      );

  static BottomAppBarThemeData bottomAppBarTheme(ColorScheme colorScheme) =>
      BottomAppBarThemeData(
        color: colorScheme.surfaceContainer,
        elevation: DesignTokens.elevation2,
      );

  static DividerThemeData dividerTheme(ColorScheme colorScheme) =>
      DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: DesignTokens.space24,
      );

  static ProgressIndicatorThemeData progressIndicatorTheme(
    ColorScheme colorScheme,
  ) =>
      ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.surfaceContainerHighest,
        circularTrackColor: colorScheme.surfaceContainerHighest,
      );

  static SnackBarThemeData snackBarTheme(ColorScheme colorScheme) =>
      SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        ),
        contentTextStyle: TextStyle(color: colorScheme.surface),
      );

  static ChipThemeData chipTheme(ColorScheme colorScheme) => ChipThemeData(
    backgroundColor: colorScheme.surfaceContainerHighest,
    labelStyle: TextStyle(color: colorScheme.onSurface),
    side: BorderSide(color: colorScheme.outline),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
    ),
  );

  static IconThemeData iconTheme(ColorScheme colorScheme) => IconThemeData(
    color: colorScheme.onSurfaceVariant,
    size: DesignTokens.sizeIcon,
  );

  static SwitchThemeData switchTheme(ColorScheme colorScheme) => SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return colorScheme.primary;
      }
      return colorScheme.outline;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return colorScheme.primaryContainer;
      }
      return colorScheme.surfaceContainerHighest;
    }),
  );

  static CheckboxThemeData checkboxTheme(ColorScheme colorScheme) =>
      CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.resolveWith((states) {
          return colorScheme.onPrimary;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusXs),
        ),
      );

  static RadioThemeData radioTheme(ColorScheme colorScheme) => RadioThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return colorScheme.primary;
      }
      return colorScheme.onSurfaceVariant;
    }),
  );

  static TooltipThemeData tooltipTheme(ColorScheme colorScheme) =>
      TooltipThemeData(
        decoration: BoxDecoration(
          color: colorScheme.inverseSurface,
          borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
        ),
        textStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: DesignTokens.fontSize14,
        ),
      );

  static FloatingActionButtonThemeData floatingActionButtonTheme(
    ColorScheme colorScheme,
  ) =>
      FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: DesignTokens.elevation3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        ),
      );

  static MenuThemeData menuTheme(ColorScheme colorScheme) => MenuThemeData(
    style: MenuStyle(
      backgroundColor: WidgetStatePropertyAll(colorScheme.surfaceContainer),
      elevation: WidgetStatePropertyAll(DesignTokens.elevation3),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        ),
      ),
    ),
  );

  static BottomSheetThemeData bottomSheetTheme(ColorScheme colorScheme) =>
      BottomSheetThemeData(
        backgroundColor: colorScheme.surfaceContainerHigh,
        elevation: DesignTokens.elevation4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(DesignTokens.radiusXl),
          ),
        ),
        modalElevation: DesignTokens.elevation4,
      );

  static DatePickerThemeData datePickerTheme(ColorScheme colorScheme) =>
      DatePickerThemeData(
        backgroundColor: colorScheme.surfaceContainerHigh,
        headerBackgroundColor: colorScheme.primaryContainer,
        headerForegroundColor: colorScheme.onPrimaryContainer,
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.onPrimary;
          }
          return colorScheme.onSurface;
        }),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return Colors.transparent;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        ),
      );

  static TimePickerThemeData timePickerTheme(ColorScheme colorScheme) =>
      TimePickerThemeData(
        backgroundColor: colorScheme.surfaceContainerHigh,
        hourMinuteColor: colorScheme.surfaceContainerHighest,
        hourMinuteTextColor: colorScheme.onSurface,
        dialBackgroundColor: colorScheme.surfaceContainerHighest,
        dialHandColor: colorScheme.primary,
        dialTextColor: colorScheme.onSurface,
        entryModeIconColor: colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        ),
      );

  static SearchBarThemeData searchBarTheme(ColorScheme colorScheme) =>
      SearchBarThemeData(
        backgroundColor: WidgetStatePropertyAll(
          colorScheme.surfaceContainerHighest,
        ),
        elevation: WidgetStatePropertyAll(DesignTokens.elevation0),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
          ),
        ),
        padding: WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: DesignTokens.space16),
        ),
      );
}
