import 'package:flutter/foundation.dart';

class SecureLogger {
  SecureLogger._();

  static const _sensitivePatterns = [
    r'access_token',
    r'refresh_token',
    r'password',
    r'secret',
    r'api_key',
    r'authorization',
    r'bearer\s+\S+',
    r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b',
  ];

  static void debug(String tag, String message) {
    assert(() {
      debugPrint('[SecureLogger][$tag] $message');
      return true;
    }());
  }

  static void info(String tag, String message) {
    final sanitized = _sanitize(message);
    debugPrint('[SecureLogger][$tag][INFO] $sanitized');
  }

  static void warning(String tag, String message) {
    final sanitized = _sanitize(message);
    debugPrint('[SecureLogger][$tag][WARNING] $sanitized');
  }

  static void error(String tag, String message, [Object? error]) {
    final sanitized = _sanitize(message);
    debugPrint('[SecureLogger][$tag][ERROR] $sanitized');
    if (error != null && kDebugMode) {
      debugPrint('[SecureLogger][$tag][ERROR_DETAIL] ${error.runtimeType}');
    }
  }

  static String _sanitize(String message) {
    var sanitized = message;
    for (final pattern in _sensitivePatterns) {
      try {
        sanitized = sanitized.replaceAllMapped(
          RegExp(pattern, caseSensitive: false),
          (match) => _obfuscateMatch(match.group(0) ?? ''),
        );
      } catch (_) {}
    }
    return sanitized;
  }

  static String _obfuscateMatch(String value) {
    if (value.length <= 4) return '****';
    return '${value.substring(0, 2)}****${value.substring(value.length - 2)}';
  }
}
