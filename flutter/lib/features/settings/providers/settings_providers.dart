import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../di/injection_container.dart' as di;
import '../domain/repositories/settings_repository.dart';
import '../domain/usecases/get_settings_usecase.dart';
import '../domain/usecases/update_settings_usecase.dart';
import '../presentation/controllers/settings_controller.dart';

final settingsControllerProvider =
    StateNotifierProvider<SettingsController, SettingsState>((ref) {
  return SettingsController(
    getSettings: GetSettingsUseCase(di.sl<SettingsRepository>()),
    updateSettings: UpdateSettingsUseCase(di.sl<SettingsRepository>()),
  );
});
