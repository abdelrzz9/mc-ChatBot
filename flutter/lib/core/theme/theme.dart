import 'package:flutter/material.dart';

import 'app_theme_data.dart';
import 'app_theme_metrics.dart';
import 'app_theme_text_styles.dart';
import 'design_tokens.dart';
import 'theme_extensions.dart';

export 'app_component_themes.dart';
export 'app_elevation.dart';
export 'app_radius.dart';
export 'app_shadows.dart';
export 'app_spacing.dart';
export 'app_theme_colors.dart';
export 'app_theme_data.dart';
export 'app_theme_metrics.dart';
export 'app_theme_text_styles.dart';
export 'design_tokens.dart';
export 'theme_extensions.dart';

abstract final class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => AppThemeData.lightTheme;
  static ThemeData get darkTheme => AppThemeData.darkTheme;

  static ThemeData resolve(Brightness brightness) =>
      brightness == Brightness.dark ? darkTheme : lightTheme;

  static BrandColors brandColors(BuildContext context) =>
      Theme.of(context).extension<BrandColors>() ?? BrandColors.light;

  static AppDurations durations(BuildContext context) =>
      Theme.of(context).extension<AppDurations>() ?? AppDurations.standard;

  // Color conveniences - all from DesignTokens
  static const Color primaryColor = DesignTokens.primarySeed;
  static const Color primaryAccent = DesignTokens.primarySeed;
  static const Color secondaryColor = DesignTokens.secondarySeed;
  static const Color secondaryAccent = DesignTokens.secondarySeed;
  static const Color accentColor = DesignTokens.primarySeed;
  static const Color backgroundColor = DesignTokens.neutralBlack;
  static const Color surfaceColor = DesignTokens.neutralGray900;
  static const Color cardColor = DesignTokens.neutralGray900;
  static const Color onboardingBackgroundColor = DesignTokens.neutralBlack;
  static const Color splashBackgroundColor = DesignTokens.neutralBlack;
  static const Color readingBackgroundColor = DesignTokens.neutralBlack;
  static const Color activeCardBackgroundColor = DesignTokens.neutralGray800;
  static const Color activeCardBorderColor = DesignTokens.neutralGray700;
  static const Color archivedCardBackgroundColor = DesignTokens.neutralGray800;
  static const Color archivedCardBorderColor = DesignTokens.neutralGray700;
  static const Color cardDateTextColor = DesignTokens.neutralGray500;
  static const Color archivedTitleColor = DesignTokens.neutralGray500;
  static const Color archivedDateColor = DesignTokens.neutralGray600;
  static const Color primaryTextColor = DesignTokens.neutralWhite;
  static const Color secondaryTextColor = DesignTokens.neutralGray300;
  static const Color hintTextColor = DesignTokens.neutralGray600;
  static const Color subtitleTextColor = DesignTokens.neutralGray500;
  static const Color goldColor = DesignTokens.primarySeed;
  static const Color dividerTextColor = DesignTokens.neutralGray600;
  static const Color dividerColor = DesignTokens.neutralGray700;
  static const Color gradientOverlayColor = DesignTokens.primarySeed;
  static const Color buttonColor = DesignTokens.primarySeed;
  static const Color selectedColor = DesignTokens.neutralGray800;
  static const Color borderColor = DesignTokens.neutralGray700;
  static const Color inputFillColor = DesignTokens.neutralGray900;
  static const Color inputBorderColor = DesignTokens.neutralGray600;
  static const Color formCardColor = DesignTokens.primarySeed;
  static const Color successColor = DesignTokens.successLight;
  static const Color errorColor = DesignTokens.errorLight;
  static const Color warningColor = DesignTokens.warningLight;
  static const Color infoColor = DesignTokens.infoLight;
  static const Color activeEventDotColor = DesignTokens.successLight;
  static const Color highlightColor = DesignTokens.utilityHighlight;
  static const Color bookmarkColor = DesignTokens.primarySeed;
  static const Color googleColor = DesignTokens.utilityGoogle;
  static const Color appleColor = DesignTokens.neutralWhite;
  static const Color overlayColor = DesignTokens.utilityOverlay;
  static const Color shimmerColor = DesignTokens.neutralGray800;
  static const Color photoSlotColor = DesignTokens.neutralGray600;
  static const Color tipsBgColor = DesignTokens.neutralGray500;
  static const Color enrollDisabledColor = DesignTokens.primarySeed;
  static const Color tabUnselectedTextColor = DesignTokens.neutralGray500;
  static const Color tabDividerColor = DesignTokens.neutralGray300;
  static const Color slateGray = DesignTokens.neutralGray500;

  // Metrics conveniences - all from DesignTokens via AppThemeMetrics
  static const double radiusSm = AppThemeMetrics.radiusSm;
  static const double radiusMd = AppThemeMetrics.radiusMd;
  static const double radiusLg = AppThemeMetrics.radiusLg;
  static const double radiusXl = AppThemeMetrics.radiusXl;
  static const double spacingXs = AppThemeMetrics.spacingXs;
  static const double spacingSm = AppThemeMetrics.spacingSm;
  static const double spacingMd = AppThemeMetrics.spacingMd;
  static const double spacingLg = AppThemeMetrics.spacingLg;
  static const double spacingXl = AppThemeMetrics.spacingXl;
  static const double spacingXxl = AppThemeMetrics.spacingXxl;
  static const double activeCardAspectWidth =
      AppThemeMetrics.activeCardAspectWidth;
  static const double activeCardBreakpoint =
      AppThemeMetrics.activeCardBreakpoint;
  static const double statusDotSize = AppThemeMetrics.statusDotSize;
  static const double notifDotSize = AppThemeMetrics.notifDotSize;
  static const double emptyStatePadding = AppThemeMetrics.emptyStatePadding;

  // Text style conveniences
  static TextStyle get splashLargeText => AppThemeTextStyles.splashLargeText;
  static TextStyle get splashMediumText => AppThemeTextStyles.splashMediumText;
  static TextStyle get onboardingLargeText =>
      AppThemeTextStyles.onboardingLargeText;
  static TextStyle get onboardingMediumText =>
      AppThemeTextStyles.onboardingMediumText;

  static TextStyle get onbaordingLargeText => onboardingLargeText;
  static TextStyle get onbaordingMediumText => onboardingMediumText;
}
