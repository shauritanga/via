import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/voice_repository.dart';

class StopListening implements UseCase<void, NoParams> {
  final VoiceRepository repository;

  StopListening(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.stopListening();
  }
}
