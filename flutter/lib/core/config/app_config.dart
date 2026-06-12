import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get baseUrl => dotenv.env['BASE_URL']?.trim() ?? '';

  static bool get isProduction {
    final url = baseUrl;
    return url.startsWith('https://');
  }

  static bool get isBaseUrlValid {
    final url = baseUrl;
    if (url.isEmpty) return false;
    final uri = Uri.tryParse(url);
    return uri?.hasScheme == true && uri?.host.isNotEmpty == true;
  }

  static bool get isBaseUrlHttps {
    final url = baseUrl;
    if (url.isEmpty) return false;
    try {
      final uri = Uri.parse(url);
      return uri.scheme == 'https';
    } catch (_) {
      return false;
    }
  }

  static List<String> get requiredKeys => ['BASE_URL', 'GOOGLE_CLIENT_ID'];

  static List<String> validate() {
    final missing = <String>[];
    for (final key in requiredKeys) {
      final value = dotenv.env[key]?.trim();
      if (value == null || value.isEmpty) missing.add(key);
    }
    return missing;
  }
}
