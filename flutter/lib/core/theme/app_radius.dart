import 'package:flutter/material.dart';
import 'design_tokens.dart';

abstract final class AppRadius {
  AppRadius._();

  static const double xs = DesignTokens.radiusXs;
  static const double sm = DesignTokens.radiusSm;
  static const double md = DesignTokens.radiusMd;
  static const double lg = DesignTokens.radiusLg;
  static const double xl = DesignTokens.radiusXl;
  static const double full = DesignTokens.radiusFull;

  static const BorderRadius borderRadiusXs = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius borderRadiusSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius borderRadiusMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius borderRadiusLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius borderRadiusXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius borderRadiusFull = BorderRadius.all(Radius.circular(full));
}
