import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../providers/settings_providers.dart';

class AccessibilitySettingsScreen extends ConsumerStatefulWidget {
  const AccessibilitySettingsScreen({super.key});

  @override
  ConsumerState<AccessibilitySettingsScreen> createState() =>
      _AccessibilitySettingsScreenState();
}

class _AccessibilitySettingsScreenState
    extends ConsumerState<AccessibilitySettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final accessibilitySettingsAsync = ref.watch(accessibilitySettingsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(localizations.accessibilitySettings)),
      body: accessibilitySettingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorView(context, error.toString()),
        data: (settings) =>
            _buildSettingsContent(context, ref, settings, localizations),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Failed to load accessibility settings',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(error, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildSettingsContent(
    BuildContext context,
    WidgetRef ref,
    dynamic settings,
    AppLocalizations localizations,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Visual settings
        _buildVisualSection(context, ref, settings, localizations),

        const SizedBox(height: 24),

        // Audio settings
        _buildAudioSection(context, ref, settings, localizations),

        const SizedBox(height: 24),

        // Interaction settings
        _buildInteractionSection(context, ref, settings, localizations),

        const SizedBox(height: 24),

        // Voice command settings
        _buildVoiceCommandSection(context, ref, settings, localizations),
      ],
    );
  }

  Widget _buildVisualSection(
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
              'Visual Settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // High contrast mode
            SwitchListTile(
              title: Text(localizations.highContrastMode),
              subtitle: const Text('Increase contrast for better visibility'),
              value: settings.highContrastMode,
              onChanged: (value) {
                final newSettings = settings.copyWith(highContrastMode: value);
                ref
                    .read(settingsNotifierProvider.notifier)
                    .updateAccessibilitySettings(newSettings);
              },
            ),

            const SizedBox(height: 16),

            // Text scale factor
            Text(
              localizations.textSize,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Slider(
              value: settings.textScaleFactor,
              min: 0.8,
              max: 2.0,
              divisions: 12,
              label: '${(settings.textScaleFactor * 100).round()}%',
              onChanged: (value) {
                final newSettings = settings.copyWith(textScaleFactor: value);
                ref
                    .read(settingsNotifierProvider.notifier)
                    .updateAccessibilitySettings(newSettings);
              },
            ),
            Text(
              'Current size: ${(settings.textScaleFactor * 100).round()}%',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioSection(
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
              'Audio Settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Voice feedback
            SwitchListTile(
              title: Text(localizations.voiceFeedback),
              subtitle: const Text('Provide audio feedback for actions'),
              value: settings.enableVoiceFeedback,
              onChanged: (value) {
                final newSettings = settings.copyWith(
                  enableVoiceFeedback: value,
                );
                ref
                    .read(settingsNotifierProvider.notifier)
                    .updateAccessibilitySettings(newSettings);
              },
            ),

            // Screen reader support
            SwitchListTile(
              title: const Text('Screen Reader Support'),
              subtitle: const Text(
                'Enhanced compatibility with screen readers',
              ),
              value: settings.enableScreenReader,
              onChanged: (value) {
                final newSettings = settings.copyWith(
                  enableScreenReader: value,
                );
                ref
                    .read(settingsNotifierProvider.notifier)
                    .updateAccessibilitySettings(newSettings);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractionSection(
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
              'Interaction Settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Haptic feedback
            SwitchListTile(
              title: Text(localizations.hapticFeedback),
              subtitle: const Text('Vibration feedback for interactions'),
              value: settings.enableHapticFeedback,
              onChanged: (value) {
                final newSettings = settings.copyWith(
                  enableHapticFeedback: value,
                );
                ref
                    .read(settingsNotifierProvider.notifier)
                    .updateAccessibilitySettings(newSettings);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceCommandSection(
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

            // Voice command timeout
            Text(
              'Voice Command Timeout',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Slider(
              value: settings.voiceCommandTimeout.toDouble(),
              min: 3000,
              max: 10000,
              divisions: 7,
              label: '${(settings.voiceCommandTimeout / 1000).round()}s',
              onChanged: (value) {
                final newSettings = settings.copyWith(
                  voiceCommandTimeout: value.round(),
                );
                ref
                    .read(settingsNotifierProvider.notifier)
                    .updateAccessibilitySettings(newSettings);
              },
            ),
            Text(
              'Timeout: ${(settings.voiceCommandTimeout / 1000).round()} seconds',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
