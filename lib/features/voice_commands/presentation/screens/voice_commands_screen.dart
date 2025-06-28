import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../widgets/voice_command_integration.dart';
import '../widgets/tts_settings_widget.dart';
import '../providers/voice_command_providers.dart';

class VoiceCommandsScreen extends ConsumerWidget {
  const VoiceCommandsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final availableLanguagesAsync = ref.watch(availableLanguagesProvider);
    final availableVoicesAsync = ref.watch(availableVoicesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.voiceCommands),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(context, localizations),
            tooltip: localizations.help,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main voice command panel
            const VoiceCommandPanel(showAdvancedControls: true),

            const SizedBox(height: 24),

            // Voice system status
            _buildVoiceSystemStatus(context, ref, localizations),

            const SizedBox(height: 24),

            // Available languages
            availableLanguagesAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error: $error'),
              data: (languages) =>
                  _buildLanguageSection(context, languages, localizations),
            ),

            const SizedBox(height: 24),

            // Available voices
            availableVoicesAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error: $error'),
              data: (voices) =>
                  _buildVoicesSection(context, voices, localizations),
            ),

            const SizedBox(height: 24),

            // Quick TTS controls
            _buildQuickControlsSection(context, localizations),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceSystemStatus(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations localizations,
  ) {
    final isListening = ref.watch(isListeningProvider);
    final isSpeaking = ref.watch(isSpeakingProvider);
    final hasError = ref.watch(hasVoiceErrorProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Voice System Status',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatusIndicator(
                  context,
                  'Speech Recognition',
                  isListening ? 'Active' : 'Inactive',
                  isListening ? Colors.green : Colors.grey,
                  isListening ? Icons.mic : Icons.mic_off,
                ),
                const SizedBox(width: 24),
                _buildStatusIndicator(
                  context,
                  'Text-to-Speech',
                  isSpeaking ? 'Speaking' : 'Ready',
                  isSpeaking ? Colors.blue : Colors.grey,
                  isSpeaking ? Icons.volume_up : Icons.volume_off,
                ),
              ],
            ),
            if (hasError) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Voice system error detected',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(
    BuildContext context,
    String label,
    String status,
    Color color,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          status,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageSection(
    BuildContext context,
    List<String> languages,
    AppLocalizations localizations,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Supported Languages',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: languages.map((language) {
                final languageName = language == 'en' ? 'English' : 'Kiswahili';
                return Chip(
                  avatar: Icon(Icons.language, size: 16),
                  label: Text(languageName),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoicesSection(
    BuildContext context,
    List<String> voices,
    AppLocalizations localizations,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available Voices',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (voices.isEmpty)
              Text(
                'No voices available',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              Column(
                children: voices.take(5).map((voice) {
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.record_voice_over, size: 20),
                    title: Text(voice),
                    contentPadding: EdgeInsets.zero,
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickControlsSection(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick TTS Controls',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (context) =>
                    const TTSSettingsWidget(showAsDialog: true),
              ),
              child: const Text('Open TTS Settings'),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context, AppLocalizations localizations) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.help),
        content: const Text('Voice command help will be implemented here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
