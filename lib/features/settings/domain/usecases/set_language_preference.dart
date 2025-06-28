import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/settings_repository.dart';

class SetLanguagePreference implements UseCase<void, SetLanguagePreferenceParams> {
  final SettingsRepository repository;

  SetLanguagePreference(this.repository);

  @override
  Future<Either<Failure, void>> call(SetLanguagePreferenceParams params) async {
    return await repository.setLanguagePreference(params.language);
  }
}

class SetLanguagePreferenceParams extends Equatable {
  final String language;

  const SetLanguagePreferenceParams({required this.language});

  @override
  List<Object> get props => [language];
}
