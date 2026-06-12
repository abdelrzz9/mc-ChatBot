import '../../../../core/network/dio_client.dart';

class SettingsRemoteDataSource {
  final DioClient _client;

  SettingsRemoteDataSource({required DioClient client}) : _client = client;

  Future<Map<String, dynamic>> getSettings() async {
    final response = await _client.get(
      '/api/v1/settings',
      requiresAuth: true,
    );
    return response.data as Map<String, dynamic>;
  }

  Future<void> updateSettings(Map<String, dynamic> data) async {
    await _client.put(
      '/api/v1/settings',
      data: data,
      requiresAuth: true,
    );
  }
}
