import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/config/app_config.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/app_local_storage.dart';
import '../../../../di/injection_container.dart';

class ChatRemoteDataSource {
  final DioClient _client;

  ChatRemoteDataSource({required DioClient client}) : _client = client;

  Future<List<dynamic>> getConversations() async {
    final response = await _client.get('/api/v1/conversations');
    return response.data['conversations'] as List<dynamic>;
  }

  Future<Map<String, dynamic>> createConversation(String title) async {
    final response = await _client.post(
      '/api/v1/conversations',
      data: {'title': title},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> renameConversation(
    String id,
    String title,
  ) async {
    final response = await _client.put(
      '/api/v1/conversations/$id',
      data: {'title': title},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<void> deleteConversation(String id) async {
    await _client.delete('/api/v1/conversations/$id');
  }

  Future<List<dynamic>> getMessages(String conversationId) async {
    final response = await _client.get(
      '/api/v1/conversations/$conversationId/messages',
    );
    return response.data['messages'] as List<dynamic>;
  }

  Stream<String> sendMessageStream(String conversationId, String content) async* {
    final client = http.Client();
    try {
      final request = http.Request(
        'POST',
        Uri.parse('${AppConfig.baseUrl}/api/v1/chat/send'),
      );
      request.headers['Content-Type'] = 'application/json';
      request.headers['Accept'] = 'text/event-stream';
      final token = sl<AppLocalStorage>().getString('access_token');
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.body = jsonEncode({
        'conversation_id': conversationId,
        'content': content,
      });

      final response = await client.send(request);

      await for (final chunk in response.stream.transform(utf8.decoder)) {
        for (final line in chunk.split('\n')) {
          if (line.startsWith('data: ')) {
            final data = line.substring(6).trim();
            if (data == '[DONE]') return;
            if (data.isEmpty) continue;
            try {
              final json = jsonDecode(data) as Map<String, dynamic>;
              if (json['token'] != null) {
                yield json['token'] as String;
              } else if (json['error'] != null) {
                throw Exception(json['error']);
              }
            } catch (_) {
              rethrow;
            }
          }
        }
      }
    } finally {
      client.close();
    }
  }
}
