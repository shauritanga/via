import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/app_settings.dart';
import '../repositories/settings_repository.dart';

class GetTtsSettings implements UseCase<TTSPreferences, NoParams> {
  final SettingsRepository repository;

  GetTtsSettings(this.repository);

  @override
  Future<Either<Failure, TTSPreferences>> call(NoParams params) async {
    return await repository.getTtsSettings();
  }
}
