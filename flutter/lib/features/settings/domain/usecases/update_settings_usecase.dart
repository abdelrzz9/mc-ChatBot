import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/settings.dart';
import '../repositories/settings_repository.dart';

class UpdateSettingsUseCase extends UseCase<void, UpdateSettingsParams> {
  final SettingsRepository repository;

  UpdateSettingsUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateSettingsParams params) async {
    return repository.updateSettings(params.settings);
  }
}

class UpdateSettingsParams extends Equatable {
  final AppSettings settings;

  const UpdateSettingsParams(this.settings);

  @override
  List<Object?> get props => [settings];
}
