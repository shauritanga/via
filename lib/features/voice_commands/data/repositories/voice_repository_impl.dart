import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/voice_command_translator.dart';
import '../../domain/entities/voice_command.dart';
import '../../domain/repositories/voice_repository.dart';
import '../datasources/speech_recognition_datasource.dart';
import '../datasources/text_to_speech_datasource.dart';

class VoiceRepositoryImpl implements VoiceRepository {
  final SpeechRecognitionDataSource speechRecognitionDataSource;
  final TextToSpeechDataSource textToSpeechDataSource;

  VoiceRepositoryImpl({
    required this.speechRecognitionDataSource,
    required this.textToSpeechDataSource,
  });

  @override
  Future<Either<Failure, void>> startListening({
    required String language,
    required Function(SpeechRecognitionResult) onResult,
    required Function(String) onError,
  }) async {
    try {
      await speechRecognitionDataSource.startListening(
        language: language,
        onResult: onResult,
        onError: onError,
      );
      return const Right(null);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(SpeechRecognitionFailure('Failed to start listening: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> stopListening() async {
    try {
      await speechRecognitionDataSource.stopListening();
      return const Right(null);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(SpeechRecognitionFailure('Failed to stop listening: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isListening() async {
    try {
      final isListening = await speechRecognitionDataSource.isListening();
      return Right(isListening);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(SpeechRecognitionFailure('Failed to check listening status: $e'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getAvailableLanguages() async {
    try {
      final languages = await speechRecognitionDataSource.getAvailableLanguages();
      return Right(languages);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(SpeechRecognitionFailure('Failed to get available languages: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> speakText({
    required String text,
    required String language,
    TTSSettings? settings,
  }) async {
    try {
      await textToSpeechDataSource.speakText(
        text: text,
        language: language,
        settings: settings,
      );
      return const Right(null);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(TextToSpeechFailure('Failed to speak text: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> stopSpeaking() async {
    try {
      await textToSpeechDataSource.stop();
      return const Right(null);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(TextToSpeechFailure('Failed to stop speaking: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isSpeaking() async {
    try {
      final isSpeaking = await textToSpeechDataSource.isSpeaking();
      return Right(isSpeaking);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(TextToSpeechFailure('Failed to check speaking status: $e'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getAvailableVoices(String language) async {
    try {
      final voices = await textToSpeechDataSource.getAvailableVoices(language);
      return Right(voices);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(TextToSpeechFailure('Failed to get available voices: $e'));
    }
  }

  @override
  Future<Either<Failure, VoiceCommand>> parseVoiceCommand({
    required String recognizedText,
    required String language,
    required double confidence,
  }) async {
    try {
      final command = VoiceCommandTranslator.parseCommand(
        recognizedText: recognizedText,
        language: language,
        confidence: confidence,
      );
      return Right(command);
    } catch (e) {
      return Left(SpeechRecognitionFailure('Failed to parse voice command: $e'));
    }
  }
}
