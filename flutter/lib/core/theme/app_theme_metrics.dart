import 'design_tokens.dart';

abstract final class AppThemeMetrics {
  AppThemeMetrics._();

  static const double radiusSm = DesignTokens.radiusSm;
  static const double radiusMd = DesignTokens.radiusMd;
  static const double radiusLg = DesignTokens.radiusLg;
  static const double radiusXl = DesignTokens.radiusXl;

  static const double spacingXs = DesignTokens.space4;
  static const double spacingSm = DesignTokens.space8;
  static const double spacingMd = DesignTokens.space16;
  static const double spacingLg = DesignTokens.space24;
  static const double spacingXl = DesignTokens.space32;
  static const double spacingXxl = DesignTokens.space40;

  static const double activeCardAspectWidth = 358.0;
  static const double activeCardBreakpoint = 350.0;
  static const double statusDotSize = DesignTokens.sizeStatusDot;
  static const double notifDotSize = DesignTokens.sizeNotifDot;
  static const double emptyStatePadding = DesignTokens.space32;
}
