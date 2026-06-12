import 'failure.dart';
import '../security/secure_logger.dart';

class FailureHandler {
  FailureHandler._();

  static String getUserFriendlyMessage(Failure failure) {
    if (failure is NetworkFailure) {
      return 'Unable to connect. Please check your internet connection.';
    }

    if (failure is UnauthorizedFailure) {
      return 'Your session has expired. Please sign in again.';
    }

    if (failure is ServerFailure) {
      return _getServerErrorMessage(failure);
    }

    if (failure is CacheFailure) {
      return 'Something went wrong. Please try again.';
    }

    if (failure is CancelledFailure) {
      return '';
    }

    if (failure is FileNotFoundFailure) {
      return failure.message;
    }

    if (failure is FileTooLargeFailure) {
      return failure.message;
    }

    if (failure is InvalidFileFormatFailure) {
      return failure.message;
    }

    return 'An unexpected error occurred. Please try again.';
  }

  static String _getServerErrorMessage(ServerFailure failure) {
    final message = failure.message;

    final userFriendly = <String, String>{
      'Access denied': 'You do not have permission to perform this action.',
      'Resource not found': 'The requested resource was not found.',
      'Too many attempts': 'Too many attempts. Please try again later.',
      'Server error': 'A server error occurred. Please try again later.',
      'not found': 'The requested resource was not found.',
    };

    for (final entry in userFriendly.entries) {
      if (message.toLowerCase().contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }

    return message.isNotEmpty ? message : 'A server error occurred. Please try again later.';
  }

  static void logFailure(Failure failure, String source) {
    SecureLogger.error(
      source,
      'Failure: ${failure.runtimeType} - ${failure.message}',
    );
  }
}
