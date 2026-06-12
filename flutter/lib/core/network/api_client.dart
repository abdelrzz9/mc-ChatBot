import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../errors/failure.dart';
import 'network_info.dart';
import '../constants/end_points.dart';

class ApiClient {
  final http.Client _client;
  final NetworkInfo _networkInfo;

  String? _accessToken;

  ApiClient({http.Client? client, required NetworkInfo networkInfo})
    : _client = client ?? http.Client(),
      _networkInfo = networkInfo;

  String get baseUrl => EndPoints.baseUrl;

  void setAccessToken(String token) => _accessToken = token;
  void clearAccessToken() => _accessToken = null;

  String? get currentAccessToken => _accessToken;

  Future<Map<String, String>> _getHeaders({bool requiresAuth = false}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }

    try {
      final info = await PackageInfo.fromPlatform();
      headers['X-App-Version'] = '${info.version}+${info.buildNumber}';
    } catch (_) {}

    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        headers['X-Device-Info'] =
            '${androidInfo.brand}/${androidInfo.model}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        headers['X-Device-Info'] =
            '${iosInfo.name}/${iosInfo.model}';
      }
    } catch (_) {}

    return headers;
  }

  Future<void> checkConnection() async {
    if (!await _networkInfo.isConnected) {
      throw const NetworkFailure(message: 'No internet connection');
    }
  }

  Future<dynamic> get(String endpoint) async {
    await checkConnection();
    final response = await _client.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _getHeaders(),
    );
    return _handleResponse(response);
  }

  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) async {
    await checkConnection();
    final response = await _client.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _getHeaders(requiresAuth: requiresAuth),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<void> postVoid(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) async {
    await checkConnection();
    final response = await _client.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _getHeaders(requiresAuth: requiresAuth),
      body: body != null ? jsonEncode(body) : null,
    );
    _handleVoidResponse(response);
  }

  Future<void> delete(String endpoint) async {
    await checkConnection();
    final response = await _client.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _getHeaders(),
    );
    _handleVoidResponse(response);
  }

  void _handleVoidResponse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 204) return;
    switch (response.statusCode) {
      case 400:
      case 422:
        throw ServerFailure(message: _parseError(response));
      case 401:
        throw const UnauthorizedFailure(
          message: 'Session expired. Please log in again.',
        );
      case 403:
        throw const ServerFailure(message: 'Access denied.');
      case 404:
        throw const ServerFailure(message: 'Resource not found.');
      case 429:
        throw const ServerFailure(
          message: 'Too many attempts. Try again later.',
        );
      case 500:
        throw const ServerFailure(message: 'Server error. Try again later.');
      default:
        throw ServerFailure(message: _parseError(response));
    }
  }

  Future<void> postMultipart(
    String endpoint, {
    required List<File> files,
    required List<String> fieldNames,
    bool requiresAuth = false,
  }) async {
    await checkConnection();
    final uri = Uri.parse('$baseUrl$endpoint');
    final request = http.MultipartRequest('POST', uri);

    if (_accessToken != null) {
      request.headers['Authorization'] = 'Bearer $_accessToken';
    }

    try {
      final info = await PackageInfo.fromPlatform();
      request.headers['X-App-Version'] = '${info.version}+${info.buildNumber}';
    } catch (_) {}

    for (int i = 0; i < files.length; i++) {
      final file = files[i];
      final stream = http.ByteStream(file.openRead());
      final length = await file.length();
      final ext = file.path.split('.').last.toLowerCase();

      request.files.add(
        http.MultipartFile(
          fieldNames[i],
          stream,
          length,
          filename: file.path.split('/').last,
          contentType: MediaType(
            'image',
            _mimeTypeFromExtension(ext),
          ),
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 401) {
      throw const UnauthorizedFailure(
        message: 'Session expired. Please log in again.',
      );
    }

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw ServerFailure(
        message: 'Failed to upload photos. Please try again.',
      );
    }
  }

  String _mimeTypeFromExtension(String ext) {
    switch (ext) {
      case 'png':
        return 'png';
      case 'heic':
      case 'heif':
        return 'heic';
      case 'webp':
        return 'webp';
      default:
        return 'jpeg';
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    }
    switch (response.statusCode) {
      case 400:
      case 422:
        throw ServerFailure(message: _parseError(response));
      case 401:
        throw const UnauthorizedFailure(
          message: 'Session expired. Please log in again.',
        );
      case 403:
        throw const ServerFailure(message: 'Access denied.');
      case 404:
        throw const ServerFailure(message: 'Resource not found.');
      case 429:
        throw const ServerFailure(
          message: 'Too many attempts. Try again later.',
        );
      case 500:
        throw const ServerFailure(message: 'Server error. Try again later.');
      default:
        throw ServerFailure(message: _parseError(response));
    }
  }

  String _parseError(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return body['message'] as String? ??
          body['error'] as String? ??
          'Unknown server error';
    } catch (_) {
      return 'Server error ${response.statusCode}';
    }
  }
}
