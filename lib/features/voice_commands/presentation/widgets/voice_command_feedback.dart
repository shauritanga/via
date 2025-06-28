import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../providers/voice_command_coordinator.dart';
import '../providers/voice_command_providers.dart';
import '../../../settings/presentation/providers/settings_providers.dart';

class VoiceCommandFeedback extends ConsumerWidget {
  final bool showAsOverlay;
  final bool showStatusText;

  const VoiceCommandFeedback({
    super.key,
    this.showAsOverlay = false,
    this.showStatusText = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coordinatorState = ref.watch(coordinatorStateProvider);
    final statusMessage = ref.watch(coordinatorStatusProvider);
    final errorMessage = ref.watch(coordinatorErrorProvider);
    final isAwaitingConfirmation = ref.watch(isAwaitingConfirmationProvider);
    final currentVoiceText = ref.watch(currentVoiceTextProvider);

    if (showAsOverlay) {
      return _buildOverlay(
        context,
        ref,
        coordinatorState,
        statusMessage,
        errorMessage,
        isAwaitingConfirmation,
        currentVoiceText,
      );
    }

    return _buildInlineWidget(
      context,
      ref,
      coordinatorState,
      statusMessage,
      errorMessage,
      isAwaitingConfirmation,
      currentVoiceText,
    );
  }

  Widget _buildOverlay(
    BuildContext context,
    WidgetRef ref,
    CoordinatorState coordinatorState,
    String? statusMessage,
    String? errorMessage,
    bool isAwaitingConfirmation,
    String? currentVoiceText,
  ) {
    if (coordinatorState == CoordinatorState.idle &&
        statusMessage == null &&
        errorMessage == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: _buildContent(
          context,
          ref,
          coordinatorState,
          statusMessage,
          errorMessage,
          isAwaitingConfirmation,
          currentVoiceText,
        ),
      ),
    );
  }

  Widget _buildInlineWidget(
    BuildContext context,
    WidgetRef ref,
    CoordinatorState coordinatorState,
    String? statusMessage,
    String? errorMessage,
    bool isAwaitingConfirmation,
    String? currentVoiceText,
  ) {
    return Card(
      child: _buildContent(
        context,
        ref,
        coordinatorState,
        statusMessage,
        errorMessage,
        isAwaitingConfirmation,
        currentVoiceText,
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    CoordinatorState coordinatorState,
    String? statusMessage,
    String? errorMessage,
    bool isAwaitingConfirmation,
    String? currentVoiceText,
  ) {
    final localizations = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status indicator
          Row(
            children: [
              _buildStatusIcon(coordinatorState),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getStatusTitle(coordinatorState, localizations),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (showStatusText &&
                        _getStatusDescription(
                              coordinatorState,
                              localizations,
                            ) !=
                            null)
                      Text(
                        _getStatusDescription(coordinatorState, localizations)!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
              if (coordinatorState != CoordinatorState.idle)
                _buildActionButton(
                  context,
                  ref,
                  coordinatorState,
                  isAwaitingConfirmation,
                ),
            ],
          ),

          // Current voice text
          if (currentVoiceText != null && currentVoiceText.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '"$currentVoiceText"',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
              ),
            ),
          ],

          // Status or error message
          if (statusMessage != null || errorMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: errorMessage != null
                    ? Theme.of(context).colorScheme.errorContainer
                    : Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                errorMessage ?? statusMessage!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: errorMessage != null
                      ? Theme.of(context).colorScheme.onErrorContainer
                      : Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],

          // Confirmation buttons
          if (isAwaitingConfirmation) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.close),
                  label: Text(localizations.cancel),
                  onPressed: () {
                    ref
                        .read(voiceCommandCoordinatorProvider.notifier)
                        .cancelPendingAction();
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: Text(localizations.ok),
                  onPressed: () {
                    ref
                        .read(voiceCommandCoordinatorProvider.notifier)
                        .confirmPendingAction();
                  },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusIcon(CoordinatorState state) {
    switch (state) {
      case CoordinatorState.idle:
        return Icon(Icons.mic_off, color: Colors.grey, size: 24);
      case CoordinatorState.listening:
        return Icon(Icons.mic, color: Colors.red, size: 24);
      case CoordinatorState.processing:
        return SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
        );
      case CoordinatorState.executing:
        return Icon(Icons.play_arrow, color: Colors.blue, size: 24);
      case CoordinatorState.speaking:
        return Icon(Icons.volume_up, color: Colors.green, size: 24);
      case CoordinatorState.waitingConfirmation:
        return Icon(Icons.help_outline, color: Colors.amber, size: 24);
      case CoordinatorState.error:
        return Icon(Icons.error, color: Colors.red, size: 24);
    }
  }

  String _getStatusTitle(
    CoordinatorState state,
    AppLocalizations localizations,
  ) {
    switch (state) {
      case CoordinatorState.idle:
        return 'Ready';
      case CoordinatorState.listening:
        return localizations.listening;
      case CoordinatorState.processing:
        return 'Processing...';
      case CoordinatorState.executing:
        return 'Executing...';
      case CoordinatorState.speaking:
        return 'Speaking...';
      case CoordinatorState.waitingConfirmation:
        return 'Confirmation Required';
      case CoordinatorState.error:
        return localizations.error;
    }
  }

  String? _getStatusDescription(
    CoordinatorState state,
    AppLocalizations localizations,
  ) {
    switch (state) {
      case CoordinatorState.idle:
        return 'Tap the microphone to start';
      case CoordinatorState.listening:
        return localizations.speakCommand;
      case CoordinatorState.processing:
        return 'Understanding your command...';
      case CoordinatorState.executing:
        return 'Performing the requested action...';
      case CoordinatorState.speaking:
        return 'Providing voice feedback...';
      case CoordinatorState.waitingConfirmation:
        return 'Please confirm the action';
      case CoordinatorState.error:
        return 'Something went wrong';
    }
  }

  Widget _buildActionButton(
    BuildContext context,
    WidgetRef ref,
    CoordinatorState state,
    bool isAwaitingConfirmation,
  ) {
    if (isAwaitingConfirmation) {
      return const SizedBox.shrink(); // Confirmation buttons are shown below
    }

    switch (state) {
      case CoordinatorState.listening:
        return IconButton(
          icon: const Icon(Icons.stop),
          onPressed: () {
            ref.read(voiceCommandProvider.notifier).stopListening();
          },
        );
      case CoordinatorState.speaking:
        return IconButton(
          icon: const Icon(Icons.volume_off),
          onPressed: () {
            ref.read(voiceCommandProvider.notifier).stopSpeaking();
          },
        );
      case CoordinatorState.error:
        return IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            ref.read(voiceCommandCoordinatorProvider.notifier).clearError();
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

// Floating voice command status
class FloatingVoiceStatus extends ConsumerWidget {
  const FloatingVoiceStatus({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coordinatorState = ref.watch(coordinatorStateProvider);
    final isListening = ref.watch(isListeningProvider);
    final isSpeaking = ref.watch(isSpeakingProvider);

    if (coordinatorState == CoordinatorState.idle &&
        !isListening &&
        !isSpeaking) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 100,
      left: 16,
      right: 16,
      child: VoiceCommandFeedback(showAsOverlay: true),
    );
  }
}

// Voice command help dialog
class VoiceCommandHelpDialog extends ConsumerWidget {
  const VoiceCommandHelpDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final currentLanguage = ref.watch(currentLanguageProvider);

    final commands = _getAvailableCommands(currentLanguage);

    return AlertDialog(
      title: Text(localizations.help),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available Voice Commands:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: commands.length,
                itemBuilder: (context, index) {
                  final command = commands[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.mic,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            command,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(localizations.ok),
        ),
      ],
    );
  }

  List<String> _getAvailableCommands(String language) {
    if (language == 'sw') {
      return [
        'Soma hati - Start reading the current document',
        'Fungua hati [jina] - Open a specific document',
        'Acha kusoma - Stop reading',
        'Simamisha kusoma - Pause reading',
        'Endelea kusoma - Resume reading',
        'Ukurasa unaofuata - Go to next page',
        'Ukurasa uliotangulia - Go to previous page',
        'Nenda ukurasa [nambari] - Go to specific page',
        'Soma sehemu [jina] - Read specific section',
        'Orodha ya hati - List all documents',
        'Badilisha lugha - Change language',
        'Mipangilio - Open settings',
        'Msaada - Show help',
      ];
    } else {
      return [
        'Read document - Start reading the current document',
        'Open document [name] - Open a specific document',
        'Stop reading - Stop reading',
        'Pause reading - Pause reading',
        'Resume reading - Resume reading',
        'Next page - Go to next page',
        'Previous page - Go to previous page',
        'Go to page [number] - Go to specific page',
        'Read section [name] - Read specific section',
        'List documents - List all documents',
        'Change language - Change language',
        'Settings - Open settings',
        'Help - Show help',
      ];
    }
  }

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const VoiceCommandHelpDialog(),
    );
  }
}
