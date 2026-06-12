import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme_metrics.dart';
import 'context_extensions.dart';

extension ResponsiveX on BuildContext {
  double heightCalculated(double height) {
    return height * this.height / 852;
  }

  double widthCalculated(double width) {
    return width * this.width / 393;
  }

  double hPadding() => (width * 0.06).clamp(
    AppThemeMetrics.spacingLg,
    AppThemeMetrics.spacingXxl,
  );

  double cardMaxWidth() => min(width * 0.92, 480.0);

  double logoSize() => (width * 0.15).clamp(56.0, 88.0);

  double titleFontSize() => (width * 0.07).clamp(22.0, 32.0);

  double sectionSpacing() => height * 0.02;

  double iconSize() => (width * 0.055).clamp(20.0, 26.0);

  double radius() =>
      (width * 0.03).clamp(AppThemeMetrics.radiusSm, AppThemeMetrics.radiusMd);
}
