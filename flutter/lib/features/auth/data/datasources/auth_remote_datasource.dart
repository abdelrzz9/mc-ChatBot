import '../../../../core/network/dio_client.dart';

class AuthRemoteDataSource {
  final DioClient _client;

  AuthRemoteDataSource({required DioClient client}) : _client = client;

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _client.post(
      '/api/v1/auth/login',
      data: {'email': email, 'password': password},
      requiresAuth: false,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> register(
    String email,
    String password,
    String displayName,
  ) async {
    final response = await _client.post(
      '/api/v1/auth/register',
      data: {
        'email': email,
        'password': password,
        'display_name': displayName,
      },
      requiresAuth: false,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final response = await _client.post(
      '/api/v1/auth/refresh',
      data: {'refreshToken': refreshToken},
      requiresAuth: false,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<void> logout() async {
    await _client.post(
      '/api/v1/auth/logout',
      data: {},
      requiresAuth: true,
    );
  }
}
