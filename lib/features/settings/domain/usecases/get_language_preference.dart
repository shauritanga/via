import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/settings_repository.dart';

class GetLanguagePreference implements UseCase<String, NoParams> {
  final SettingsRepository repository;

  GetLanguagePreference(this.repository);

  @override
  Future<Either<Failure, String>> call(NoParams params) async {
    return await repository.getLanguagePreference();
  }
}
