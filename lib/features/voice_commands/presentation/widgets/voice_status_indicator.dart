import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../providers/voice_command_providers.dart';
import '../providers/voice_command_coordinator.dart';

/// A comprehensive status indicator that shows voice command feedback
class VoiceStatusIndicator extends ConsumerWidget {
  final bool showAsOverlay;
  final EdgeInsets? padding;

  const VoiceStatusIndicator({
    super.key,
    this.showAsOverlay = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voiceState = ref.watch(voiceCommandProvider);
    final coordinatorState = ref.watch(voiceCommandCoordinatorProvider);
    final localizations = AppLocalizations.of(context);

    // Don't show anything if idle and no recent activity
    if (voiceState.state == VoiceCommandState.idle &&
        coordinatorState.state == CoordinatorState.idle &&
        voiceState.lastCommand == null) {
      return const SizedBox.shrink();
    }

    final content = _buildStatusContent(
      context,
      voiceState,
      coordinatorState,
      localizations,
    );

    if (showAsOverlay) {
      return Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        child: content,
      );
    }

    return Padding(
      padding: padding ?? const EdgeInsets.all(16),
      child: content,
    );
  }

  Widget _buildStatusContent(
    BuildContext context,
    VoiceCommandStateData voiceState,
    VoiceCommandCoordinatorData coordinatorState,
    AppLocalizations localizations,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _getBackgroundColor(voiceState.state, coordinatorState.state),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStatusIcon(voiceState.state, coordinatorState.state),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getStatusTitle(
                    voiceState.state,
                    coordinatorState.state,
                    localizations,
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                if (_getStatusSubtitle(
                      voiceState,
                      coordinatorState,
                      localizations,
                    ) !=
                    null) ...[
                  const SizedBox(height: 2),
                  Text(
                    _getStatusSubtitle(
                      voiceState,
                      coordinatorState,
                      localizations,
                    )!,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (voiceState.state == VoiceCommandState.listening &&
              voiceState.soundLevel != null) ...[
            const SizedBox(width: 8),
            _buildSoundLevelIndicator(voiceState.soundLevel!),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusIcon(
    VoiceCommandState voiceState,
    CoordinatorState coordinatorState,
  ) {
    // Prioritize coordinator state for more specific feedback
    if (coordinatorState == CoordinatorState.processing) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
      );
    }

    if (coordinatorState == CoordinatorState.executing) {
      return const Icon(Icons.play_arrow, color: Colors.white, size: 20);
    }

    switch (voiceState) {
      case VoiceCommandState.listening:
        return const _PulsingIcon(
          icon: Icons.mic,
          color: Colors.white,
          size: 20,
        );
      case VoiceCommandState.processing:
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        );
      case VoiceCommandState.speaking:
        return const _PulsingIcon(
          icon: Icons.volume_up,
          color: Colors.white,
          size: 20,
        );
      case VoiceCommandState.error:
        return const Icon(Icons.error_outline, color: Colors.white, size: 20);
      case VoiceCommandState.idle:
        return const Icon(
          Icons.check_circle_outline,
          color: Colors.white,
          size: 20,
        );
    }
  }

  Widget _buildSoundLevelIndicator(double soundLevel) {
    return Container(
      width: 24,
      height: 20,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: LinearProgressIndicator(
          value: soundLevel.clamp(0.0, 1.0),
          backgroundColor: Colors.transparent,
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }

  Color _getBackgroundColor(
    VoiceCommandState voiceState,
    CoordinatorState coordinatorState,
  ) {
    if (coordinatorState == CoordinatorState.error ||
        voiceState == VoiceCommandState.error) {
      return Colors.red.shade600;
    }
    if (voiceState == VoiceCommandState.listening) {
      return Colors.red.shade500;
    }
    if (voiceState == VoiceCommandState.speaking ||
        coordinatorState == CoordinatorState.speaking) {
      return Colors.green.shade600;
    }
    if (voiceState == VoiceCommandState.processing ||
        coordinatorState == CoordinatorState.processing ||
        coordinatorState == CoordinatorState.executing) {
      return Colors.blue.shade600;
    }
    return Colors.grey.shade600;
  }

  String _getStatusTitle(
    VoiceCommandState voiceState,
    CoordinatorState coordinatorState,
    AppLocalizations localizations,
  ) {
    // Prioritize coordinator state
    switch (coordinatorState) {
      case CoordinatorState.processing:
        return 'Processing command...'; // TODO: Add to localizations
      case CoordinatorState.executing:
        return 'Executing command...'; // TODO: Add to localizations
      case CoordinatorState.speaking:
        return 'Speaking...'; // TODO: Add to localizations
      case CoordinatorState.waitingConfirmation:
        return 'Waiting for confirmation...'; // TODO: Add to localizations
      case CoordinatorState.error:
        return localizations.error;
      case CoordinatorState.idle:
      case CoordinatorState.listening:
        break;
    }

    // Fall back to voice state
    switch (voiceState) {
      case VoiceCommandState.listening:
        return localizations.listening;
      case VoiceCommandState.processing:
        return 'Processing...'; // TODO: Add to localizations
      case VoiceCommandState.speaking:
        return 'Speaking...'; // TODO: Add to localizations
      case VoiceCommandState.error:
        return localizations.error;
      case VoiceCommandState.idle:
        return 'Ready'; // TODO: Add to localizations
    }
  }

  String? _getStatusSubtitle(
    VoiceCommandStateData voiceState,
    VoiceCommandCoordinatorData coordinatorState,
    AppLocalizations localizations,
  ) {
    // Show error messages
    if (voiceState.errorMessage != null) {
      return voiceState.errorMessage;
    }
    if (coordinatorState.errorMessage != null) {
      return coordinatorState.errorMessage;
    }

    // Show status messages
    if (coordinatorState.statusMessage != null) {
      return coordinatorState.statusMessage;
    }

    // Show current text being processed
    if (voiceState.currentText != null && voiceState.currentText!.isNotEmpty) {
      return '"${voiceState.currentText}"';
    }

    // Show last command result
    if (voiceState.lastCommand != null) {
      return 'Command executed'; // TODO: Add to localizations
    }

    return null;
  }
}

// Simple pulsing icon widget
class _PulsingIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final double size;

  const _PulsingIcon({
    required this.icon,
    required this.color,
    required this.size,
  });

  @override
  State<_PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<_PulsingIcon>
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
      begin: 0.7,
      end: 1.0,
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
        return Opacity(
          opacity: _animation.value,
          child: Icon(widget.icon, color: widget.color, size: widget.size),
        );
      },
    );
  }
}
