import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/settings.dart';

abstract class SettingsRepository {
  Future<Either<Failure, AppSettings>> getSettings();
  Future<Either<Failure, void>> updateSettings(AppSettings settings);
}
