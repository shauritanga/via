import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/dependency_injection.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../documents/domain/entities/document.dart';
import '../../../documents/domain/entities/document_content.dart';
import '../../../documents/domain/usecases/get_document_content.dart';
import '../../domain/entities/voice_command.dart';
import '../../domain/usecases/read_document_content.dart';
import '../../domain/usecases/stop_speaking.dart';
import '../../../settings/presentation/providers/settings_providers.dart';

// Document reader state
enum DocumentReaderState { idle, loading, reading, paused, error }

class DocumentReaderData {
  final DocumentReaderState state;
  final Document? currentDocument;
  final DocumentContent? documentContent;
  final int currentPage;
  final String? currentSection;
  final ReadingMode readingMode;
  final ReadingPreferences? readingPreferences;
  final String? errorMessage;
  final bool isAutoScrollEnabled;
  final double readingProgress; // 0.0 to 1.0

  const DocumentReaderData({
    required this.state,
    this.currentDocument,
    this.documentContent,
    this.currentPage = 1,
    this.currentSection,
    this.readingMode = ReadingMode.fullDocument,
    this.readingPreferences,
    this.errorMessage,
    this.isAutoScrollEnabled = true,
    this.readingProgress = 0.0,
  });

  DocumentReaderData copyWith({
    DocumentReaderState? state,
    Document? currentDocument,
    DocumentContent? documentContent,
    int? currentPage,
    String? currentSection,
    ReadingMode? readingMode,
    ReadingPreferences? readingPreferences,
    String? errorMessage,
    bool? isAutoScrollEnabled,
    double? readingProgress,
  }) {
    return DocumentReaderData(
      state: state ?? this.state,
      currentDocument: currentDocument ?? this.currentDocument,
      documentContent: documentContent ?? this.documentContent,
      currentPage: currentPage ?? this.currentPage,
      currentSection: currentSection ?? this.currentSection,
      readingMode: readingMode ?? this.readingMode,
      readingPreferences: readingPreferences ?? this.readingPreferences,
      errorMessage: errorMessage ?? this.errorMessage,
      isAutoScrollEnabled: isAutoScrollEnabled ?? this.isAutoScrollEnabled,
      readingProgress: readingProgress ?? this.readingProgress,
    );
  }
}

// Document reader notifier
class DocumentReaderNotifier extends StateNotifier<DocumentReaderData> {
  final GetDocumentContent _getDocumentContent;
  final ReadDocumentContent _readDocumentContent;
  final StopSpeaking _stopSpeaking;
  final Ref _ref;

  DocumentReaderNotifier(
    this._getDocumentContent,
    this._readDocumentContent,
    this._stopSpeaking,
    this._ref,
  ) : super(const DocumentReaderData(state: DocumentReaderState.idle));

  Future<void> loadDocument(Document document) async {
    try {
      state = state.copyWith(
        state: DocumentReaderState.loading,
        currentDocument: document,
        errorMessage: null,
      );

      final result = await _getDocumentContent(
        GetDocumentContentParams(documentId: document.id),
      );

      result.fold(
        (failure) {
          state = state.copyWith(
            state: DocumentReaderState.error,
            errorMessage: failure.toString(),
          );
        },
        (content) {
          final currentLanguage = _ref.read(currentLanguageProvider);
          final defaultPreferences = ReadingPreferences(
            language: currentLanguage,
          );

          state = state.copyWith(
            state: DocumentReaderState.idle,
            documentContent: content,
            readingPreferences: defaultPreferences,
            currentPage: 1,
            readingProgress: 0.0,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        state: DocumentReaderState.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> startReading({
    ReadingMode? mode,
    int? pageNumber,
    String? sectionName,
    int? startPage,
    int? endPage,
  }) async {
    if (state.documentContent == null) return;

    try {
      state = state.copyWith(
        state: DocumentReaderState.reading,
        readingMode: mode ?? state.readingMode,
        currentPage: pageNumber ?? state.currentPage,
        currentSection: sectionName ?? state.currentSection,
        errorMessage: null,
      );

      final currentLanguage = _ref.read(currentLanguageProvider);
      final ttsSettings = await _ref.read(ttsSettingsProvider.future);

      final ttsSettingsConverted = TTSSettings(
        speechRate: ttsSettings.speechRate,
        pitch: ttsSettings.pitch,
        volume: ttsSettings.volume,
        language: currentLanguage,
        voice: ttsSettings.preferredVoice,
      );

      final result = await _readDocumentContent(
        ReadDocumentContentParams(
          documentContent: state.documentContent!,
          readingMode: state.readingMode,
          language: currentLanguage,
          ttsSettings: ttsSettingsConverted,
          readingPreferences: state.readingPreferences,
          pageNumber: state.currentPage,
          sectionName: state.currentSection,
          startPage: startPage,
          endPage: endPage,
        ),
      );

      result.fold(
        (failure) {
          state = state.copyWith(
            state: DocumentReaderState.error,
            errorMessage: failure.toString(),
          );
        },
        (_) {
          // Reading started successfully
          _startProgressTracking();
        },
      );
    } catch (e) {
      state = state.copyWith(
        state: DocumentReaderState.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> stopReading() async {
    try {
      final result = await _stopSpeaking(NoParams());

      result.fold(
        (failure) {
          state = state.copyWith(
            state: DocumentReaderState.error,
            errorMessage: failure.toString(),
          );
        },
        (_) {
          state = state.copyWith(
            state: DocumentReaderState.idle,
            readingProgress: 0.0,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        state: DocumentReaderState.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> pauseReading() async {
    if (state.state == DocumentReaderState.reading) {
      await stopReading();
      state = state.copyWith(state: DocumentReaderState.paused);
    }
  }

  Future<void> resumeReading() async {
    if (state.state == DocumentReaderState.paused) {
      await startReading();
    }
  }

  void goToPage(int pageNumber) {
    if (state.documentContent != null &&
        pageNumber > 0 &&
        pageNumber <= state.documentContent!.pages.length) {
      state = state.copyWith(currentPage: pageNumber);
    }
  }

  void nextPage() {
    if (state.documentContent != null &&
        state.currentPage < state.documentContent!.pages.length) {
      goToPage(state.currentPage + 1);
    }
  }

  void previousPage() {
    if (state.currentPage > 1) {
      goToPage(state.currentPage - 1);
    }
  }

  void setReadingMode(ReadingMode mode) {
    state = state.copyWith(readingMode: mode);
  }

  void updateReadingPreferences(ReadingPreferences preferences) {
    state = state.copyWith(readingPreferences: preferences);
  }

  void toggleAutoScroll() {
    state = state.copyWith(isAutoScrollEnabled: !state.isAutoScrollEnabled);
  }

  void clearError() {
    if (state.state == DocumentReaderState.error) {
      state = state.copyWith(
        state: DocumentReaderState.idle,
        errorMessage: null,
      );
    }
  }

  void _startProgressTracking() {
    // This would be implemented with a timer or stream
    // to track reading progress based on TTS callbacks
    // For now, we'll simulate progress
    Future.delayed(const Duration(seconds: 1), () {
      if (state.state == DocumentReaderState.reading) {
        // Update progress based on reading position
        // This is a simplified implementation
        final newProgress = (state.readingProgress + 0.1).clamp(0.0, 1.0);
        state = state.copyWith(readingProgress: newProgress);

        if (newProgress < 1.0) {
          _startProgressTracking();
        } else {
          // Reading completed
          state = state.copyWith(
            state: DocumentReaderState.idle,
            readingProgress: 0.0,
          );
        }
      }
    });
  }

  // Voice command handlers
  Future<void> handleVoiceCommand(VoiceCommand command) async {
    switch (command.type) {
      case VoiceCommandType.readDocument:
        await startReading();
        break;
      case VoiceCommandType.stopReading:
        await stopReading();
        break;
      case VoiceCommandType.pauseReading:
        await pauseReading();
        break;
      case VoiceCommandType.resumeReading:
        await resumeReading();
        break;
      case VoiceCommandType.nextPage:
        nextPage();
        if (state.state == DocumentReaderState.reading) {
          await startReading(mode: ReadingMode.currentPage);
        }
        break;
      case VoiceCommandType.previousPage:
        previousPage();
        if (state.state == DocumentReaderState.reading) {
          await startReading(mode: ReadingMode.currentPage);
        }
        break;
      case VoiceCommandType.goToPage:
        final pageNumber = command.parameters['pageNumber'] as int?;
        if (pageNumber != null) {
          goToPage(pageNumber);
          if (state.state == DocumentReaderState.reading) {
            await startReading(mode: ReadingMode.currentPage);
          }
        }
        break;
      case VoiceCommandType.readSection:
        final sectionName = command.parameters['sectionName'] as String?;
        if (sectionName != null) {
          await startReading(
            mode: ReadingMode.specificSection,
            sectionName: sectionName,
          );
        }
        break;
      default:
        // Handle other commands or ignore
        break;
    }
  }
}

// Providers
final documentReaderProvider =
    StateNotifierProvider<DocumentReaderNotifier, DocumentReaderData>((ref) {
      return DocumentReaderNotifier(
        sl<GetDocumentContent>(),
        sl<ReadDocumentContent>(),
        sl<StopSpeaking>(),
        ref,
      );
    });

final isReadingProvider = Provider<bool>((ref) {
  final readerState = ref.watch(documentReaderProvider);
  return readerState.state == DocumentReaderState.reading;
});

final currentDocumentProvider = Provider<Document?>((ref) {
  final readerState = ref.watch(documentReaderProvider);
  return readerState.currentDocument;
});

final currentPageProvider = Provider<int>((ref) {
  final readerState = ref.watch(documentReaderProvider);
  return readerState.currentPage;
});

final readingProgressProvider = Provider<double>((ref) {
  final readerState = ref.watch(documentReaderProvider);
  return readerState.readingProgress;
});

final totalPagesProvider = Provider<int>((ref) {
  final readerState = ref.watch(documentReaderProvider);
  return readerState.documentContent?.pages.length ?? 0;
});
