import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_remote_datasource.dart';
import '../models/settings_model.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsRemoteDataSource remoteDataSource;

  SettingsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, AppSettings>> getSettings() async {
    try {
      final data = await remoteDataSource.getSettings();
      final settings = SettingsModel.fromJson(data).toEntity();
      return Right(settings);
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> updateSettings(AppSettings settings) async {
    try {
      final model = SettingsModel.fromEntity(settings);
      await remoteDataSource.updateSettings(model.toJson());
      return const Right(null);
    } catch (e) {
      return Left(_mapErrorToFailure(e));
    }
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
