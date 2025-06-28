import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../voice_commands/presentation/widgets/tts_settings_widget.dart';
import '../providers/settings_providers.dart';

class VoiceSettingsScreen extends ConsumerWidget {
  const VoiceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final voiceCommandSettingsAsync = ref.watch(voiceCommandSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(localizations.speechSettings)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TTS Settings
            const TTSSettingsWidget(showAsDialog: false),

            const SizedBox(height: 24),

            // Voice Command Settings
            voiceCommandSettingsAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) =>
                  _buildErrorView(context, error.toString()),
              data: (settings) => _buildVoiceCommandSettings(
                context,
                ref,
                settings,
                localizations,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String error) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 8),
            Text(
              'Failed to load voice command settings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(error, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceCommandSettings(
    BuildContext context,
    WidgetRef ref,
    dynamic settings,
    AppLocalizations localizations,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Voice Command Settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Continuous listening
            SwitchListTile(
              title: const Text('Continuous Listening'),
              subtitle: const Text('Keep listening for voice commands'),
              value: settings.enableContinuousListening,
              onChanged: (value) {
                final newSettings = settings.copyWith(
                  enableContinuousListening: value,
                );
                ref
                    .read(settingsNotifierProvider.notifier)
                    .updateVoiceCommandSettings(newSettings);
              },
            ),

            const SizedBox(height: 16),

            // Minimum confidence
            Text(
              'Recognition Confidence',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Slider(
              value: settings.minimumConfidence,
              min: 0.5,
              max: 1.0,
              divisions: 10,
              label: '${(settings.minimumConfidence * 100).round()}%',
              onChanged: (value) {
                final newSettings = settings.copyWith(minimumConfidence: value);
                ref
                    .read(settingsNotifierProvider.notifier)
                    .updateVoiceCommandSettings(newSettings);
              },
            ),
            Text(
              'Minimum confidence: ${(settings.minimumConfidence * 100).round()}%',
              style: Theme.of(context).textTheme.bodySmall,
            ),

            const SizedBox(height: 16),

            // Listening timeout
            Text(
              'Listening Timeout',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Slider(
              value: settings.listeningTimeout.toDouble(),
              min: 3000,
              max: 15000,
              divisions: 12,
              label: '${(settings.listeningTimeout / 1000).round()}s',
              onChanged: (value) {
                final newSettings = settings.copyWith(
                  listeningTimeout: value.round(),
                );
                ref
                    .read(settingsNotifierProvider.notifier)
                    .updateVoiceCommandSettings(newSettings);
              },
            ),
            Text(
              'Timeout: ${(settings.listeningTimeout / 1000).round()} seconds',
              style: Theme.of(context).textTheme.bodySmall,
            ),

            const SizedBox(height: 16),

            // Wake word
            SwitchListTile(
              title: const Text('Wake Word'),
              subtitle: Text('Say "${settings.wakeWord}" to activate'),
              value: settings.enableWakeWord,
              onChanged: (value) {
                final newSettings = settings.copyWith(enableWakeWord: value);
                ref
                    .read(settingsNotifierProvider.notifier)
                    .updateVoiceCommandSettings(newSettings);
              },
            ),

            // Voice confirmation
            SwitchListTile(
              title: const Text('Voice Confirmation'),
              subtitle: const Text('Speak confirmations for actions'),
              value: settings.enableVoiceConfirmation,
              onChanged: (value) {
                final newSettings = settings.copyWith(
                  enableVoiceConfirmation: value,
                );
                ref
                    .read(settingsNotifierProvider.notifier)
                    .updateVoiceCommandSettings(newSettings);
              },
            ),
          ],
        ),
      ),
    );
  }
}
