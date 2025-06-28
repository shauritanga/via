import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/failures.dart';
import '../models/app_settings_model.dart';

abstract class SettingsLocalDataSource {
  Future<AppSettingsModel> getSettings();
  Future<void> saveSettings(AppSettingsModel settings);
  Future<String> getLanguagePreference();
  Future<void> setLanguagePreference(String language);
  Future<TTSPreferencesModel> getTtsSettings();
  Future<void> setTtsSettings(TTSPreferencesModel settings);
  Future<AccessibilitySettingsModel> getAccessibilitySettings();
  Future<void> setAccessibilitySettings(AccessibilitySettingsModel settings);
  Future<VoiceCommandSettingsModel> getVoiceCommandSettings();
  Future<void> setVoiceCommandSettings(VoiceCommandSettingsModel settings);
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String settingsKey = 'APP_SETTINGS';
  static const String languageKey = 'LANGUAGE_PREFERENCE';
  static const String ttsSettingsKey = 'TTS_SETTINGS';
  static const String accessibilitySettingsKey = 'ACCESSIBILITY_SETTINGS';
  static const String voiceCommandSettingsKey = 'VOICE_COMMAND_SETTINGS';

  SettingsLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<AppSettingsModel> getSettings() async {
    try {
      final settingsJson = sharedPreferences.getString(settingsKey);
      if (settingsJson == null) {
        return AppSettingsModel.defaultSettings();
      }
      return AppSettingsModel.fromJson(settingsJson);
    } catch (e) {
      throw CacheFailure('Failed to get settings: $e');
    }
  }

  @override
  Future<void> saveSettings(AppSettingsModel settings) async {
    try {
      await sharedPreferences.setString(settingsKey, settings.toJson());
    } catch (e) {
      throw CacheFailure('Failed to save settings: $e');
    }
  }

  @override
  Future<String> getLanguagePreference() async {
    try {
      return sharedPreferences.getString(languageKey) ?? 'en';
    } catch (e) {
      throw CacheFailure('Failed to get language preference: $e');
    }
  }

  @override
  Future<void> setLanguagePreference(String language) async {
    try {
      await sharedPreferences.setString(languageKey, language);
      
      // Also update the full settings
      final currentSettings = await getSettings();
      final updatedSettings = AppSettingsModel(
        language: language,
        ttsPreferences: currentSettings.ttsPreferences,
        accessibilitySettings: currentSettings.accessibilitySettings,
        voiceCommandSettings: currentSettings.voiceCommandSettings,
      );
      await saveSettings(updatedSettings);
    } catch (e) {
      throw CacheFailure('Failed to set language preference: $e');
    }
  }

  @override
  Future<TTSPreferencesModel> getTtsSettings() async {
    try {
      final settings = await getSettings();
      return settings.ttsPreferences as TTSPreferencesModel;
    } catch (e) {
      throw CacheFailure('Failed to get TTS settings: $e');
    }
  }

  @override
  Future<void> setTtsSettings(TTSPreferencesModel settings) async {
    try {
      final currentSettings = await getSettings();
      final updatedSettings = AppSettingsModel(
        language: currentSettings.language,
        ttsPreferences: settings,
        accessibilitySettings: currentSettings.accessibilitySettings,
        voiceCommandSettings: currentSettings.voiceCommandSettings,
      );
      await saveSettings(updatedSettings);
    } catch (e) {
      throw CacheFailure('Failed to set TTS settings: $e');
    }
  }

  @override
  Future<AccessibilitySettingsModel> getAccessibilitySettings() async {
    try {
      final settings = await getSettings();
      return settings.accessibilitySettings as AccessibilitySettingsModel;
    } catch (e) {
      throw CacheFailure('Failed to get accessibility settings: $e');
    }
  }

  @override
  Future<void> setAccessibilitySettings(AccessibilitySettingsModel settings) async {
    try {
      final currentSettings = await getSettings();
      final updatedSettings = AppSettingsModel(
        language: currentSettings.language,
        ttsPreferences: currentSettings.ttsPreferences,
        accessibilitySettings: settings,
        voiceCommandSettings: currentSettings.voiceCommandSettings,
      );
      await saveSettings(updatedSettings);
    } catch (e) {
      throw CacheFailure('Failed to set accessibility settings: $e');
    }
  }

  @override
  Future<VoiceCommandSettingsModel> getVoiceCommandSettings() async {
    try {
      final settings = await getSettings();
      return settings.voiceCommandSettings as VoiceCommandSettingsModel;
    } catch (e) {
      throw CacheFailure('Failed to get voice command settings: $e');
    }
  }

  @override
  Future<void> setVoiceCommandSettings(VoiceCommandSettingsModel settings) async {
    try {
      final currentSettings = await getSettings();
      final updatedSettings = AppSettingsModel(
        language: currentSettings.language,
        ttsPreferences: currentSettings.ttsPreferences,
        accessibilitySettings: currentSettings.accessibilitySettings,
        voiceCommandSettings: settings,
      );
      await saveSettings(updatedSettings);
    } catch (e) {
      throw CacheFailure('Failed to set voice command settings: $e');
    }
  }
}
