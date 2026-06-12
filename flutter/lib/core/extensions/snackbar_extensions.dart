import 'package:flutter/material.dart';
import '../theme/app_theme_metrics.dart';

extension SnackBarX on BuildContext {
  void showErrorSnackBar(String message) {
    final tt = Theme.of(this).textTheme;
    final cs = Theme.of(this).colorScheme;

    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: tt.bodySmall?.copyWith(color: cs.onError),
          ),
          backgroundColor: cs.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppThemeMetrics.radiusMd),
          ),
          margin: const EdgeInsets.all(AppThemeMetrics.spacingMd),
        ),
      );
  }

  void showSuccessSnackBar(String message) {
    final tt = Theme.of(this).textTheme;
    final cs = Theme.of(this).colorScheme;

    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: tt.bodySmall?.copyWith(color: cs.onPrimary),
          ),
          backgroundColor: cs.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppThemeMetrics.radiusMd),
          ),
          margin: const EdgeInsets.all(AppThemeMetrics.spacingMd),
        ),
      );
  }
}
