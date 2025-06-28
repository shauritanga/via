import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/voice_command.dart';

abstract class VoiceRepository {
  Future<Either<Failure, void>> startListening({
    required String language,
    required Function(SpeechRecognitionResult) onResult,
    required Function(String) onError,
  });
  
  Future<Either<Failure, void>> stopListening();
  
  Future<Either<Failure, bool>> isListening();
  
  Future<Either<Failure, List<String>>> getAvailableLanguages();
  
  Future<Either<Failure, void>> speakText({
    required String text,
    required String language,
    TTSSettings? settings,
  });
  
  Future<Either<Failure, void>> stopSpeaking();
  
  Future<Either<Failure, bool>> isSpeaking();
  
  Future<Either<Failure, List<String>>> getAvailableVoices(String language);
  
  Future<Either<Failure, VoiceCommand>> parseVoiceCommand({
    required String recognizedText,
    required String language,
    required double confidence,
  });
}
