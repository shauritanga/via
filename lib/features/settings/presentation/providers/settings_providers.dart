import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/dependency_injection.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/usecases/get_language_preference.dart';
import '../../domain/usecases/set_language_preference.dart';

// Current language provider
final currentLanguageProvider = StateNotifierProvider<LanguageNotifier, String>(
  (ref) {
    return LanguageNotifier();
  },
);

class LanguageNotifier extends StateNotifier<String> {
  LanguageNotifier() : super(AppConstants.englishLocale) {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    try {
      final getLanguagePreference = sl<GetLanguagePreference>();
      final result = await getLanguagePreference(NoParams());

      result.fold(
        (failure) {
          // Keep default language
        },
        (language) {
          state = language;
        },
      );
    } catch (e) {
      // Keep default language
    }
  }

  Future<void> changeLanguage(String language) async {
    try {
      final setLanguagePreference = sl<SetLanguagePreference>();
      final result = await setLanguagePreference(
        SetLanguagePreferenceParams(language: language),
      );

      result.fold(
        (failure) {
          // Handle error
        },
        (_) {
          state = language;
        },
      );
    } catch (e) {
      // Handle error
    }
  }
}

// App settings provider
final appSettingsProvider = FutureProvider<AppSettings>((ref) async {
  final settingsRepository = sl<SettingsRepository>();
  final result = await settingsRepository.getSettings();

  return result.fold(
    (failure) => const AppSettings(
      language: AppConstants.englishLocale,
      ttsPreferences: TTSPreferences(
        speechRate: AppConstants.defaultSpeechRate,
        pitch: AppConstants.defaultPitch,
        volume: AppConstants.defaultVolume,
        preferredVoice: '',
        enablePunctuation: true,
        enableEmphasis: true,
      ),
      accessibilitySettings: AccessibilitySettings(
        highContrastMode: false,
        textScaleFactor: 1.0,
        enableVoiceFeedback: true,
        enableHapticFeedback: true,
        enableScreenReader: true,
        voiceCommandTimeout: 5000,
      ),
      voiceCommandSettings: VoiceCommandSettings(
        enableContinuousListening: false,
        minimumConfidence: 0.7,
        listeningTimeout: 5000,
        enableWakeWord: false,
        wakeWord: 'via',
        enableVoiceConfirmation: true,
      ),
    ),
    (settings) => settings,
  );
});

// TTS settings provider
final ttsSettingsProvider = FutureProvider<TTSPreferences>((ref) async {
  final settingsRepository = sl<SettingsRepository>();
  final result = await settingsRepository.getTtsSettings();

  return result.fold(
    (failure) => const TTSPreferences(
      speechRate: AppConstants.defaultSpeechRate,
      pitch: AppConstants.defaultPitch,
      volume: AppConstants.defaultVolume,
      preferredVoice: '',
      enablePunctuation: true,
      enableEmphasis: true,
    ),
    (settings) => settings,
  );
});

// Accessibility settings provider
final accessibilitySettingsProvider = FutureProvider<AccessibilitySettings>((
  ref,
) async {
  final settingsRepository = sl<SettingsRepository>();
  final result = await settingsRepository.getAccessibilitySettings();

  return result.fold(
    (failure) => const AccessibilitySettings(
      highContrastMode: false,
      textScaleFactor: 1.0,
      enableVoiceFeedback: true,
      enableHapticFeedback: true,
      enableScreenReader: true,
      voiceCommandTimeout: 5000,
    ),
    (settings) => settings,
  );
});

// Voice command settings provider
final voiceCommandSettingsProvider = FutureProvider<VoiceCommandSettings>((
  ref,
) async {
  final settingsRepository = sl<SettingsRepository>();
  final result = await settingsRepository.getVoiceCommandSettings();

  return result.fold(
    (failure) => const VoiceCommandSettings(
      enableContinuousListening: false,
      minimumConfidence: 0.7,
      listeningTimeout: 5000,
      enableWakeWord: false,
      wakeWord: 'via',
      enableVoiceConfirmation: true,
    ),
    (settings) => settings,
  );
});

// Settings notifier for managing settings state
class SettingsNotifier extends StateNotifier<AsyncValue<AppSettings>> {
  SettingsNotifier() : super(const AsyncValue.loading()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settingsRepository = sl<SettingsRepository>();
      final result = await settingsRepository.getSettings();

      result.fold(
        (failure) {
          state = AsyncValue.error(failure, StackTrace.current);
        },
        (settings) {
          state = AsyncValue.data(settings);
        },
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateTtsSettings(TTSPreferences settings) async {
    try {
      final settingsRepository = sl<SettingsRepository>();
      final result = await settingsRepository.setTtsSettings(settings);

      result.fold(
        (failure) {
          // Handle error
        },
        (_) {
          // Reload settings
          _loadSettings();
        },
      );
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updateAccessibilitySettings(
    AccessibilitySettings settings,
  ) async {
    try {
      final settingsRepository = sl<SettingsRepository>();
      final result = await settingsRepository.setAccessibilitySettings(
        settings,
      );

      result.fold(
        (failure) {
          // Handle error
        },
        (_) {
          // Reload settings
          _loadSettings();
        },
      );
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updateVoiceCommandSettings(VoiceCommandSettings settings) async {
    try {
      final settingsRepository = sl<SettingsRepository>();
      final result = await settingsRepository.setVoiceCommandSettings(settings);

      result.fold(
        (failure) {
          // Handle error
        },
        (_) {
          // Reload settings
          _loadSettings();
        },
      );
    } catch (e) {
      // Handle error
    }
  }
}

final settingsNotifierProvider =
    StateNotifierProvider<SettingsNotifier, AsyncValue<AppSettings>>((ref) {
      return SettingsNotifier();
    });
