import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:via/features/voice_commands/domain/entities/voice_command.dart'
    as stt;
import '../../../../core/errors/failures.dart';
import '../../domain/entities/voice_command.dart';
import '../../../../core/constants/app_constants.dart';

abstract class SpeechRecognitionDataSource {
  Future<void> initialize();
  Future<bool> requestPermissions();
  Future<void> startListening({
    required String language,
    required Function(SpeechRecognitionResult) onResult,
    required Function(String) onError,
  });
  Future<void> stopListening();
  Future<bool> isListening();
  Future<List<String>> getAvailableLanguages();
  Future<bool> isAvailable();
}

class SpeechRecognitionDataSourceImpl implements SpeechRecognitionDataSource {
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isInitialized = false;
  StreamSubscription<stt.SpeechRecognitionResult>? _resultSubscription;

  @override
  Future<void> initialize() async {
    try {
      if (!_isInitialized) {
        _isInitialized = await _speechToText.initialize(
          onError: (error) {
            // Log error - in production, use a proper logging framework
            // print('Speech recognition error: ${error.errorMsg}');
          },
          onStatus: (status) {
            // Log status - in production, use a proper logging framework
            // print('Speech recognition status: $status');
          },
        );

        if (!_isInitialized) {
          throw const SpeechRecognitionFailure(
            'Failed to initialize speech recognition',
          );
        }
      }
    } catch (e) {
      throw SpeechRecognitionFailure(
        'Failed to initialize speech recognition: $e',
      );
    }
  }

  @override
  Future<bool> requestPermissions() async {
    try {
      final microphoneStatus = await Permission.microphone.request();
      final speechStatus = await Permission.speech.request();

      return microphoneStatus.isGranted && speechStatus.isGranted;
    } catch (e) {
      throw PermissionFailure('Failed to request permissions: $e');
    }
  }

  @override
  Future<void> startListening({
    required String language,
    required Function(SpeechRecognitionResult) onResult,
    required Function(String) onError,
  }) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      final hasPermission = await requestPermissions();
      if (!hasPermission) {
        throw const PermissionFailure('Microphone permission not granted');
      }

      if (!await isAvailable()) {
        throw const SpeechRecognitionFailure(
          'Speech recognition not available',
        );
      }

      // Stop any existing listening session
      if (await isListening()) {
        await stopListening();
      }

      // Map language codes to speech_to_text locale identifiers
      final localeId = _getLocaleId(language);

      await _speechToText.listen(
        onResult: (result) {
          final speechResult = SpeechRecognitionResult(
            recognizedText: result.recognizedWords,
            confidence: result.confidence,
            isFinal: result.finalResult,
            language: language,
            timestamp: DateTime.now(),
          );
          onResult(speechResult);
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        localeId: localeId,
        onSoundLevelChange: (level) {
          // Handle sound level changes if needed
        },
        listenOptions: stt.SpeechListenOptions(
          partialResults: true,
          cancelOnError: true,
          listenMode: stt.ListenMode.confirmation,
        ),
      );
    } catch (e) {
      if (e is Failure) {
        onError(e.toString());
        rethrow;
      }
      final failure = SpeechRecognitionFailure('Failed to start listening: $e');
      onError(failure.toString());
      throw failure;
    }
  }

  @override
  Future<void> stopListening() async {
    try {
      if (_isInitialized && await isListening()) {
        await _speechToText.stop();
      }
    } catch (e) {
      throw SpeechRecognitionFailure('Failed to stop listening: $e');
    }
  }

  @override
  Future<bool> isListening() async {
    try {
      return _speechToText.isListening;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<String>> getAvailableLanguages() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      final locales = await _speechToText.locales();
      final supportedLanguages = <String>[];

      // Check for English locales
      final englishLocales = locales.where(
        (locale) =>
            locale.localeId.startsWith('en_') || locale.localeId == 'en',
      );
      if (englishLocales.isNotEmpty) {
        supportedLanguages.add(AppConstants.englishLocale);
      }

      // Check for Swahili locales
      final swahiliLocales = locales.where(
        (locale) =>
            locale.localeId.startsWith('sw_') || locale.localeId == 'sw',
      );
      if (swahiliLocales.isNotEmpty) {
        supportedLanguages.add(AppConstants.swahiliLocale);
      }

      // If no specific locales found, add defaults
      if (supportedLanguages.isEmpty) {
        supportedLanguages.add(AppConstants.englishLocale);
      }

      return supportedLanguages;
    } catch (e) {
      // Return default languages if error occurs
      return [AppConstants.englishLocale];
    }
  }

  @override
  Future<bool> isAvailable() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }
      return _speechToText.isAvailable;
    } catch (e) {
      return false;
    }
  }

  String _getLocaleId(String languageCode) {
    switch (languageCode) {
      case AppConstants.englishLocale:
        return 'en_US'; // Default to US English
      case AppConstants.swahiliLocale:
        return 'sw_KE'; // Swahili (Kenya) - most common variant
      default:
        return 'en_US';
    }
  }

  void dispose() {
    _resultSubscription?.cancel();
  }
}

// Mock implementation for testing
class MockSpeechRecognitionDataSource implements SpeechRecognitionDataSource {
  bool _isListening = false;
  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _isInitialized = true;
  }

  @override
  Future<bool> requestPermissions() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return true;
  }

  @override
  Future<void> startListening({
    required String language,
    required Function(SpeechRecognitionResult) onResult,
    required Function(String) onError,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _isListening = true;

    // Simulate recognition after a delay
    Future.delayed(const Duration(seconds: 2), () {
      if (_isListening) {
        final result = SpeechRecognitionResult(
          recognizedText: 'read document',
          confidence: 0.95,
          isFinal: true,
          language: language,
          timestamp: DateTime.now(),
        );
        onResult(result);
      }
    });
  }

  @override
  Future<void> stopListening() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _isListening = false;
  }

  @override
  Future<bool> isListening() async {
    return _isListening;
  }

  @override
  Future<List<String>> getAvailableLanguages() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return [AppConstants.englishLocale, AppConstants.swahiliLocale];
  }

  @override
  Future<bool> isAvailable() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _isInitialized;
  }
}
