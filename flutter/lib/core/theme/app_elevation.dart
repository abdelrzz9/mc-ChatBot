import 'design_tokens.dart';

abstract final class AppElevation {
  AppElevation._();

  static const double none = DesignTokens.elevation0;
  static const double low = DesignTokens.elevation1;
  static const double medium = DesignTokens.elevation2;
  static const double high = DesignTokens.elevation3;
  static const double extraHigh = DesignTokens.elevation4;
  static const double overlay = DesignTokens.elevation5;
}
