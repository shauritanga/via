import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/voice_command.dart';
import '../../../../core/constants/app_constants.dart';

abstract class TextToSpeechDataSource {
  Future<void> initialize();
  Future<void> speakText({
    required String text,
    required String language,
    TTSSettings? settings,
  });
  Future<void> stop();
  Future<bool> isSpeaking();
  Future<List<String>> getAvailableVoices(String language);
  Future<void> setLanguage(String language);
  Future<void> setSpeechRate(double rate);
  Future<void> setPitch(double pitch);
  Future<void> setVolume(double volume);
  Future<void> setVoice(String voice);
}

class TextToSpeechDataSourceImpl implements TextToSpeechDataSource {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  String _currentLanguage = AppConstants.englishLocale;
  
  final Completer<void> _initCompleter = Completer<void>();

  @override
  Future<void> initialize() async {
    try {
      if (!_isInitialized) {
        // Configure TTS settings
        await _flutterTts.setSharedInstance(true);
        
        // Set default values
        await _flutterTts.setSpeechRate(AppConstants.defaultSpeechRate);
        await _flutterTts.setPitch(AppConstants.defaultPitch);
        await _flutterTts.setVolume(AppConstants.defaultVolume);
        
        // Set default language
        await setLanguage(AppConstants.englishLocale);
        
        // Set up event handlers
        _flutterTts.setStartHandler(() {
          print('TTS: Speech started');
        });
        
        _flutterTts.setCompletionHandler(() {
          print('TTS: Speech completed');
        });
        
        _flutterTts.setErrorHandler((msg) {
          print('TTS Error: $msg');
        });
        
        _flutterTts.setCancelHandler(() {
          print('TTS: Speech cancelled');
        });
        
        _flutterTts.setPauseHandler(() {
          print('TTS: Speech paused');
        });
        
        _flutterTts.setContinueHandler(() {
          print('TTS: Speech continued');
        });

        _isInitialized = true;
        if (!_initCompleter.isCompleted) {
          _initCompleter.complete();
        }
      }
    } catch (e) {
      if (!_initCompleter.isCompleted) {
        _initCompleter.completeError(TextToSpeechFailure('Failed to initialize TTS: $e'));
      }
      throw TextToSpeechFailure('Failed to initialize TTS: $e');
    }
  }

  @override
  Future<void> speakText({
    required String text,
    required String language,
    TTSSettings? settings,
  }) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      // Wait for initialization to complete
      await _initCompleter.future;

      // Apply settings if provided
      if (settings != null) {
        await _applySettings(settings);
      }

      // Set language if different from current
      if (language != _currentLanguage) {
        await setLanguage(language);
      }

      // Stop any current speech
      if (await isSpeaking()) {
        await stop();
      }

      // Speak the text
      final result = await _flutterTts.speak(text);
      
      if (result == 0) {
        // Success
        print('TTS: Started speaking: ${text.substring(0, text.length > 50 ? 50 : text.length)}...');
      } else {
        throw TextToSpeechFailure('Failed to start speaking: result code $result');
      }
    } catch (e) {
      if (e is Failure) rethrow;
      throw TextToSpeechFailure('Failed to speak text: $e');
    }
  }

  @override
  Future<void> stop() async {
    try {
      if (_isInitialized) {
        await _flutterTts.stop();
      }
    } catch (e) {
      throw TextToSpeechFailure('Failed to stop TTS: $e');
    }
  }

  @override
  Future<bool> isSpeaking() async {
    try {
      if (!_isInitialized) {
        return false;
      }
      
      // Note: FlutterTts doesn't have a direct isSpeaking method
      // We'll need to track this state ourselves or use platform-specific implementations
      return false; // Placeholder - would need platform-specific implementation
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<String>> getAvailableVoices(String language) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      await _initCompleter.future;

      final voices = await _flutterTts.getVoices;
      if (voices == null) return [];

      final languageCode = _getLanguageCode(language);
      final filteredVoices = <String>[];

      for (final voice in voices) {
        if (voice is Map<String, dynamic>) {
          final voiceLanguage = voice['locale'] as String?;
          final voiceName = voice['name'] as String?;
          
          if (voiceLanguage != null && 
              voiceName != null && 
              voiceLanguage.startsWith(languageCode)) {
            filteredVoices.add(voiceName);
          }
        }
      }

      return filteredVoices;
    } catch (e) {
      print('Error getting voices: $e');
      return [];
    }
  }

  @override
  Future<void> setLanguage(String language) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      await _initCompleter.future;

      final languageCode = _getLanguageCode(language);
      await _flutterTts.setLanguage(languageCode);
      _currentLanguage = language;
    } catch (e) {
      throw TextToSpeechFailure('Failed to set language: $e');
    }
  }

  @override
  Future<void> setSpeechRate(double rate) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      await _initCompleter.future;

      // Clamp rate between 0.1 and 2.0
      final clampedRate = rate.clamp(0.1, 2.0);
      await _flutterTts.setSpeechRate(clampedRate);
    } catch (e) {
      throw TextToSpeechFailure('Failed to set speech rate: $e');
    }
  }

  @override
  Future<void> setPitch(double pitch) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      await _initCompleter.future;

      // Clamp pitch between 0.5 and 2.0
      final clampedPitch = pitch.clamp(0.5, 2.0);
      await _flutterTts.setPitch(clampedPitch);
    } catch (e) {
      throw TextToSpeechFailure('Failed to set pitch: $e');
    }
  }

  @override
  Future<void> setVolume(double volume) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      await _initCompleter.future;

      // Clamp volume between 0.0 and 1.0
      final clampedVolume = volume.clamp(0.0, 1.0);
      await _flutterTts.setVolume(clampedVolume);
    } catch (e) {
      throw TextToSpeechFailure('Failed to set volume: $e');
    }
  }

  @override
  Future<void> setVoice(String voice) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      await _initCompleter.future;

      await _flutterTts.setVoice({'name': voice, 'locale': _getLanguageCode(_currentLanguage)});
    } catch (e) {
      throw TextToSpeechFailure('Failed to set voice: $e');
    }
  }

  Future<void> _applySettings(TTSSettings settings) async {
    await setSpeechRate(settings.speechRate);
    await setPitch(settings.pitch);
    await setVolume(settings.volume);
    
    if (settings.voice.isNotEmpty) {
      await setVoice(settings.voice);
    }
  }

  String _getLanguageCode(String language) {
    switch (language) {
      case AppConstants.englishLocale:
        return 'en-US';
      case AppConstants.swahiliLocale:
        return 'sw-KE'; // Swahili (Kenya)
      default:
        return 'en-US';
    }
  }

  void dispose() {
    _flutterTts.stop();
  }
}

// Mock implementation for testing
class MockTextToSpeechDataSource implements TextToSpeechDataSource {
  bool _isSpeaking = false;
  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _isInitialized = true;
  }

  @override
  Future<void> speakText({
    required String text,
    required String language,
    TTSSettings? settings,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _isSpeaking = true;
    
    // Simulate speaking duration
    Future.delayed(Duration(seconds: text.length ~/ 10 + 1), () {
      _isSpeaking = false;
    });
  }

  @override
  Future<void> stop() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _isSpeaking = false;
  }

  @override
  Future<bool> isSpeaking() async {
    return _isSpeaking;
  }

  @override
  Future<List<String>> getAvailableVoices(String language) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return ['Default Voice', 'Voice 1', 'Voice 2'];
  }

  @override
  Future<void> setLanguage(String language) async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<void> setSpeechRate(double rate) async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<void> setPitch(double pitch) async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<void> setVolume(double volume) async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<void> setVoice(String voice) async {
    await Future.delayed(const Duration(milliseconds: 100));
  }
}
