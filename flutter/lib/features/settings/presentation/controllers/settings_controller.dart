import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failure_handler.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/settings.dart';
import '../../domain/usecases/get_settings_usecase.dart';
import '../../domain/usecases/update_settings_usecase.dart';

enum SettingsStatus { initial, loading, loaded, error }

class SettingsState {
  final SettingsStatus status;
  final AppSettings? settings;
  final String? error;
  final bool isSaving;

  const SettingsState({
    this.status = SettingsStatus.initial,
    this.settings,
    this.error,
    this.isSaving = false,
  });

  SettingsState copyWith({
    SettingsStatus? status,
    AppSettings? settings,
    String? error,
    bool? isSaving,
  }) {
    return SettingsState(
      status: status ?? this.status,
      settings: settings ?? this.settings,
      error: error,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class SettingsController extends StateNotifier<SettingsState> {
  final GetSettingsUseCase _getSettings;
  final UpdateSettingsUseCase _updateSettings;

  SettingsController({
    required GetSettingsUseCase getSettings,
    required UpdateSettingsUseCase updateSettings,
  })  : _getSettings = getSettings,
        _updateSettings = updateSettings,
        super(const SettingsState()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    state = state.copyWith(status: SettingsStatus.loading, error: null);
    final result = await _getSettings(NoParams());
    result.fold(
      (failure) {
        state = state.copyWith(
          status: SettingsStatus.error,
          error: FailureHandler.getUserFriendlyMessage(failure),
        );
      },
      (settings) {
        state = state.copyWith(
          status: SettingsStatus.loaded,
          settings: settings,
        );
      },
    );
  }

  Future<void> updateSettings(AppSettings settings) async {
    state = state.copyWith(isSaving: true, error: null);
    final result = await _updateSettings(UpdateSettingsParams(settings));
    result.fold(
      (failure) {
        state = state.copyWith(
          isSaving: false,
          error: FailureHandler.getUserFriendlyMessage(failure),
        );
      },
      (_) {
        state = state.copyWith(
          isSaving: false,
          status: SettingsStatus.loaded,
          settings: settings,
        );
      },
    );
  }

  void updateTheme(String theme) {
    final current = state.settings;
    if (current != null) {
      updateSettings(current.copyWith(theme: theme));
    }
  }

  void updateAiProvider(String provider) {
    final current = state.settings;
    if (current != null) {
      updateSettings(current.copyWith(aiProvider: provider));
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
