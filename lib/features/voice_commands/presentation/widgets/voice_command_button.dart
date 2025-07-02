import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../providers/voice_command_providers.dart';

class VoiceCommandButton extends ConsumerWidget {
  final VoidCallback? onCommandReceived;
  final bool showText;
  final double size;

  const VoiceCommandButton({
    super.key,
    this.onCommandReceived,
    this.showText = true,
    this.size = 64.0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voiceState = ref.watch(voiceCommandProvider);
    final localizations = AppLocalizations.of(context);

    return Semantics(
      label: _getSemanticLabel(voiceState.state, localizations),
      hint: _getSemanticHint(voiceState.state, localizations),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated pulse effect for listening state
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: voiceState.state == VoiceCommandState.listening
                ? size + 16
                : size,
            height: voiceState.state == VoiceCommandState.listening
                ? size + 16
                : size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: voiceState.state == VoiceCommandState.listening
                  ? _getButtonColor(voiceState.state).withValues(alpha: 0.2)
                  : Colors.transparent,
            ),
            child: Center(
              child: GestureDetector(
                onTap: () => _handleTap(ref),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getButtonColor(voiceState.state),
                    boxShadow: [
                      BoxShadow(
                        color: _getButtonColor(
                          voiceState.state,
                        ).withValues(alpha: 0.4),
                        blurRadius:
                            voiceState.state == VoiceCommandState.listening
                            ? 12
                            : 8,
                        spreadRadius:
                            voiceState.state == VoiceCommandState.listening
                            ? 4
                            : 2,
                      ),
                    ],
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildButtonIcon(voiceState.state),
                  ),
                ),
              ),
            ),
          ),
          if (showText) ...[
            const SizedBox(height: 8),
            Text(
              _getButtonText(voiceState.state, localizations),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (voiceState.currentText != null) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  voiceState.currentText!,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            if (voiceState.errorMessage != null) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  voiceState.errorMessage!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  void _handleTap(WidgetRef ref) {
    final voiceNotifier = ref.read(voiceCommandProvider.notifier);
    final currentState = ref.read(voiceCommandProvider).state;

    switch (currentState) {
      case VoiceCommandState.idle:
        voiceNotifier.startListening();
        break;
      case VoiceCommandState.listening:
        voiceNotifier.stopListening();
        break;
      case VoiceCommandState.speaking:
        voiceNotifier.stopSpeaking();
        break;
      case VoiceCommandState.error:
        voiceNotifier.clearError();
        break;
      case VoiceCommandState.processing:
        // Do nothing while processing
        break;
    }
  }

  Widget _buildButtonIcon(VoiceCommandState state) {
    switch (state) {
      case VoiceCommandState.idle:
        return Icon(
          Icons.mic,
          size: size * 0.4,
          color: Colors.white,
          key: const ValueKey('mic'),
        );
      case VoiceCommandState.listening:
        return _PulsingMicIcon(
          size: size * 0.4,
          key: const ValueKey('mic_listening'),
        );
      case VoiceCommandState.processing:
        return SizedBox(
          width: size * 0.4,
          height: size * 0.4,
          child: const CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 3,
            key: ValueKey('processing'),
          ),
        );
      case VoiceCommandState.speaking:
        return _AnimatedSpeakerIcon(
          size: size * 0.4,
          key: const ValueKey('speaking'),
        );
      case VoiceCommandState.error:
        return Icon(
          Icons.error,
          size: size * 0.4,
          color: Colors.white,
          key: const ValueKey('error'),
        );
    }
  }

  Color _getButtonColor(VoiceCommandState state) {
    switch (state) {
      case VoiceCommandState.idle:
        return Colors.blue;
      case VoiceCommandState.listening:
        return Colors.red;
      case VoiceCommandState.processing:
        return Colors.orange;
      case VoiceCommandState.speaking:
        return Colors.green;
      case VoiceCommandState.error:
        return Colors.red.shade700;
    }
  }

  String _getButtonText(
    VoiceCommandState state,
    AppLocalizations localizations,
  ) {
    switch (state) {
      case VoiceCommandState.idle:
        return localizations.startListening;
      case VoiceCommandState.listening:
        return localizations.listening;
      case VoiceCommandState.processing:
        return 'Processing...';
      case VoiceCommandState.speaking:
        return 'Speaking...';
      case VoiceCommandState.error:
        return localizations.error;
    }
  }

  String _getSemanticLabel(
    VoiceCommandState state,
    AppLocalizations localizations,
  ) {
    switch (state) {
      case VoiceCommandState.idle:
        return localizations.startListening;
      case VoiceCommandState.listening:
        return localizations.stopListening;
      case VoiceCommandState.processing:
        return 'Processing voice command';
      case VoiceCommandState.speaking:
        return 'Speaking, tap to stop';
      case VoiceCommandState.error:
        return 'Error occurred, tap to retry';
    }
  }

  String _getSemanticHint(
    VoiceCommandState state,
    AppLocalizations localizations,
  ) {
    switch (state) {
      case VoiceCommandState.idle:
        return 'Tap to start voice recognition';
      case VoiceCommandState.listening:
        return 'Tap to stop listening';
      case VoiceCommandState.processing:
        return 'Please wait while processing';
      case VoiceCommandState.speaking:
        return 'Tap to stop speaking';
      case VoiceCommandState.error:
        return 'Tap to clear error and try again';
    }
  }
}

// Floating voice command button
class FloatingVoiceCommandButton extends ConsumerWidget {
  final VoidCallback? onCommandReceived;

  const FloatingVoiceCommandButton({super.key, this.onCommandReceived});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isListening = ref.watch(isListeningProvider);
    final isSpeaking = ref.watch(isSpeakingProvider);
    final hasError = ref.watch(hasVoiceErrorProvider);

    return FloatingActionButton(
      onPressed: () => _handlePress(ref),
      backgroundColor: _getBackgroundColor(isListening, isSpeaking, hasError),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _getIcon(isListening, isSpeaking, hasError),
      ),
    );
  }

  void _handlePress(WidgetRef ref) {
    final voiceNotifier = ref.read(voiceCommandProvider.notifier);
    final currentState = ref.read(voiceCommandProvider).state;

    switch (currentState) {
      case VoiceCommandState.idle:
        voiceNotifier.startListening();
        break;
      case VoiceCommandState.listening:
        voiceNotifier.stopListening();
        break;
      case VoiceCommandState.speaking:
        voiceNotifier.stopSpeaking();
        break;
      case VoiceCommandState.error:
        voiceNotifier.clearError();
        break;
      case VoiceCommandState.processing:
        // Do nothing while processing
        break;
    }
  }

  Color _getBackgroundColor(bool isListening, bool isSpeaking, bool hasError) {
    if (hasError) return Colors.red.shade700;
    if (isListening) return Colors.red;
    if (isSpeaking) return Colors.green;
    return Colors.blue;
  }

  Widget _getIcon(bool isListening, bool isSpeaking, bool hasError) {
    if (hasError) {
      return const Icon(Icons.error, key: ValueKey('error'));
    }
    if (isListening) {
      return const Icon(Icons.mic, key: ValueKey('listening'));
    }
    if (isSpeaking) {
      return const Icon(Icons.volume_up, key: ValueKey('speaking'));
    }
    return const Icon(Icons.mic, key: ValueKey('idle'));
  }
}

// Animated pulsing microphone icon for listening state
class _PulsingMicIcon extends StatefulWidget {
  final double size;

  const _PulsingMicIcon({super.key, required this.size});

  @override
  State<_PulsingMicIcon> createState() => _PulsingMicIconState();
}

class _PulsingMicIconState extends State<_PulsingMicIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Icon(Icons.mic, size: widget.size, color: Colors.white),
        );
      },
    );
  }
}

// Animated speaker icon for speaking state
class _AnimatedSpeakerIcon extends StatefulWidget {
  final double size;

  const _AnimatedSpeakerIcon({super.key, required this.size});

  @override
  State<_AnimatedSpeakerIcon> createState() => _AnimatedSpeakerIconState();
}

class _AnimatedSpeakerIconState extends State<_AnimatedSpeakerIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Icon(Icons.volume_up, size: widget.size, color: Colors.white),
        );
      },
    );
  }
}
