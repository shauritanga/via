import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/app_settings.dart';
import '../repositories/settings_repository.dart';

class SetTtsSettings implements UseCase<void, SetTtsSettingsParams> {
  final SettingsRepository repository;

  SetTtsSettings(this.repository);

  @override
  Future<Either<Failure, void>> call(SetTtsSettingsParams params) async {
    return await repository.setTtsSettings(params.settings);
  }
}

class SetTtsSettingsParams extends Equatable {
  final TTSPreferences settings;

  const SetTtsSettingsParams({required this.settings});

  @override
  List<Object> get props => [settings];
}
