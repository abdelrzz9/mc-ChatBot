import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/user.dart';

class AuthTokens {
  final String accessToken;
  final String refreshToken;

  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
  });
}

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String email, String password);
  Future<Either<Failure, User>> register(
    String email,
    String password,
    String displayName,
  );
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, AuthTokens>> refreshToken(String token);
  Future<bool> isAuthenticated();
  Future<void> saveTokens(String accessToken, String refreshToken);
  Future<void> clearTokens();
}
