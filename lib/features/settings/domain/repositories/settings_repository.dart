import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/app_settings.dart';

abstract class SettingsRepository {
  Future<Either<Failure, AppSettings>> getSettings();
  Future<Either<Failure, void>> saveSettings(AppSettings settings);
  Future<Either<Failure, String>> getLanguagePreference();
  Future<Either<Failure, void>> setLanguagePreference(String language);
  Future<Either<Failure, TTSPreferences>> getTtsSettings();
  Future<Either<Failure, void>> setTtsSettings(TTSPreferences settings);
  Future<Either<Failure, AccessibilitySettings>> getAccessibilitySettings();
  Future<Either<Failure, void>> setAccessibilitySettings(AccessibilitySettings settings);
  Future<Either<Failure, VoiceCommandSettings>> getVoiceCommandSettings();
  Future<Either<Failure, void>> setVoiceCommandSettings(VoiceCommandSettings settings);
}
