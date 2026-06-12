import '../../../../core/network/dio_client.dart';

class DocumentRemoteDataSource {
  final DioClient _client;

  DocumentRemoteDataSource({required DioClient client}) : _client = client;

  Future<List<dynamic>> getDocuments() async {
    final response = await _client.get('/api/v1/documents');
    return response.data['documents'] as List<dynamic>;
  }

  Future<Map<String, dynamic>> uploadDocument(
    String filePath,
    String fileName,
  ) async {
    final response = await _client.postMultipart(
      '/api/v1/documents/upload',
      files: [
        {'field': 'file', 'path': filePath, 'filename': fileName},
      ],
    );
    return response.data as Map<String, dynamic>;
  }

  Future<void> deleteDocument(String id) async {
    await _client.delete('/api/v1/documents/$id');
  }

  Future<void> reindexDocument(String id) async {
    await _client.post('/api/v1/documents/$id/reindex');
  }
}
