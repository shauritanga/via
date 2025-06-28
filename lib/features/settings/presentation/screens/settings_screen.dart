import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../shared/widgets/language_selector.dart';
import '../../../../core/navigation/app_router.dart';
import '../providers/settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final appSettingsAsync = ref.watch(appSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(localizations.settings)),
      body: appSettingsAsync.when(
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
            'Failed to load settings',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(error, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Trigger a refresh
            },
            child: const Text('Retry'),
          ),
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
        // Language settings
        _buildLanguageSection(context, localizations),

        const SizedBox(height: 24),

        // Voice settings
        _buildVoiceSection(context, localizations),

        const SizedBox(height: 24),

        // Accessibility settings
        _buildAccessibilitySection(context, localizations),

        const SizedBox(height: 24),

        // App information
        _buildAppInfoSection(context, localizations),
      ],
    );
  }

  Widget _buildLanguageSection(
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
              localizations.language,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            const VoiceLanguageSelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceSection(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.record_voice_over),
            title: Text(localizations.speechSettings),
            subtitle: const Text('Configure text-to-speech and voice commands'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => context.go('${AppRoutes.settings}/voice'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.mic),
            title: Text(localizations.voiceCommands),
            subtitle: const Text('Voice command settings and help'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => context.go(AppRoutes.voiceCommands),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessibilitySection(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.accessibility_new),
        title: Text(localizations.accessibilitySettings),
        subtitle: const Text(
          'High contrast, text size, and other accessibility options',
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => context.go('${AppRoutes.settings}/accessibility'),
      ),
    );
  }

  Widget _buildAppInfoSection(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(localizations.about),
            subtitle: const Text('App version and information'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _showAboutDialog(context, localizations),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: Text(localizations.help),
            subtitle: const Text('User guide and support'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => context.go(AppRoutes.help),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context, AppLocalizations localizations) {
    showAboutDialog(
      context: context,
      applicationName: 'VIA',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.mic, size: 48),
      children: [
        const Text(
          'Voice Interactive Assistant (VIA) is an accessible PDF reading app '
          'that uses voice commands and text-to-speech to help users interact '
          'with documents hands-free.',
        ),
        const SizedBox(height: 16),
        const Text(
          'Features:\n'
          '• Voice-controlled PDF reading\n'
          '• Multi-language support (English & Swahili)\n'
          '• Accessibility-first design\n'
          '• Offline document storage\n'
          '• Customizable speech settings',
        ),
      ],
    );
  }
}
