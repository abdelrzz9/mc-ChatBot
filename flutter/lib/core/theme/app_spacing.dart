import 'package:flutter/material.dart';
import 'design_tokens.dart';

abstract final class AppSpacing {
  AppSpacing._();

  static const double xxs = DesignTokens.space2;
  static const double xs = DesignTokens.space4;
  static const double sm = DesignTokens.space8;
  static const double md = DesignTokens.space12;
  static const double lg = DesignTokens.space16;
  static const double xl = DesignTokens.space20;
  static const double xxl = DesignTokens.space24;
  static const double xxxl = DesignTokens.space32;
  static const double huge = DesignTokens.space40;
  static const double massive = DesignTokens.space48;

  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(lg);
  static const EdgeInsets paddingLg = EdgeInsets.all(xxl);
  static const EdgeInsets paddingXl = EdgeInsets.all(xxxl);

  static const EdgeInsets hPaddingSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets hPaddingMd = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets hPaddingLg = EdgeInsets.symmetric(horizontal: xxl);

  static const EdgeInsets vPaddingSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets vPaddingMd = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets vPaddingLg = EdgeInsets.symmetric(vertical: xxl);
}
