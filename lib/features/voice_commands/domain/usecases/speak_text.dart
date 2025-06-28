import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/voice_command.dart';
import '../repositories/voice_repository.dart';

class SpeakText implements UseCase<void, SpeakTextParams> {
  final VoiceRepository repository;

  SpeakText(this.repository);

  @override
  Future<Either<Failure, void>> call(SpeakTextParams params) async {
    return await repository.speakText(
      text: params.text,
      language: params.language,
      settings: params.settings,
    );
  }
}

class SpeakTextParams extends Equatable {
  final String text;
  final String language;
  final TTSSettings? settings;

  const SpeakTextParams({
    required this.text,
    required this.language,
    this.settings,
  });

  @override
  List<Object?> get props => [text, language, settings];
}
