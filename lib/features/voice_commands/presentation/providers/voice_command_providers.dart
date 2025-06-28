import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/dependency_injection.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/voice_command.dart';
import '../../domain/repositories/voice_repository.dart';
import '../../domain/usecases/start_listening.dart';
import '../../domain/usecases/stop_listening.dart';
import '../../domain/usecases/speak_text.dart';
import '../../domain/usecases/stop_speaking.dart';
import '../../../settings/domain/repositories/settings_repository.dart';
import '../../../settings/presentation/providers/settings_providers.dart';

// Voice command state
enum VoiceCommandState { idle, listening, processing, speaking, error }

class VoiceCommandStateData {
  final VoiceCommandState state;
  final String? currentText;
  final VoiceCommand? lastCommand;
  final String? errorMessage;
  final double? soundLevel;

  const VoiceCommandStateData({
    required this.state,
    this.currentText,
    this.lastCommand,
    this.errorMessage,
    this.soundLevel,
  });

  VoiceCommandStateData copyWith({
    VoiceCommandState? state,
    String? currentText,
    VoiceCommand? lastCommand,
    String? errorMessage,
    double? soundLevel,
  }) {
    return VoiceCommandStateData(
      state: state ?? this.state,
      currentText: currentText ?? this.currentText,
      lastCommand: lastCommand ?? this.lastCommand,
      errorMessage: errorMessage ?? this.errorMessage,
      soundLevel: soundLevel ?? this.soundLevel,
    );
  }
}

// Voice command notifier
class VoiceCommandNotifier extends StateNotifier<VoiceCommandStateData> {
  final StartListening _startListening;
  final StopListening _stopListening;
  final SpeakText _speakText;
  final StopSpeaking _stopSpeaking;
  final Ref _ref;

  VoiceCommandNotifier(
    this._startListening,
    this._stopListening,
    this._speakText,
    this._stopSpeaking,
    this._ref,
  ) : super(const VoiceCommandStateData(state: VoiceCommandState.idle));

  Future<void> startListening() async {
    if (state.state == VoiceCommandState.listening) return;

    try {
      state = state.copyWith(
        state: VoiceCommandState.listening,
        errorMessage: null,
      );

      final currentLanguage = _ref.read(currentLanguageProvider);

      final result = await _startListening(
        StartListeningParams(
          language: currentLanguage,
          onResult: _onSpeechResult,
          onError: _onSpeechError,
        ),
      );

      result.fold(
        (failure) {
          state = state.copyWith(
            state: VoiceCommandState.error,
            errorMessage: failure.toString(),
          );
        },
        (_) {
          // Successfully started listening
        },
      );
    } catch (e) {
      state = state.copyWith(
        state: VoiceCommandState.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> stopListening() async {
    if (state.state != VoiceCommandState.listening) return;

    try {
      final result = await _stopListening(NoParams());

      result.fold(
        (failure) {
          state = state.copyWith(
            state: VoiceCommandState.error,
            errorMessage: failure.toString(),
          );
        },
        (_) {
          state = state.copyWith(
            state: VoiceCommandState.idle,
            currentText: null,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        state: VoiceCommandState.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> speakText(String text, {TTSSettings? settings}) async {
    try {
      state = state.copyWith(
        state: VoiceCommandState.speaking,
        currentText: text,
        errorMessage: null,
      );

      final currentLanguage = _ref.read(currentLanguageProvider);

      final result = await _speakText(
        SpeakTextParams(
          text: text,
          language: currentLanguage,
          settings: settings,
        ),
      );

      result.fold(
        (failure) {
          state = state.copyWith(
            state: VoiceCommandState.error,
            errorMessage: failure.toString(),
          );
        },
        (_) {
          // Speaking started successfully
          // State will be updated when speaking completes
        },
      );
    } catch (e) {
      state = state.copyWith(
        state: VoiceCommandState.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> stopSpeaking() async {
    if (state.state != VoiceCommandState.speaking) return;

    try {
      final result = await _stopSpeaking(NoParams());

      result.fold(
        (failure) {
          state = state.copyWith(
            state: VoiceCommandState.error,
            errorMessage: failure.toString(),
          );
        },
        (_) {
          state = state.copyWith(
            state: VoiceCommandState.idle,
            currentText: null,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        state: VoiceCommandState.error,
        errorMessage: e.toString(),
      );
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    state = state.copyWith(currentText: result.recognizedText);

    if (result.isFinal) {
      state = state.copyWith(state: VoiceCommandState.processing);

      _processCommand(result);
    }
  }

  void _onSpeechError(String error) {
    state = state.copyWith(state: VoiceCommandState.error, errorMessage: error);
  }

  Future<void> _processCommand(SpeechRecognitionResult result) async {
    try {
      // Parse the command using the voice repository
      final voiceRepository = sl<VoiceRepository>();
      final commandResult = await voiceRepository.parseVoiceCommand(
        recognizedText: result.recognizedText,
        language: result.language,
        confidence: result.confidence,
      );

      commandResult.fold(
        (failure) {
          state = state.copyWith(
            state: VoiceCommandState.error,
            errorMessage: failure.toString(),
          );
        },
        (command) {
          state = state.copyWith(
            state: VoiceCommandState.idle,
            lastCommand: command,
            currentText: null,
          );

          // Notify listeners about the new command
          _ref.read(lastVoiceCommandProvider.notifier).state = command;
        },
      );
    } catch (e) {
      state = state.copyWith(
        state: VoiceCommandState.error,
        errorMessage: e.toString(),
      );
    }
  }

  void clearError() {
    if (state.state == VoiceCommandState.error) {
      state = state.copyWith(state: VoiceCommandState.idle, errorMessage: null);
    }
  }

  void reset() {
    state = const VoiceCommandStateData(state: VoiceCommandState.idle);
  }
}

// Providers
final voiceCommandProvider =
    StateNotifierProvider<VoiceCommandNotifier, VoiceCommandStateData>((ref) {
      return VoiceCommandNotifier(
        sl<StartListening>(),
        sl<StopListening>(),
        sl<SpeakText>(),
        sl<StopSpeaking>(),
        ref,
      );
    });

final lastVoiceCommandProvider = StateProvider<VoiceCommand?>((ref) => null);

final isListeningProvider = Provider<bool>((ref) {
  final voiceState = ref.watch(voiceCommandProvider);
  return voiceState.state == VoiceCommandState.listening;
});

final isSpeakingProvider = Provider<bool>((ref) {
  final voiceState = ref.watch(voiceCommandProvider);
  return voiceState.state == VoiceCommandState.speaking;
});

final hasVoiceErrorProvider = Provider<bool>((ref) {
  final voiceState = ref.watch(voiceCommandProvider);
  return voiceState.state == VoiceCommandState.error;
});

final currentVoiceTextProvider = Provider<String?>((ref) {
  final voiceState = ref.watch(voiceCommandProvider);
  return voiceState.currentText;
});

final voiceErrorMessageProvider = Provider<String?>((ref) {
  final voiceState = ref.watch(voiceCommandProvider);
  return voiceState.errorMessage;
});

// TTS Settings provider
final ttsSettingsProvider = FutureProvider<TTSSettings>((ref) async {
  final settingsRepository = sl<SettingsRepository>();
  final result = await settingsRepository.getTtsSettings();

  return result.fold(
    (failure) => const TTSSettings(
      speechRate: 0.5,
      pitch: 1.0,
      volume: 1.0,
      language: 'en',
      voice: '',
    ),
    (settings) => TTSSettings(
      speechRate: settings.speechRate,
      pitch: settings.pitch,
      volume: settings.volume,
      language: ref.read(currentLanguageProvider),
      voice: settings.preferredVoice,
    ),
  );
});

// Available voices provider
final availableVoicesProvider = FutureProvider<List<String>>((ref) async {
  final voiceRepository = sl<VoiceRepository>();
  final currentLanguage = ref.watch(currentLanguageProvider);

  final result = await voiceRepository.getAvailableVoices(currentLanguage);

  return result.fold((failure) => <String>[], (voices) => voices);
});

// Available languages provider
final availableLanguagesProvider = FutureProvider<List<String>>((ref) async {
  final voiceRepository = sl<VoiceRepository>();

  final result = await voiceRepository.getAvailableLanguages();

  return result.fold((failure) => ['en'], (languages) => languages);
});
