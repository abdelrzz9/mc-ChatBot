import 'package:flutter_dotenv/flutter_dotenv.dart';

class EndPoints {
  static String get baseUrl => dotenv.env['BASE_URL']?.trim() ?? '';
}
