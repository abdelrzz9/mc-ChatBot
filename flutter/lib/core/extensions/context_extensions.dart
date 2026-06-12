import 'package:flutter/material.dart';

extension ContextX on BuildContext {
  ThemeData get theme => Theme.of(this);

  MediaQueryData get mq => MediaQuery.of(this);

  Size get size => mq.size;

  double get width => size.width;
  double get height => size.height;

  TextTheme get textTheme => theme.textTheme;

  Orientation get orientation => mq.orientation;

  void unfocus() => FocusScope.of(this).unfocus();
}
