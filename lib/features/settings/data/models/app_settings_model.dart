import 'dart:convert';
import '../../domain/entities/app_settings.dart';

class AppSettingsModel extends AppSettings {
  const AppSettingsModel({
    required super.language,
    required super.ttsPreferences,
    required super.accessibilitySettings,
    required super.voiceCommandSettings,
  });

  factory AppSettingsModel.fromJson(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return AppSettingsModel(
      language: json['language'] ?? 'en',
      ttsPreferences: TTSPreferencesModel.fromMap(
        json['ttsPreferences'] ?? {},
      ),
      accessibilitySettings: AccessibilitySettingsModel.fromMap(
        json['accessibilitySettings'] ?? {},
      ),
      voiceCommandSettings: VoiceCommandSettingsModel.fromMap(
        json['voiceCommandSettings'] ?? {},
      ),
    );
  }

  factory AppSettingsModel.fromEntity(AppSettings settings) {
    return AppSettingsModel(
      language: settings.language,
      ttsPreferences: settings.ttsPreferences,
      accessibilitySettings: settings.accessibilitySettings,
      voiceCommandSettings: settings.voiceCommandSettings,
    );
  }

  String toJson() {
    return jsonEncode({
      'language': language,
      'ttsPreferences': (ttsPreferences as TTSPreferencesModel).toMap(),
      'accessibilitySettings': (accessibilitySettings as AccessibilitySettingsModel).toMap(),
      'voiceCommandSettings': (voiceCommandSettings as VoiceCommandSettingsModel).toMap(),
    });
  }

  factory AppSettingsModel.defaultSettings() {
    return const AppSettingsModel(
      language: 'en',
      ttsPreferences: TTSPreferencesModel.defaultSettings(),
      accessibilitySettings: AccessibilitySettingsModel.defaultSettings(),
      voiceCommandSettings: VoiceCommandSettingsModel.defaultSettings(),
    );
  }
}

class TTSPreferencesModel extends TTSPreferences {
  const TTSPreferencesModel({
    required super.speechRate,
    required super.pitch,
    required super.volume,
    required super.preferredVoice,
    required super.enablePunctuation,
    required super.enableEmphasis,
  });

  factory TTSPreferencesModel.fromMap(Map<String, dynamic> map) {
    return TTSPreferencesModel(
      speechRate: (map['speechRate'] ?? 0.5).toDouble(),
      pitch: (map['pitch'] ?? 1.0).toDouble(),
      volume: (map['volume'] ?? 1.0).toDouble(),
      preferredVoice: map['preferredVoice'] ?? '',
      enablePunctuation: map['enablePunctuation'] ?? true,
      enableEmphasis: map['enableEmphasis'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'speechRate': speechRate,
      'pitch': pitch,
      'volume': volume,
      'preferredVoice': preferredVoice,
      'enablePunctuation': enablePunctuation,
      'enableEmphasis': enableEmphasis,
    };
  }

  const factory TTSPreferencesModel.defaultSettings() = TTSPreferencesModel._defaultSettings;

  const TTSPreferencesModel._defaultSettings()
      : super(
          speechRate: 0.5,
          pitch: 1.0,
          volume: 1.0,
          preferredVoice: '',
          enablePunctuation: true,
          enableEmphasis: true,
        );
}

class AccessibilitySettingsModel extends AccessibilitySettings {
  const AccessibilitySettingsModel({
    required super.highContrastMode,
    required super.textScaleFactor,
    required super.enableVoiceFeedback,
    required super.enableHapticFeedback,
    required super.enableScreenReader,
    required super.voiceCommandTimeout,
  });

  factory AccessibilitySettingsModel.fromMap(Map<String, dynamic> map) {
    return AccessibilitySettingsModel(
      highContrastMode: map['highContrastMode'] ?? false,
      textScaleFactor: (map['textScaleFactor'] ?? 1.0).toDouble(),
      enableVoiceFeedback: map['enableVoiceFeedback'] ?? true,
      enableHapticFeedback: map['enableHapticFeedback'] ?? true,
      enableScreenReader: map['enableScreenReader'] ?? true,
      voiceCommandTimeout: map['voiceCommandTimeout'] ?? 5000,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'highContrastMode': highContrastMode,
      'textScaleFactor': textScaleFactor,
      'enableVoiceFeedback': enableVoiceFeedback,
      'enableHapticFeedback': enableHapticFeedback,
      'enableScreenReader': enableScreenReader,
      'voiceCommandTimeout': voiceCommandTimeout,
    };
  }

  const factory AccessibilitySettingsModel.defaultSettings() = AccessibilitySettingsModel._defaultSettings;

  const AccessibilitySettingsModel._defaultSettings()
      : super(
          highContrastMode: false,
          textScaleFactor: 1.0,
          enableVoiceFeedback: true,
          enableHapticFeedback: true,
          enableScreenReader: true,
          voiceCommandTimeout: 5000,
        );
}

class VoiceCommandSettingsModel extends VoiceCommandSettings {
  const VoiceCommandSettingsModel({
    required super.enableContinuousListening,
    required super.minimumConfidence,
    required super.listeningTimeout,
    required super.enableWakeWord,
    required super.wakeWord,
    required super.enableVoiceConfirmation,
  });

  factory VoiceCommandSettingsModel.fromMap(Map<String, dynamic> map) {
    return VoiceCommandSettingsModel(
      enableContinuousListening: map['enableContinuousListening'] ?? false,
      minimumConfidence: (map['minimumConfidence'] ?? 0.7).toDouble(),
      listeningTimeout: map['listeningTimeout'] ?? 5000,
      enableWakeWord: map['enableWakeWord'] ?? false,
      wakeWord: map['wakeWord'] ?? 'via',
      enableVoiceConfirmation: map['enableVoiceConfirmation'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enableContinuousListening': enableContinuousListening,
      'minimumConfidence': minimumConfidence,
      'listeningTimeout': listeningTimeout,
      'enableWakeWord': enableWakeWord,
      'wakeWord': wakeWord,
      'enableVoiceConfirmation': enableVoiceConfirmation,
    };
  }

  const factory VoiceCommandSettingsModel.defaultSettings() = VoiceCommandSettingsModel._defaultSettings;

  const VoiceCommandSettingsModel._defaultSettings()
      : super(
          enableContinuousListening: false,
          minimumConfidence: 0.7,
          listeningTimeout: 5000,
          enableWakeWord: false,
          wakeWord: 'via',
          enableVoiceConfirmation: true,
        );
}
