import 'package:flutter/material.dart';

abstract final class AppShadows {
  AppShadows._();

  static const List<BoxShadow> elevation0 = [];

  static const List<BoxShadow> elevation1 = [
    BoxShadow(
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
      color: Color(0x1A000000),
    ),
  ];

  static const List<BoxShadow> elevation2 = [
    BoxShadow(
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
      color: Color(0x1A000000),
    ),
  ];

  static const List<BoxShadow> elevation3 = [
    BoxShadow(
      offset: Offset(0, 4),
      blurRadius: 8,
      spreadRadius: 0,
      color: Color(0x1A000000),
    ),
  ];

  static const List<BoxShadow> elevation4 = [
    BoxShadow(
      offset: Offset(0, 6),
      blurRadius: 12,
      spreadRadius: 0,
      color: Color(0x26000000),
    ),
  ];

  static const List<BoxShadow> elevation5 = [
    BoxShadow(
      offset: Offset(0, 8),
      blurRadius: 16,
      spreadRadius: 0,
      color: Color(0x33000000),
    ),
  ];

  static const List<BoxShadow> elevation6 = [
    BoxShadow(
      offset: Offset(0, 12),
      blurRadius: 24,
      spreadRadius: 0,
      color: Color(0x40000000),
    ),
  ];
}
