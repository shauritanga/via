import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/voice_repository.dart';

class StopSpeaking implements UseCase<void, NoParams> {
  final VoiceRepository repository;

  StopSpeaking(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.stopSpeaking();
  }
}
