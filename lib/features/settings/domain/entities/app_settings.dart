import 'package:equatable/equatable.dart';

class AppSettings extends Equatable {
  final String language;
  final TTSPreferences ttsPreferences;
  final AccessibilitySettings accessibilitySettings;
  final VoiceCommandSettings voiceCommandSettings;

  const AppSettings({
    required this.language,
    required this.ttsPreferences,
    required this.accessibilitySettings,
    required this.voiceCommandSettings,
  });

  @override
  List<Object> get props => [
        language,
        ttsPreferences,
        accessibilitySettings,
        voiceCommandSettings,
      ];

  AppSettings copyWith({
    String? language,
    TTSPreferences? ttsPreferences,
    AccessibilitySettings? accessibilitySettings,
    VoiceCommandSettings? voiceCommandSettings,
  }) {
    return AppSettings(
      language: language ?? this.language,
      ttsPreferences: ttsPreferences ?? this.ttsPreferences,
      accessibilitySettings: accessibilitySettings ?? this.accessibilitySettings,
      voiceCommandSettings: voiceCommandSettings ?? this.voiceCommandSettings,
    );
  }
}

class TTSPreferences extends Equatable {
  final double speechRate;
  final double pitch;
  final double volume;
  final String preferredVoice;
  final bool enablePunctuation;
  final bool enableEmphasis;

  const TTSPreferences({
    required this.speechRate,
    required this.pitch,
    required this.volume,
    required this.preferredVoice,
    required this.enablePunctuation,
    required this.enableEmphasis,
  });

  @override
  List<Object> get props => [
        speechRate,
        pitch,
        volume,
        preferredVoice,
        enablePunctuation,
        enableEmphasis,
      ];

  TTSPreferences copyWith({
    double? speechRate,
    double? pitch,
    double? volume,
    String? preferredVoice,
    bool? enablePunctuation,
    bool? enableEmphasis,
  }) {
    return TTSPreferences(
      speechRate: speechRate ?? this.speechRate,
      pitch: pitch ?? this.pitch,
      volume: volume ?? this.volume,
      preferredVoice: preferredVoice ?? this.preferredVoice,
      enablePunctuation: enablePunctuation ?? this.enablePunctuation,
      enableEmphasis: enableEmphasis ?? this.enableEmphasis,
    );
  }
}

class AccessibilitySettings extends Equatable {
  final bool highContrastMode;
  final double textScaleFactor;
  final bool enableVoiceFeedback;
  final bool enableHapticFeedback;
  final bool enableScreenReader;
  final int voiceCommandTimeout;

  const AccessibilitySettings({
    required this.highContrastMode,
    required this.textScaleFactor,
    required this.enableVoiceFeedback,
    required this.enableHapticFeedback,
    required this.enableScreenReader,
    required this.voiceCommandTimeout,
  });

  @override
  List<Object> get props => [
        highContrastMode,
        textScaleFactor,
        enableVoiceFeedback,
        enableHapticFeedback,
        enableScreenReader,
        voiceCommandTimeout,
      ];

  AccessibilitySettings copyWith({
    bool? highContrastMode,
    double? textScaleFactor,
    bool? enableVoiceFeedback,
    bool? enableHapticFeedback,
    bool? enableScreenReader,
    int? voiceCommandTimeout,
  }) {
    return AccessibilitySettings(
      highContrastMode: highContrastMode ?? this.highContrastMode,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
      enableVoiceFeedback: enableVoiceFeedback ?? this.enableVoiceFeedback,
      enableHapticFeedback: enableHapticFeedback ?? this.enableHapticFeedback,
      enableScreenReader: enableScreenReader ?? this.enableScreenReader,
      voiceCommandTimeout: voiceCommandTimeout ?? this.voiceCommandTimeout,
    );
  }
}

class VoiceCommandSettings extends Equatable {
  final bool enableContinuousListening;
  final double minimumConfidence;
  final int listeningTimeout;
  final bool enableWakeWord;
  final String wakeWord;
  final bool enableVoiceConfirmation;

  const VoiceCommandSettings({
    required this.enableContinuousListening,
    required this.minimumConfidence,
    required this.listeningTimeout,
    required this.enableWakeWord,
    required this.wakeWord,
    required this.enableVoiceConfirmation,
  });

  @override
  List<Object> get props => [
        enableContinuousListening,
        minimumConfidence,
        listeningTimeout,
        enableWakeWord,
        wakeWord,
        enableVoiceConfirmation,
      ];

  VoiceCommandSettings copyWith({
    bool? enableContinuousListening,
    double? minimumConfidence,
    int? listeningTimeout,
    bool? enableWakeWord,
    String? wakeWord,
    bool? enableVoiceConfirmation,
  }) {
    return VoiceCommandSettings(
      enableContinuousListening: enableContinuousListening ?? this.enableContinuousListening,
      minimumConfidence: minimumConfidence ?? this.minimumConfidence,
      listeningTimeout: listeningTimeout ?? this.listeningTimeout,
      enableWakeWord: enableWakeWord ?? this.enableWakeWord,
      wakeWord: wakeWord ?? this.wakeWord,
      enableVoiceConfirmation: enableVoiceConfirmation ?? this.enableVoiceConfirmation,
    );
  }
}
