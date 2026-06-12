import 'package:flutter/material.dart';

import 'design_tokens.dart';

class BrandColors extends ThemeExtension<BrandColors> {
  final Color brandPrimary;
  final Color brandSecondary;
  final Color brandTertiary;
  final Color brandSurface;
  final Color brandBackground;
  final Color brandOnBackground;

  const BrandColors({
    required this.brandPrimary,
    required this.brandSecondary,
    required this.brandTertiary,
    required this.brandSurface,
    required this.brandBackground,
    required this.brandOnBackground,
  });

  static const light = BrandColors(
    brandPrimary: Color(0xFFD4872F),
    brandSecondary: Color(0xFF4A90D9),
    brandTertiary: Color(0xFF7C5CBF),
    brandSurface: Color(0xFFFFF8F0),
    brandBackground: Color(0xFFFFFCF7),
    brandOnBackground: Color(0xFF1C1B1F),
  );

  static const dark = BrandColors(
    brandPrimary: Color(0xFFFFB951),
    brandSecondary: Color(0xFF7CB8F0),
    brandTertiary: Color(0xFFB99CFF),
    brandSurface: Color(0xFF1A1510),
    brandBackground: Color(0xFF0F0E0D),
    brandOnBackground: Color(0xFFE6E1E5),
  );

  @override
  BrandColors copyWith({
    Color? brandPrimary,
    Color? brandSecondary,
    Color? brandTertiary,
    Color? brandSurface,
    Color? brandBackground,
    Color? brandOnBackground,
  }) {
    return BrandColors(
      brandPrimary: brandPrimary ?? this.brandPrimary,
      brandSecondary: brandSecondary ?? this.brandSecondary,
      brandTertiary: brandTertiary ?? this.brandTertiary,
      brandSurface: brandSurface ?? this.brandSurface,
      brandBackground: brandBackground ?? this.brandBackground,
      brandOnBackground: brandOnBackground ?? this.brandOnBackground,
    );
  }

  @override
  BrandColors lerp(ThemeExtension<BrandColors>? other, double t) {
    if (other is! BrandColors) return this;
    return BrandColors(
      brandPrimary: Color.lerp(brandPrimary, other.brandPrimary, t)!,
      brandSecondary: Color.lerp(brandSecondary, other.brandSecondary, t)!,
      brandTertiary: Color.lerp(brandTertiary, other.brandTertiary, t)!,
      brandSurface: Color.lerp(brandSurface, other.brandSurface, t)!,
      brandBackground: Color.lerp(brandBackground, other.brandBackground, t)!,
      brandOnBackground: Color.lerp(
        brandOnBackground,
        other.brandOnBackground,
        t,
      )!,
    );
  }
}

class AppDurations extends ThemeExtension<AppDurations> {
  final Duration quick;
  final Duration normal;
  final Duration slow;

  const AppDurations({
    required this.quick,
    required this.normal,
    required this.slow,
  });

  static const standard = AppDurations(
    quick: DesignTokens.durationQuick,
    normal: DesignTokens.durationNormal,
    slow: DesignTokens.durationSlow,
  );

  @override
  AppDurations copyWith({
    Duration? quick,
    Duration? normal,
    Duration? slow,
  }) {
    return AppDurations(
      quick: quick ?? this.quick,
      normal: normal ?? this.normal,
      slow: slow ?? this.slow,
    );
  }

  @override
  AppDurations lerp(ThemeExtension<AppDurations>? other, double t) {
    if (other is! AppDurations) return this;
    return AppDurations(
      quick: Duration(milliseconds: (quick.inMilliseconds * (1 - t) + other.quick.inMilliseconds * t).round()),
      normal: Duration(milliseconds: (normal.inMilliseconds * (1 - t) + other.normal.inMilliseconds * t).round()),
      slow: Duration(milliseconds: (slow.inMilliseconds * (1 - t) + other.slow.inMilliseconds * t).round()),
    );
  }
}
