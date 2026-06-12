import '../config/app_config.dart';
import 'secure_logger.dart';

class EnvValidator {
  EnvValidator._();

  static List<String> validate() => AppConfig.validate();

  static bool isBaseUrlValid() => AppConfig.isBaseUrlValid;

  static bool isProduction() => AppConfig.isProduction;

  static bool isBaseUrlHttps() => AppConfig.isBaseUrlHttps;

  static void validateProduction() {
    if (!AppConfig.isBaseUrlHttps) {
      SecureLogger.error('EnvValidator', 'PRODUCTION MODE REQUIRES HTTPS.');
    }
    final missing = validate();
    if (missing.isNotEmpty) {
      SecureLogger.error('EnvValidator', 'Missing env vars: $missing');
    }
  }
}
