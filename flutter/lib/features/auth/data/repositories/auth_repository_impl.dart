import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/app_local_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AppLocalStorage localStorage;
  final DioClient dioClient;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localStorage,
    required this.dioClient,
  });

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      final data = await remoteDataSource.login(email, password);
      final userModel =
          UserModel.fromJson(data['user'] as Map<String, dynamic>);
      await saveTokens(
        data['accessToken'] as String,
        data['refreshToken'] as String,
      );
      return Right(userModel.toEntity());
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, User>> register(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      final data = await remoteDataSource.register(email, password, displayName);
      final userModel =
          UserModel.fromJson(data['user'] as Map<String, dynamic>);
      await saveTokens(
        data['accessToken'] as String,
        data['refreshToken'] as String,
      );
      return Right(userModel.toEntity());
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      await clearTokens();
      return const Right(null);
    } catch (e) {
      await clearTokens();
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, AuthTokens>> refreshToken(String token) async {
    try {
      final data = await remoteDataSource.refreshToken(token);
      final newAccessToken = data['accessToken'] as String;
      final newRefreshToken = data['refreshToken'] as String;
      await saveTokens(newAccessToken, newRefreshToken);
      return Right(AuthTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      ));
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = localStorage.getString('access_token');
    return token != null && token.isNotEmpty;
  }

  @override
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await localStorage.setString('access_token', accessToken);
    await localStorage.setSecureString('refresh_token', refreshToken);
  }

  @override
  Future<void> clearTokens() async {
    await localStorage.remove('access_token');
    await localStorage.removeSecure('refresh_token');
  }

  Failure _mapErrorToFailure(dynamic e) {
    if (e is DioException) {
      final message = (e.response?.data is Map)
          ? ((e.response?.data as Map)['message'] as String? ??
              e.message ?? 'Server error')
          : e.message ?? 'Server error';
      if (e.response?.statusCode == 401) {
        return UnauthorizedFailure(message: message);
      }
      return ServerFailure(message: message);
    }
    if (e is Failure) return e;
    return ServerFailure(message: e.toString());
  }
}
