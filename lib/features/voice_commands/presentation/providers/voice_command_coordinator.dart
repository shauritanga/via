import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/dependency_injection.dart';
import '../../domain/entities/voice_command.dart';
import '../../domain/usecases/process_voice_command.dart';
import '../../domain/usecases/speak_text.dart';
import '../../domain/usecases/read_document_content.dart';
import '../../../documents/domain/entities/document.dart';
import '../../../documents/presentation/providers/document_providers.dart';
import '../../../voice_commands/presentation/providers/document_reader_provider.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import 'voice_command_providers.dart';

// Voice command coordinator state
enum CoordinatorState {
  idle,
  listening,
  processing,
  executing,
  speaking,
  waitingConfirmation,
  error,
}

class VoiceCommandCoordinatorData {
  final CoordinatorState state;
  final VoiceCommand? lastCommand;
  final VoiceCommandResult? lastResult;
  final String? statusMessage;
  final String? errorMessage;
  final bool isAwaitingConfirmation;
  final VoiceCommandAction? pendingAction;
  final Map<String, dynamic>? pendingData;

  const VoiceCommandCoordinatorData({
    required this.state,
    this.lastCommand,
    this.lastResult,
    this.statusMessage,
    this.errorMessage,
    this.isAwaitingConfirmation = false,
    this.pendingAction,
    this.pendingData,
  });

  VoiceCommandCoordinatorData copyWith({
    CoordinatorState? state,
    VoiceCommand? lastCommand,
    VoiceCommandResult? lastResult,
    String? statusMessage,
    String? errorMessage,
    bool? isAwaitingConfirmation,
    VoiceCommandAction? pendingAction,
    Map<String, dynamic>? pendingData,
  }) {
    return VoiceCommandCoordinatorData(
      state: state ?? this.state,
      lastCommand: lastCommand ?? this.lastCommand,
      lastResult: lastResult ?? this.lastResult,
      statusMessage: statusMessage ?? this.statusMessage,
      errorMessage: errorMessage ?? this.errorMessage,
      isAwaitingConfirmation:
          isAwaitingConfirmation ?? this.isAwaitingConfirmation,
      pendingAction: pendingAction ?? this.pendingAction,
      pendingData: pendingData ?? this.pendingData,
    );
  }
}

// Voice command coordinator notifier
class VoiceCommandCoordinator
    extends StateNotifier<VoiceCommandCoordinatorData> {
  final ProcessVoiceCommand _processVoiceCommand;
  final SpeakText _speakText;
  final Ref _ref;

  VoiceCommandCoordinator(this._processVoiceCommand, this._speakText, this._ref)
    : super(const VoiceCommandCoordinatorData(state: CoordinatorState.idle)) {
    // Listen to voice command changes
    _ref.listen(lastVoiceCommandProvider, (previous, next) {
      if (next != null && next != previous) {
        handleVoiceCommand(next);
      }
    });
  }

  Future<void> handleVoiceCommand(VoiceCommand command) async {
    try {
      state = state.copyWith(
        state: CoordinatorState.processing,
        lastCommand: command,
        statusMessage: 'Processing command...',
        errorMessage: null,
      );

      // Get current context
      final currentDocument = _ref.read(selectedDocumentProvider);
      final currentPage = _ref.read(currentPageProvider);

      // Process the command
      final result = await _processVoiceCommand(
        ProcessVoiceCommandParams(
          voiceCommand: command,
          currentDocument: currentDocument,
          currentPage: currentPage,
        ),
      );

      result.fold(
        (failure) {
          state = state.copyWith(
            state: CoordinatorState.error,
            errorMessage: failure.toString(),
          );
        },
        (commandResult) async {
          state = state.copyWith(
            lastResult: commandResult,
            statusMessage: commandResult.message,
          );

          await _executeCommandResult(commandResult);
        },
      );
    } catch (e) {
      state = state.copyWith(
        state: CoordinatorState.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> _executeCommandResult(VoiceCommandResult result) async {
    switch (result.type) {
      case VoiceCommandResultType.action:
        if (result.requiresConfirmation) {
          await _requestConfirmation(result);
        } else {
          await _executeAction(result);
        }
        break;

      case VoiceCommandResultType.navigation:
        await _handleNavigation(result);
        break;

      case VoiceCommandResultType.speech:
        await _speakMessage(result.message);
        break;

      case VoiceCommandResultType.confirmation:
        await _requestConfirmation(result);
        break;

      case VoiceCommandResultType.error:
        await _handleError(result.message);
        break;
    }
  }

  Future<void> _executeAction(VoiceCommandResult result) async {
    if (result.action == null) return;

    state = state.copyWith(state: CoordinatorState.executing);

    try {
      switch (result.action!) {
        case VoiceCommandAction.readDocument:
          await _handleReadDocument(result);
          break;

        case VoiceCommandAction.openDocument:
          await _handleOpenDocument(result);
          break;

        case VoiceCommandAction.readSection:
          await _handleReadSection(result);
          break;

        case VoiceCommandAction.stopReading:
          await _handleStopReading();
          break;

        case VoiceCommandAction.pauseReading:
          await _handlePauseReading();
          break;

        case VoiceCommandAction.resumeReading:
          await _handleResumeReading();
          break;

        case VoiceCommandAction.nextPage:
          await _handleNextPage();
          break;

        case VoiceCommandAction.previousPage:
          await _handlePreviousPage();
          break;

        case VoiceCommandAction.goToPage:
          await _handleGoToPage(result);
          break;

        case VoiceCommandAction.deleteDocument:
          await _handleDeleteDocument(result);
          break;

        case VoiceCommandAction.changeLanguage:
          await _handleChangeLanguage(result);
          break;
      }

      // Speak confirmation message
      await _speakMessage(result.message);

      state = state.copyWith(state: CoordinatorState.idle);
    } catch (e) {
      state = state.copyWith(
        state: CoordinatorState.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> _handleReadDocument(VoiceCommandResult result) async {
    final document = result.data?['document'] as Document?;
    if (document != null) {
      // Set the selected document
      _ref.read(selectedDocumentProvider.notifier).state = document;

      // Load the document in the reader
      await _ref.read(documentReaderProvider.notifier).loadDocument(document);

      // Start reading
      await _ref.read(documentReaderProvider.notifier).startReading();
    }
  }

  Future<void> _handleOpenDocument(VoiceCommandResult result) async {
    final document = result.data?['document'] as Document?;
    if (document != null) {
      _ref.read(selectedDocumentProvider.notifier).state = document;
      await _ref.read(documentReaderProvider.notifier).loadDocument(document);
    }
  }

  Future<void> _handleReadSection(VoiceCommandResult result) async {
    final sectionName = result.data?['sectionName'] as String?;
    if (sectionName != null) {
      await _ref
          .read(documentReaderProvider.notifier)
          .startReading(
            mode: ReadingMode.specificSection,
            sectionName: sectionName,
          );
    }
  }

  Future<void> _handleStopReading() async {
    await _ref.read(documentReaderProvider.notifier).stopReading();
  }

  Future<void> _handlePauseReading() async {
    await _ref.read(documentReaderProvider.notifier).pauseReading();
  }

  Future<void> _handleResumeReading() async {
    await _ref.read(documentReaderProvider.notifier).resumeReading();
  }

  Future<void> _handleNextPage() async {
    _ref.read(documentReaderProvider.notifier).nextPage();
  }

  Future<void> _handlePreviousPage() async {
    _ref.read(documentReaderProvider.notifier).previousPage();
  }

  Future<void> _handleGoToPage(VoiceCommandResult result) async {
    final pageNumber = result.data?['pageNumber'] as int?;
    if (pageNumber != null) {
      _ref.read(documentReaderProvider.notifier).goToPage(pageNumber);
    }
  }

  Future<void> _handleDeleteDocument(VoiceCommandResult result) async {
    final document = result.data?['document'] as Document?;
    if (document != null) {
      await _ref
          .read(documentListProvider.notifier)
          .deleteDocument(document.id);
    }
  }

  Future<void> _handleChangeLanguage(VoiceCommandResult result) async {
    final language = result.data?['language'] as String?;
    if (language != null) {
      await _ref
          .read(currentLanguageProvider.notifier)
          .changeLanguage(language);
    }
  }

  Future<void> _handleNavigation(VoiceCommandResult result) async {
    // This would typically involve navigation using go_router
    // For now, we'll just speak the message
    await _speakMessage(result.message);
    state = state.copyWith(state: CoordinatorState.idle);
  }

  Future<void> _requestConfirmation(VoiceCommandResult result) async {
    state = state.copyWith(
      state: CoordinatorState.waitingConfirmation,
      isAwaitingConfirmation: true,
      pendingAction: result.action,
      pendingData: result.data,
    );

    await _speakMessage(result.message);
  }

  Future<void> confirmPendingAction() async {
    if (state.pendingAction != null) {
      final result = VoiceCommandResult.action(
        action: state.pendingAction!,
        message: 'Confirmed',
        data: state.pendingData,
      );

      state = state.copyWith(
        isAwaitingConfirmation: false,
        pendingAction: null,
        pendingData: null,
      );

      await _executeAction(result);
    }
  }

  Future<void> cancelPendingAction() async {
    state = state.copyWith(
      state: CoordinatorState.idle,
      isAwaitingConfirmation: false,
      pendingAction: null,
      pendingData: null,
    );

    await _speakMessage('Action cancelled');
  }

  Future<void> _handleError(String message) async {
    state = state.copyWith(
      state: CoordinatorState.error,
      errorMessage: message,
    );

    await _speakMessage(message);
  }

  Future<void> _speakMessage(String message) async {
    state = state.copyWith(state: CoordinatorState.speaking);

    final currentLanguage = _ref.read(currentLanguageProvider);

    final result = await _speakText(
      SpeakTextParams(text: message, language: currentLanguage),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          state: CoordinatorState.error,
          errorMessage: failure.toString(),
        );
      },
      (_) {
        // Speaking completed successfully
      },
    );
  }

  void clearError() {
    if (state.state == CoordinatorState.error) {
      state = state.copyWith(state: CoordinatorState.idle, errorMessage: null);
    }
  }

  void reset() {
    state = const VoiceCommandCoordinatorData(state: CoordinatorState.idle);
  }
}

// Provider
final voiceCommandCoordinatorProvider =
    StateNotifierProvider<VoiceCommandCoordinator, VoiceCommandCoordinatorData>(
      (ref) {
        return VoiceCommandCoordinator(
          sl<ProcessVoiceCommand>(),
          sl<SpeakText>(),
          ref,
        );
      },
    );

// Convenience providers
final coordinatorStateProvider = Provider<CoordinatorState>((ref) {
  return ref.watch(voiceCommandCoordinatorProvider).state;
});

final isProcessingCommandProvider = Provider<bool>((ref) {
  final state = ref.watch(coordinatorStateProvider);
  return state == CoordinatorState.processing ||
      state == CoordinatorState.executing;
});

final isAwaitingConfirmationProvider = Provider<bool>((ref) {
  return ref.watch(voiceCommandCoordinatorProvider).isAwaitingConfirmation;
});

final coordinatorStatusProvider = Provider<String?>((ref) {
  return ref.watch(voiceCommandCoordinatorProvider).statusMessage;
});

final coordinatorErrorProvider = Provider<String?>((ref) {
  return ref.watch(voiceCommandCoordinatorProvider).errorMessage;
});
