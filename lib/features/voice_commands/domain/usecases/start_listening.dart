import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/voice_command.dart';
import '../repositories/voice_repository.dart';

class StartListening implements UseCase<void, StartListeningParams> {
  final VoiceRepository repository;

  StartListening(this.repository);

  @override
  Future<Either<Failure, void>> call(StartListeningParams params) async {
    return await repository.startListening(
      language: params.language,
      onResult: params.onResult,
      onError: params.onError,
    );
  }
}

class StartListeningParams extends Equatable {
  final String language;
  final Function(SpeechRecognitionResult) onResult;
  final Function(String) onError;

  const StartListeningParams({
    required this.language,
    required this.onResult,
    required this.onError,
  });

  @override
  List<Object> get props => [language];
}
