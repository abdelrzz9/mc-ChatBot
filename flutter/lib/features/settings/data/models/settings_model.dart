import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/settings.dart';

part 'settings_model.freezed.dart';
part 'settings_model.g.dart';

@freezed
abstract class SettingsModel with _$SettingsModel {
  const factory SettingsModel({
    required String theme,
    @JsonKey(name: 'ai_provider') required String aiProvider,
    @JsonKey(name: 'openai_api_key') String? openaiApiKey,
    @JsonKey(name: 'anthropic_api_key') String? anthropicApiKey,
    @JsonKey(name: 'ollama_base_url') String? ollamaBaseUrl,
  }) = _SettingsModel;

  factory SettingsModel.fromJson(Map<String, dynamic> json) =>
      _$SettingsModelFromJson(json);

  const SettingsModel._();

  AppSettings toEntity() => AppSettings(
        theme: theme,
        aiProvider: aiProvider,
        openaiApiKey: openaiApiKey,
        anthropicApiKey: anthropicApiKey,
        ollamaBaseUrl: ollamaBaseUrl,
      );

  factory SettingsModel.fromEntity(AppSettings entity) => SettingsModel(
        theme: entity.theme,
        aiProvider: entity.aiProvider,
        openaiApiKey: entity.openaiApiKey,
        anthropicApiKey: entity.anthropicApiKey,
        ollamaBaseUrl: entity.ollamaBaseUrl,
      );


}
