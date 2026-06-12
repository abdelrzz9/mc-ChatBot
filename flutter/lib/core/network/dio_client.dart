import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../errors/failure.dart';
import '../config/app_config.dart';

class DioClient {
  late final Dio _dio;
  final DioClientAuth _authInterceptor;
  final DioClientError _errorInterceptor;

  String? Function()? getAccessToken;
  Future<String?> Function()? onTokenRefresh;
  void Function()? onUnauthorized;

  DioClient({
    this.getAccessToken,
    this.onTokenRefresh,
    this.onUnauthorized,
    Duration connectTimeout = const Duration(seconds: 15),
    Duration receiveTimeout = const Duration(seconds: 15),
  })  : _authInterceptor = DioClientAuth(),
        _errorInterceptor = DioClientError() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      _authInterceptor,
      _errorInterceptor,
      if (kDebugMode)
        LogInterceptor(
          request: true,
          responseBody: true,
          error: true,
          requestHeader: false,
          responseHeader: false,
          logPrint: (obj) {
            final message = obj.toString();
            if (message.contains('Authorization') ||
                message.contains('Bearer ')) {
              return;
            }
            debugPrint('[DIO] $obj');
          },
        ),
    ]);
  }

  Future<Response<dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  }) async {
    return _executeWithAuth(
      () => _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: _buildOptions(requiresAuth),
      ),
      requiresAuth,
    );
  }

  Future<Response<dynamic>> post(
    String endpoint, {
    dynamic data,
    bool requiresAuth = false,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _executeWithAuth(
      () => _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: _buildOptions(requiresAuth),
      ),
      requiresAuth,
    );
  }

  Future<Response<dynamic>> put(
    String endpoint, {
    dynamic data,
    bool requiresAuth = true,
  }) async {
    return _executeWithAuth(
      () => _dio.put(
        endpoint,
        data: data,
        options: _buildOptions(requiresAuth),
      ),
      requiresAuth,
    );
  }

  Future<Response<dynamic>> delete(
    String endpoint, {
    bool requiresAuth = true,
  }) async {
    return _executeWithAuth(
      () => _dio.delete(
        endpoint,
        options: _buildOptions(requiresAuth),
      ),
      requiresAuth,
    );
  }

  Future<Response<dynamic>> postMultipart(
    String endpoint, {
    required List<Map<String, dynamic>> files,
    bool requiresAuth = true,
  }) async {
    return _executeWithAuth(() async {
      final formData = FormData();
      for (final file in files) {
        formData.files.add(
          MapEntry(
            file['field'] as String,
            await MultipartFile.fromFile(
              file['path'] as String,
              filename: file['filename'] as String?,
            ),
          ),
        );
      }
      return _dio.post(
        endpoint,
        data: formData,
        options: _buildOptions(requiresAuth),
      );
    }, requiresAuth);
  }

  Options _buildOptions(bool requiresAuth) {
    final headers = <String, String>{};
    if (requiresAuth && getAccessToken != null) {
      final token = getAccessToken!();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return Options(headers: headers);
  }

  Future<Response<dynamic>> _executeWithAuth(
    Future<Response<dynamic>> Function() request,
    bool requiresAuth,
  ) async {
    try {
      if (requiresAuth && getAccessToken != null) {
        final token = getAccessToken!();
        if (token == null && onTokenRefresh != null) {
          final newToken = await onTokenRefresh!();
          if (newToken == null) {
            onUnauthorized?.call();
            throw const UnauthorizedFailure(message: 'Session expired');
          }
        }
      }
      return await request();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 && requiresAuth) {
        if (onTokenRefresh != null) {
          try {
            final newToken = await onTokenRefresh!();
            if (newToken != null) {
              return await request();
            }
          } catch (_) {}
        }
        onUnauthorized?.call();
        throw const UnauthorizedFailure(message: 'Session expired. Please log in again.');
      }
      rethrow;
    }
  }

  void updateBaseUrl(String url) {
    _dio.options.baseUrl = url;
  }

  void dispose() {
    _dio.close();
  }
}

class DioClientAuth extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    handler.next(options);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    handler.next(err);
  }
}

class DioClientError extends Interceptor {
  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    handler.next(err);
  }
}
