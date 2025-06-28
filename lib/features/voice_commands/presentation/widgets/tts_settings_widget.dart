import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:via/features/settings/presentation/providers/settings_providers.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../settings/domain/entities/app_settings.dart';
import '../../../settings/presentation/providers/settings_providers.dart'
    as settings;
import '../providers/voice_command_providers.dart';

class TTSSettingsWidget extends ConsumerStatefulWidget {
  final bool showAsDialog;

  const TTSSettingsWidget({super.key, this.showAsDialog = false});

  @override
  ConsumerState<TTSSettingsWidget> createState() => _TTSSettingsWidgetState();
}

class _TTSSettingsWidgetState extends ConsumerState<TTSSettingsWidget> {
  late double _speechRate;
  late double _pitch;
  late double _volume;
  late bool _enablePunctuation;
  late bool _enableEmphasis;
  String? _selectedVoice;

  @override
  void initState() {
    super.initState();
    _initializeSettings();
  }

  void _initializeSettings() {
    ref.read(settings.ttsSettingsProvider).whenData((ttsSettings) {
      setState(() {
        _speechRate = ttsSettings.speechRate;
        _pitch = ttsSettings.pitch;
        _volume = ttsSettings.volume;
        // Note: These properties might not exist in TTSSettings
        // _enablePunctuation = ttsSettings.enablePunctuation;
        // _enableEmphasis = ttsSettings.enableEmphasis;
        // _selectedVoice = ttsSettings.preferredVoice.isNotEmpty
        //     ? ttsSettings.preferredVoice
        //     : null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final ttsSettingsAsync = ref.watch(settings.ttsSettingsProvider);
    final availableVoicesAsync = ref.watch(availableVoicesProvider);

    return ttsSettingsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (settings) {
        if (widget.showAsDialog) {
          return _buildDialog(context, localizations, availableVoicesAsync);
        }
        return _buildContent(context, localizations, availableVoicesAsync);
      },
    );
  }

  Widget _buildDialog(
    BuildContext context,
    AppLocalizations localizations,
    AsyncValue<List<String>> availableVoicesAsync,
  ) {
    return AlertDialog(
      title: Text(localizations.speechSettings),
      content: SizedBox(
        width: double.maxFinite,
        child: _buildContent(context, localizations, availableVoicesAsync),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(localizations.cancel),
        ),
        TextButton(
          onPressed: () {
            _saveSettings();
            Navigator.of(context).pop();
          },
          child: Text(localizations.save),
        ),
      ],
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppLocalizations localizations,
    AsyncValue<List<String>> availableVoicesAsync,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Speech Rate
          _buildSliderSetting(
            title: localizations.speechRate,
            value: _speechRate,
            min: 0.1,
            max: 2.0,
            divisions: 19,
            onChanged: (value) => setState(() => _speechRate = value),
            valueFormatter: (value) => '${(value * 100).round()}%',
          ),

          const SizedBox(height: 16),

          // Pitch
          _buildSliderSetting(
            title: localizations.pitch,
            value: _pitch,
            min: 0.5,
            max: 2.0,
            divisions: 15,
            onChanged: (value) => setState(() => _pitch = value),
            valueFormatter: (value) => '${(value * 100).round()}%',
          ),

          const SizedBox(height: 16),

          // Volume
          _buildSliderSetting(
            title: localizations.volume,
            value: _volume,
            min: 0.0,
            max: 1.0,
            divisions: 10,
            onChanged: (value) => setState(() => _volume = value),
            valueFormatter: (value) => '${(value * 100).round()}%',
          ),

          const SizedBox(height: 16),

          // Voice Selection
          availableVoicesAsync.when(
            loading: () => const CircularProgressIndicator(),
            error: (error, stack) => Text('Error loading voices: $error'),
            data: (voices) => _buildVoiceSelector(localizations, voices),
          ),

          const SizedBox(height: 16),

          // Additional Options
          SwitchListTile(
            title: Text('Enable Punctuation Reading'),
            subtitle: Text('Read punctuation marks aloud'),
            value: _enablePunctuation,
            onChanged: (value) => setState(() => _enablePunctuation = value),
          ),

          SwitchListTile(
            title: Text('Enable Emphasis'),
            subtitle: Text('Add emphasis to important text'),
            value: _enableEmphasis,
            onChanged: (value) => setState(() => _enableEmphasis = value),
          ),

          const SizedBox(height: 16),

          // Test Button
          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: Text('Test Voice'),
              onPressed: _testVoice,
            ),
          ),

          if (!widget.showAsDialog) ...[
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _saveSettings,
                child: Text(localizations.save),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSliderSetting({
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    required String Function(double) valueFormatter,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            Text(
              valueFormatter(value),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildVoiceSelector(
    AppLocalizations localizations,
    List<String> voices,
  ) {
    if (voices.isEmpty) {
      return const Text('No voices available');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Voice', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedVoice,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Select a voice',
          ),
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('Default Voice'),
            ),
            ...voices.map(
              (voice) =>
                  DropdownMenuItem<String>(value: voice, child: Text(voice)),
            ),
          ],
          onChanged: (value) => setState(() => _selectedVoice = value),
        ),
      ],
    );
  }

  void _testVoice() {
    final currentLanguage = ref.read(settings.currentLanguageProvider);
    final testText = currentLanguage == 'sw'
        ? 'Hii ni jaribio la sauti. Je, unasikia vizuri?'
        : 'This is a voice test. Can you hear clearly?';

    ref.read(voiceCommandProvider.notifier).speakText(testText);
  }

  void _saveSettings() {
    final newSettings = TTSPreferences(
      speechRate: _speechRate,
      pitch: _pitch,
      volume: _volume,
      preferredVoice: _selectedVoice ?? '',
      enablePunctuation: _enablePunctuation,
      enableEmphasis: _enableEmphasis,
    );

    ref
        .read(settings.settingsNotifierProvider.notifier)
        .updateTtsSettings(newSettings);
  }
}

// Quick TTS controls for reading interface
class QuickTTSControls extends ConsumerWidget {
  const QuickTTSControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ttsSettingsAsync = ref.watch(settings.ttsSettingsProvider);

    return ttsSettingsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
      data: (settings) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Speed control
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.speed),
                onPressed: () => _showSpeedDialog(context, ref, settings),
              ),
              Text(
                '${(settings.speechRate * 100).round()}%',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),

          // Pitch control
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.tune),
                onPressed: () => _showPitchDialog(context, ref, settings),
              ),
              Text(
                '${(settings.pitch * 100).round()}%',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),

          // Volume control
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.volume_up),
                onPressed: () => _showVolumeDialog(context, ref, settings),
              ),
              Text(
                '${(settings.volume * 100).round()}%',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),

          // Settings
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => const TTSSettingsWidget(showAsDialog: true),
            ),
          ),
        ],
      ),
    );
  }

  void _showSpeedDialog(
    BuildContext context,
    WidgetRef ref,
    TTSPreferences settings,
  ) {
    showDialog(
      context: context,
      builder: (context) => _QuickSettingDialog(
        title: 'Speech Speed',
        value: settings.speechRate,
        min: 0.1,
        max: 2.0,
        onChanged: (value) {
          final newSettings = settings.copyWith(speechRate: value);
          ref
              .read(settingsNotifierProvider.notifier)
              .updateTtsSettings(newSettings);
        },
      ),
    );
  }

  void _showPitchDialog(
    BuildContext context,
    WidgetRef ref,
    TTSPreferences settings,
  ) {
    showDialog(
      context: context,
      builder: (context) => _QuickSettingDialog(
        title: 'Pitch',
        value: settings.pitch,
        min: 0.5,
        max: 2.0,
        onChanged: (value) {
          final newSettings = settings.copyWith(pitch: value);
          ref
              .read(settingsNotifierProvider.notifier)
              .updateTtsSettings(newSettings);
        },
      ),
    );
  }

  void _showVolumeDialog(
    BuildContext context,
    WidgetRef ref,
    TTSPreferences settings,
  ) {
    showDialog(
      context: context,
      builder: (context) => _QuickSettingDialog(
        title: 'Volume',
        value: settings.volume,
        min: 0.0,
        max: 1.0,
        onChanged: (value) {
          final newSettings = settings.copyWith(volume: value);
          ref
              .read(settingsNotifierProvider.notifier)
              .updateTtsSettings(newSettings);
        },
      ),
    );
  }
}

class _QuickSettingDialog extends StatefulWidget {
  final String title;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const _QuickSettingDialog({
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  State<_QuickSettingDialog> createState() => _QuickSettingDialogState();
}

class _QuickSettingDialogState extends State<_QuickSettingDialog> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${(_currentValue * 100).round()}%'),
          Slider(
            value: _currentValue,
            min: widget.min,
            max: widget.max,
            divisions: 20,
            onChanged: (value) => setState(() => _currentValue = value),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.onChanged(_currentValue);
            Navigator.of(context).pop();
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
