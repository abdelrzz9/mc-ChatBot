class AppSettings {
  final String theme;
  final String aiProvider;
  final String? openaiApiKey;
  final String? anthropicApiKey;
  final String? ollamaBaseUrl;

  const AppSettings({
    required this.theme,
    required this.aiProvider,
    this.openaiApiKey,
    this.anthropicApiKey,
    this.ollamaBaseUrl,
  });

  AppSettings copyWith({
    String? theme,
    String? aiProvider,
    String? openaiApiKey,
    String? anthropicApiKey,
    String? ollamaBaseUrl,
  }) {
    return AppSettings(
      theme: theme ?? this.theme,
      aiProvider: aiProvider ?? this.aiProvider,
      openaiApiKey: openaiApiKey ?? this.openaiApiKey,
      anthropicApiKey: anthropicApiKey ?? this.anthropicApiKey,
      ollamaBaseUrl: ollamaBaseUrl ?? this.ollamaBaseUrl,
    );
  }
}
