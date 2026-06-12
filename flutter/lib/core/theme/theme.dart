import 'package:flutter/material.dart';

import 'app_theme_colors.dart';
import 'app_theme_data.dart';
import 'app_theme_metrics.dart';
import 'app_theme_text_styles.dart';
import 'theme_extensions.dart';

export 'app_theme_colors.dart';
export 'app_theme_data.dart';
export 'app_theme_metrics.dart';
export 'app_theme_text_styles.dart';
export 'app_spacing.dart';
export 'app_radius.dart';
export 'app_elevation.dart';
export 'app_shadows.dart';
export 'theme_extensions.dart';
export 'design_tokens.dart';
export 'app_component_themes.dart';

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

  static const Color primaryColor = AppThemeColors.primaryAccent;
  static const Color primaryAccent = AppThemeColors.primaryAccent;
  static const Color secondaryColor = AppThemeColors.secondaryAccent;
  static const Color secondaryAccent = AppThemeColors.secondaryAccent;
  static const Color accentColor = AppThemeColors.accent;
  static const Color backgroundColor = AppThemeColors.background;
  static const Color surfaceColor = AppThemeColors.surface;
  static const Color cardColor = AppThemeColors.card;
  static const Color onboardingBackgroundColor =
      AppThemeColors.onboardingBackground;
  static const Color splashBackgroundColor = AppThemeColors.splashBackground;
  static const Color readingBackgroundColor = AppThemeColors.readingBackground;
  static const Color activeCardBackgroundColor =
      AppThemeColors.activeCardBackground;
  static const Color activeCardBorderColor = AppThemeColors.activeCardBorder;
  static const Color archivedCardBackgroundColor =
      AppThemeColors.archivedCardBackground;
  static const Color archivedCardBorderColor =
      AppThemeColors.archivedCardBorder;
  static const Color cardDateTextColor = AppThemeColors.cardDateText;
  static const Color archivedTitleColor = AppThemeColors.archivedTitle;
  static const Color archivedDateColor = AppThemeColors.archivedDate;
  static const Color primaryTextColor = AppThemeColors.primaryText;
  static const Color secondaryTextColor = AppThemeColors.secondaryText;
  static const Color hintTextColor = AppThemeColors.hintText;
  static const Color subtitleTextColor = AppThemeColors.subtitleText;
  static const Color goldColor = AppThemeColors.gold;
  static const Color dividerTextColor = AppThemeColors.dividerText;
  static const Color dividerColor = AppThemeColors.divider;
  static const Color gradientOverlayColor = AppThemeColors.gradientOverlay;
  static const Color buttonColor = AppThemeColors.button;
  static const Color selectedColor = AppThemeColors.selected;
  static const Color borderColor = AppThemeColors.border;
  static const Color inputFillColor = AppThemeColors.inputFill;
  static const Color inputBorderColor = AppThemeColors.inputBorder;
  static const Color formCardColor = AppThemeColors.formCard;
  static const Color successColor = AppThemeColors.success;
  static const Color errorColor = AppThemeColors.error;
  static const Color warningColor = AppThemeColors.warning;
  static const Color infoColor = AppThemeColors.info;
  static const Color activeEventDotColor = AppThemeColors.activeEventDot;
  static const Color highlightColor = AppThemeColors.highlight;
  static const Color bookmarkColor = AppThemeColors.bookmark;
  static const Color googleColor = AppThemeColors.google;
  static const Color appleColor = AppThemeColors.apple;
  static const Color overlayColor = AppThemeColors.overlay;
  static const Color shimmerColor = AppThemeColors.shimmer;
  static const Color photoSlotColor = AppThemeColors.photoSlot;
  static const Color tipsBgColor = AppThemeColors.tipsBackground;
  static const Color enrollDisabledColor = AppThemeColors.enrollDisabled;
  static const Color tabUnselectedTextColor = AppThemeColors.tabUnselectedText;
  static const Color tabDividerColor = AppThemeColors.tabDivider;

  static const Color slateGray = AppThemeColors.subtitleText;

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

  static TextStyle get splashLargeText => AppThemeTextStyles.splashLargeText;
  static TextStyle get splashMediumText => AppThemeTextStyles.splashMediumText;
  static TextStyle get onboardingLargeText =>
      AppThemeTextStyles.onboardingLargeText;
  static TextStyle get onboardingMediumText =>
      AppThemeTextStyles.onboardingMediumText;

  static TextStyle get onbaordingLargeText => onboardingLargeText;
  static TextStyle get onbaordingMediumText => onboardingMediumText;
}
