import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../providers/voice_command_coordinator.dart';
import '../providers/voice_command_providers.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../domain/entities/voice_command.dart';
import 'voice_command_button.dart';
import 'voice_command_feedback.dart';

class VoiceCommandIntegration extends ConsumerStatefulWidget {
  final Widget child;
  final bool showFloatingButton;
  final bool showStatusOverlay;
  final bool enableContinuousListening;

  const VoiceCommandIntegration({
    super.key,
    required this.child,
    this.showFloatingButton = true,
    this.showStatusOverlay = true,
    this.enableContinuousListening = false,
  });

  @override
  ConsumerState<VoiceCommandIntegration> createState() =>
      _VoiceCommandIntegrationState();
}

class _VoiceCommandIntegrationState
    extends ConsumerState<VoiceCommandIntegration>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize voice command system
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeVoiceCommands();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Handle app lifecycle changes for voice commands
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        // Stop listening when app goes to background
        ref.read(voiceCommandProvider.notifier).stopListening();
        ref.read(voiceCommandProvider.notifier).stopSpeaking();
        break;
      case AppLifecycleState.resumed:
        // Optionally restart continuous listening when app returns
        if (widget.enableContinuousListening) {
          _startContinuousListening();
        }
        break;
      default:
        break;
    }
  }

  void _initializeVoiceCommands() {
    // Set up any initial voice command configuration
    if (widget.enableContinuousListening) {
      _startContinuousListening();
    }
  }

  void _startContinuousListening() {
    // This would implement continuous listening with wake word detection
    // For now, we'll just provide the capability to start listening easily
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          widget.child,

          // Voice command status overlay
          if (widget.showStatusOverlay) const FloatingVoiceStatus(),

          // Error handling overlay
          Consumer(
            builder: (context, ref, child) {
              final errorMessage = ref.watch(coordinatorErrorProvider);

              if (errorMessage != null) {
                return _buildErrorOverlay(context, ref, errorMessage);
              }

              return const SizedBox.shrink();
            },
          ),
        ],
      ),

      // Floating voice command button
      floatingActionButton: widget.showFloatingButton
          ? const FloatingVoiceCommandButton()
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildErrorOverlay(
    BuildContext context,
    WidgetRef ref,
    String errorMessage,
  ) {
    return Positioned(
      bottom: 200,
      left: 16,
      right: 16,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.error,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  errorMessage,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
                onPressed: () {
                  ref
                      .read(voiceCommandCoordinatorProvider.notifier)
                      .clearError();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Voice command panel for settings or dedicated voice interface
class VoiceCommandPanel extends ConsumerWidget {
  final bool showAdvancedControls;

  const VoiceCommandPanel({super.key, this.showAdvancedControls = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.mic, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  localizations.voiceCommands,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.help_outline),
                  onPressed: () => VoiceCommandHelpDialog.show(context),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Main voice command button
            Center(child: VoiceCommandButton(size: 80, showText: true)),

            const SizedBox(height: 16),

            // Voice command feedback
            const VoiceCommandFeedback(showStatusText: true),

            if (showAdvancedControls) ...[
              const SizedBox(height: 16),
              _buildAdvancedControls(context, ref, localizations),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedControls(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations localizations,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildQuickActionChip(
              context,
              ref,
              icon: Icons.play_arrow,
              label: 'Read Document',
              onPressed: () {
                // Simulate voice command
                _simulateVoiceCommand(ref, 'read document');
              },
            ),
            _buildQuickActionChip(
              context,
              ref,
              icon: Icons.stop,
              label: 'Stop Reading',
              onPressed: () {
                _simulateVoiceCommand(ref, 'stop reading');
              },
            ),
            _buildQuickActionChip(
              context,
              ref,
              icon: Icons.skip_next,
              label: 'Next Page',
              onPressed: () {
                _simulateVoiceCommand(ref, 'next page');
              },
            ),
            _buildQuickActionChip(
              context,
              ref,
              icon: Icons.skip_previous,
              label: 'Previous Page',
              onPressed: () {
                _simulateVoiceCommand(ref, 'previous page');
              },
            ),
            _buildQuickActionChip(
              context,
              ref,
              icon: Icons.list,
              label: 'List Documents',
              onPressed: () {
                _simulateVoiceCommand(ref, 'list documents');
              },
            ),
            _buildQuickActionChip(
              context,
              ref,
              icon: Icons.language,
              label: 'Change Language',
              onPressed: () {
                _simulateVoiceCommand(ref, 'change language');
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionChip(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onPressed,
    );
  }

  void _simulateVoiceCommand(WidgetRef ref, String commandText) {
    // This simulates a voice command for testing/accessibility
    final currentLanguage = ref.read(currentLanguageProvider);

    // Create a mock voice command
    final mockCommand = VoiceCommand(
      command: commandText,
      type: _parseCommandType(commandText),
      parameters: {},
      language: currentLanguage,
      confidence: 1.0,
      timestamp: DateTime.now(),
    );

    // Process the command
    ref
        .read(voiceCommandCoordinatorProvider.notifier)
        .handleVoiceCommand(mockCommand);
  }

  VoiceCommandType _parseCommandType(String commandText) {
    final text = commandText.toLowerCase();

    if (text.contains('read document')) return VoiceCommandType.readDocument;
    if (text.contains('stop reading')) return VoiceCommandType.stopReading;
    if (text.contains('next page')) return VoiceCommandType.nextPage;
    if (text.contains('previous page')) return VoiceCommandType.previousPage;
    if (text.contains('list documents')) return VoiceCommandType.listDocuments;
    if (text.contains('change language')) {
      return VoiceCommandType.changeLanguage;
    }

    return VoiceCommandType.unknown;
  }
}

// Voice command accessibility wrapper
class VoiceCommandAccessibility extends ConsumerWidget {
  final Widget child;

  const VoiceCommandAccessibility({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Semantics(
      container: true,
      child: Consumer(
        builder: (context, ref, child) {
          final coordinatorState = ref.watch(coordinatorStateProvider);
          final statusMessage = ref.watch(coordinatorStatusProvider);

          return Semantics(
            liveRegion: true,
            label: _getAccessibilityLabel(coordinatorState, statusMessage),
            child: this.child,
          );
        },
      ),
    );
  }

  String _getAccessibilityLabel(CoordinatorState state, String? statusMessage) {
    switch (state) {
      case CoordinatorState.listening:
        return 'Voice command system is listening. Speak your command now.';
      case CoordinatorState.processing:
        return 'Processing voice command. Please wait.';
      case CoordinatorState.executing:
        return 'Executing voice command. ${statusMessage ?? ""}';
      case CoordinatorState.speaking:
        return 'Voice feedback is being provided.';
      case CoordinatorState.waitingConfirmation:
        return 'Confirmation required. ${statusMessage ?? ""}';
      case CoordinatorState.error:
        return 'Voice command error. ${statusMessage ?? ""}';
      default:
        return 'Voice command system is ready.';
    }
  }
}
