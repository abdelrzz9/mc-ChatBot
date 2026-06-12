class ServerException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic error;

  const ServerException({
    this.message = 'Server Error',
    this.statusCode,
    this.error,
  });

  @override
  String toString() {
    return 'ServerException(message: $message, statusCode: $statusCode, error: $error)';
  }
}

class CacheException implements Exception {
  final String message;

  const CacheException({this.message = 'Cache Error'});

  @override
  String toString() => 'CacheException(message: $message)';
}
