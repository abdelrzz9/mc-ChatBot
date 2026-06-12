import 'package:flutter/material.dart';

extension NavigationX on BuildContext {
  T? getArgs<T>() {
    final args = ModalRoute.of(this)?.settings.arguments;

    if (args is Map<String, dynamic> && args['data'] is T) {
      return args['data'] as T;
    }

    return null;
  }

  void pop() {
    Navigator.pop(this);
  }
}
