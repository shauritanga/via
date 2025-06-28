import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';
import '../models/app_settings_model.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;

  SettingsRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, AppSettings>> getSettings() async {
    try {
      final settings = await localDataSource.getSettings();
      return Right(settings);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(CacheFailure('Failed to get settings: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveSettings(AppSettings settings) async {
    try {
      final settingsModel = AppSettingsModel.fromEntity(settings);
      await localDataSource.saveSettings(settingsModel);
      return const Right(null);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(CacheFailure('Failed to save settings: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> getLanguagePreference() async {
    try {
      final language = await localDataSource.getLanguagePreference();
      return Right(language);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(CacheFailure('Failed to get language preference: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setLanguagePreference(String language) async {
    try {
      await localDataSource.setLanguagePreference(language);
      return const Right(null);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(CacheFailure('Failed to set language preference: $e'));
    }
  }

  @override
  Future<Either<Failure, TTSPreferences>> getTtsSettings() async {
    try {
      final settings = await localDataSource.getTtsSettings();
      return Right(settings);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(CacheFailure('Failed to get TTS settings: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setTtsSettings(TTSPreferences settings) async {
    try {
      final settingsModel = TTSPreferencesModel(
        speechRate: settings.speechRate,
        pitch: settings.pitch,
        volume: settings.volume,
        preferredVoice: settings.preferredVoice,
        enablePunctuation: settings.enablePunctuation,
        enableEmphasis: settings.enableEmphasis,
      );
      await localDataSource.setTtsSettings(settingsModel);
      return const Right(null);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(CacheFailure('Failed to set TTS settings: $e'));
    }
  }

  @override
  Future<Either<Failure, AccessibilitySettings>> getAccessibilitySettings() async {
    try {
      final settings = await localDataSource.getAccessibilitySettings();
      return Right(settings);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(CacheFailure('Failed to get accessibility settings: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setAccessibilitySettings(AccessibilitySettings settings) async {
    try {
      final settingsModel = AccessibilitySettingsModel(
        highContrastMode: settings.highContrastMode,
        textScaleFactor: settings.textScaleFactor,
        enableVoiceFeedback: settings.enableVoiceFeedback,
        enableHapticFeedback: settings.enableHapticFeedback,
        enableScreenReader: settings.enableScreenReader,
        voiceCommandTimeout: settings.voiceCommandTimeout,
      );
      await localDataSource.setAccessibilitySettings(settingsModel);
      return const Right(null);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(CacheFailure('Failed to set accessibility settings: $e'));
    }
  }

  @override
  Future<Either<Failure, VoiceCommandSettings>> getVoiceCommandSettings() async {
    try {
      final settings = await localDataSource.getVoiceCommandSettings();
      return Right(settings);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(CacheFailure('Failed to get voice command settings: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setVoiceCommandSettings(VoiceCommandSettings settings) async {
    try {
      final settingsModel = VoiceCommandSettingsModel(
        enableContinuousListening: settings.enableContinuousListening,
        minimumConfidence: settings.minimumConfidence,
        listeningTimeout: settings.listeningTimeout,
        enableWakeWord: settings.enableWakeWord,
        wakeWord: settings.wakeWord,
        enableVoiceConfirmation: settings.enableVoiceConfirmation,
      );
      await localDataSource.setVoiceCommandSettings(settingsModel);
      return const Right(null);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(CacheFailure('Failed to set voice command settings: $e'));
    }
  }
}
