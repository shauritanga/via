import 'package:equatable/equatable.dart';

class VoiceCommand extends Equatable {
  final String command;
  final VoiceCommandType type;
  final Map<String, dynamic> parameters;
  final String language;
  final double confidence;
  final DateTime timestamp;

  const VoiceCommand({
    required this.command,
    required this.type,
    required this.parameters,
    required this.language,
    required this.confidence,
    required this.timestamp,
  });

  @override
  List<Object> get props => [
        command,
        type,
        parameters,
        language,
        confidence,
        timestamp,
      ];

  VoiceCommand copyWith({
    String? command,
    VoiceCommandType? type,
    Map<String, dynamic>? parameters,
    String? language,
    double? confidence,
    DateTime? timestamp,
  }) {
    return VoiceCommand(
      command: command ?? this.command,
      type: type ?? this.type,
      parameters: parameters ?? this.parameters,
      language: language ?? this.language,
      confidence: confidence ?? this.confidence,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

enum VoiceCommandType {
  readDocument,
  openDocument,
  readSection,
  stopReading,
  pauseReading,
  resumeReading,
  nextPage,
  previousPage,
  goToPage,
  listDocuments,
  uploadDocument,
  deleteDocument,
  changeLanguage,
  settings,
  help,
  unknown,
}

class SpeechRecognitionResult extends Equatable {
  final String recognizedText;
  final double confidence;
  final bool isFinal;
  final String language;
  final DateTime timestamp;

  const SpeechRecognitionResult({
    required this.recognizedText,
    required this.confidence,
    required this.isFinal,
    required this.language,
    required this.timestamp,
  });

  @override
  List<Object> get props => [
        recognizedText,
        confidence,
        isFinal,
        language,
        timestamp,
      ];

  SpeechRecognitionResult copyWith({
    String? recognizedText,
    double? confidence,
    bool? isFinal,
    String? language,
    DateTime? timestamp,
  }) {
    return SpeechRecognitionResult(
      recognizedText: recognizedText ?? this.recognizedText,
      confidence: confidence ?? this.confidence,
      isFinal: isFinal ?? this.isFinal,
      language: language ?? this.language,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

class TTSSettings extends Equatable {
  final double speechRate;
  final double pitch;
  final double volume;
  final String language;
  final String voice;

  const TTSSettings({
    required this.speechRate,
    required this.pitch,
    required this.volume,
    required this.language,
    required this.voice,
  });

  @override
  List<Object> get props => [speechRate, pitch, volume, language, voice];

  TTSSettings copyWith({
    double? speechRate,
    double? pitch,
    double? volume,
    String? language,
    String? voice,
  }) {
    return TTSSettings(
      speechRate: speechRate ?? this.speechRate,
      pitch: pitch ?? this.pitch,
      volume: volume ?? this.volume,
      language: language ?? this.language,
      voice: voice ?? this.voice,
    );
  }
}
