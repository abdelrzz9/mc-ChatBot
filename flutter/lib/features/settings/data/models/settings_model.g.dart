// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SettingsModel _$SettingsModelFromJson(Map<String, dynamic> json) =>
    _SettingsModel(
      theme: json['theme'] as String,
      aiProvider: json['ai_provider'] as String,
      openaiApiKey: json['openai_api_key'] as String?,
      anthropicApiKey: json['anthropic_api_key'] as String?,
      ollamaBaseUrl: json['ollama_base_url'] as String?,
    );

Map<String, dynamic> _$SettingsModelToJson(_SettingsModel instance) =>
    <String, dynamic>{
      'theme': instance.theme,
      'ai_provider': instance.aiProvider,
      'openai_api_key': instance.openaiApiKey,
      'anthropic_api_key': instance.anthropicApiKey,
      'ollama_base_url': instance.ollamaBaseUrl,
    };
