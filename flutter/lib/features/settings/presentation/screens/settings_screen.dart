import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/theme.dart';
import '../../domain/entities/settings.dart';
import '../../presentation/controllers/settings_controller.dart';
import '../../providers/settings_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _obscureOpenai = true;
  bool _obscureAnthropic = true;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final state = ref.watch(settingsControllerProvider);

    ref.listen<SettingsState>(settingsControllerProvider, (prev, next) {
      if (next.error != null && next.error != prev?.error && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: colorScheme.error,
          ),
        );
        ref.read(settingsControllerProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.raleway(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: state.status == SettingsStatus.loading && state.settings == null
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : state.status == SettingsStatus.error && state.settings == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 48, color: colorScheme.error),
                      SizedBox(height: AppSpacing.md),
                      Text(
                        state.error ?? 'Failed to load settings',
                        style: GoogleFonts.montserrat(color: colorScheme.error),
                      ),
                      SizedBox(height: AppSpacing.lg),
                      FilledButton(
                        onPressed: () =>
                            ref.read(settingsControllerProvider.notifier).loadSettings(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _buildSettingsContent(state, colorScheme),
    );
  }

  Widget _buildSettingsContent(SettingsState state, ColorScheme colorScheme) {
    final settings = state.settings;
    if (settings == null) return const SizedBox.shrink();

    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 600;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? screenWidth * 0.15 : AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionCard(
              colorScheme: colorScheme,
              title: 'Appearance',
              icon: Icons.palette_outlined,
              child: _buildThemeSelector(settings, colorScheme),
            ),
            SizedBox(height: AppSpacing.lg),
            _buildSectionCard(
              colorScheme: colorScheme,
              title: 'AI Provider',
              icon: Icons.smart_toy_outlined,
              child: _buildAiProviderSelector(settings, colorScheme),
            ),
            SizedBox(height: AppSpacing.lg),
            _buildSectionCard(
              colorScheme: colorScheme,
              title: 'API Keys',
              icon: Icons.key_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildApiKeyField(
                    label: 'OpenAI API Key',
                    value: settings.openaiApiKey ?? '',
                    obscure: _obscureOpenai,
                    onToggle: () =>
                        setState(() => _obscureOpenai = !_obscureOpenai),
                    colorScheme: colorScheme,
                    onChanged: (v) => ref
                        .read(settingsControllerProvider.notifier)
                        .updateSettings(settings.copyWith(openaiApiKey: v)),
                  ),
                  SizedBox(height: AppSpacing.md),
                  _buildApiKeyField(
                    label: 'Anthropic API Key',
                    value: settings.anthropicApiKey ?? '',
                    obscure: _obscureAnthropic,
                    onToggle: () =>
                        setState(() => _obscureAnthropic = !_obscureAnthropic),
                    colorScheme: colorScheme,
                    onChanged: (v) => ref
                        .read(settingsControllerProvider.notifier)
                        .updateSettings(settings.copyWith(anthropicApiKey: v)),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            if (settings.aiProvider.toLowerCase() == 'ollama')
              _buildSectionCard(
                colorScheme: colorScheme,
                title: 'Ollama',
                icon: Icons.dns_outlined,
                child: TextFormField(
                  initialValue: settings.ollamaBaseUrl ?? '',
                  decoration: InputDecoration(
                    labelText: 'Ollama Base URL',
                    hintText: 'http://localhost:11434',
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.borderRadiusMd,
                    ),
                  ),
                  style: GoogleFonts.montserrat(color: colorScheme.onSurface),
                  onFieldSubmitted: (v) => ref
                      .read(settingsControllerProvider.notifier)
                      .updateSettings(settings.copyWith(ollamaBaseUrl: v)),
                ),
              ),
            SizedBox(height: AppSpacing.xxl),
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: state.isSaving
                    ? null
                    : () => ref
                        .read(settingsControllerProvider.notifier)
                        .loadSettings(),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.borderRadiusMd,
                  ),
                ),
                child: state.isSaving
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onPrimary,
                        ),
                      )
                    : Text(
                        'Refresh',
                        style: GoogleFonts.raleway(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required ColorScheme colorScheme,
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.borderRadiusMd,
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: colorScheme.primary),
                SizedBox(width: AppSpacing.sm),
                Text(
                  title,
                  style: GoogleFonts.raleway(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.lg),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSelector(AppSettings settings, ColorScheme colorScheme) {
    final themes = ['system', 'light', 'dark'];
    final selected = settings.theme.toLowerCase();

    return SegmentedButton<String>(
      segments: themes
          .map((t) => ButtonSegment(
                value: t,
                label: Text(
                  t[0].toUpperCase() + t.substring(1),
                  style: GoogleFonts.montserrat(fontSize: 12),
                ),
                icon: Icon(
                  t == 'system'
                      ? Icons.settings_brightness
                      : t == 'light'
                          ? Icons.light_mode
                          : Icons.dark_mode,
                  size: 16,
                ),
              ))
          .toList(),
      selected: {selected},
      onSelectionChanged: (v) {
        ref.read(settingsControllerProvider.notifier).updateTheme(v.first);
      },
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: colorScheme.primaryContainer,
      ),
    );
  }

  Widget _buildAiProviderSelector(
      AppSettings settings, ColorScheme colorScheme) {
    final providers = ['openai', 'anthropic', 'ollama'];
    final selected = settings.aiProvider.toLowerCase();

    return DropdownButtonFormField<String>(
      initialValue: providers.contains(selected) ? selected : providers.first,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: AppRadius.borderRadiusMd,
        ),
      ),
      style: GoogleFonts.montserrat(color: colorScheme.onSurface),
      items: providers
          .map((p) => DropdownMenuItem(
                value: p,
                child: Text(
                  p[0].toUpperCase() + p.substring(1),
                  style: GoogleFonts.montserrat(color: colorScheme.onSurface),
                ),
              ))
          .toList(),
      onChanged: (v) {
        if (v != null) {
          ref.read(settingsControllerProvider.notifier).updateAiProvider(v);
        }
      },
    );
  }

  Widget _buildApiKeyField({
    required String label,
    required String value,
    required bool obscure,
    required VoidCallback onToggle,
    required ColorScheme colorScheme,
    required ValueChanged<String> onChanged,
  }) {
    return TextFormField(
      initialValue: value,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: AppRadius.borderRadiusMd,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          ),
          onPressed: onToggle,
        ),
      ),
      style: GoogleFonts.montserrat(color: colorScheme.onSurface),
      onFieldSubmitted: onChanged,
    );
  }
}
