import 'package:equatable/equatable.dart';

enum SummaryLength { brief, medium, detailed }
enum SummaryType { overview, keyPoints, academic, course }

class SummaryRequest extends Equatable {
  final String content;
  final SummaryLength length;
  final SummaryType type;
  final String language;
  final String? context; // e.g., "university prospectus", "course description"
  final List<String>? focusAreas; // e.g., ["requirements", "career prospects"]

  const SummaryRequest({
    required this.content,
    this.length = SummaryLength.medium,
    this.type = SummaryType.overview,
    this.language = 'en',
    this.context,
    this.focusAreas,
  });

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'length': length.name,
      'type': type.name,
      'language': language,
      'context': context,
      'focusAreas': focusAreas,
    };
  }

  factory SummaryRequest.fromJson(Map<String, dynamic> json) {
    return SummaryRequest(
      content: json['content'] as String,
      length: SummaryLength.values.firstWhere(
        (e) => e.name == json['length'],
        orElse: () => SummaryLength.medium,
      ),
      type: SummaryType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SummaryType.overview,
      ),
      language: json['language'] as String? ?? 'en',
      context: json['context'] as String?,
      focusAreas: (json['focusAreas'] as List<dynamic>?)?.cast<String>(),
    );
  }

  SummaryRequest copyWith({
    String? content,
    SummaryLength? length,
    SummaryType? type,
    String? language,
    String? context,
    List<String>? focusAreas,
  }) {
    return SummaryRequest(
      content: content ?? this.content,
      length: length ?? this.length,
      type: type ?? this.type,
      language: language ?? this.language,
      context: context ?? this.context,
      focusAreas: focusAreas ?? this.focusAreas,
    );
  }

  @override
  List<Object?> get props => [content, length, type, language, context, focusAreas];
}

class SummaryResponse extends Equatable {
  final String summary;
  final List<String> keyPoints;
  final Map<String, String> metadata;
  final double confidence;
  final DateTime createdAt;

  const SummaryResponse({
    required this.summary,
    required this.keyPoints,
    required this.metadata,
    required this.confidence,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'summary': summary,
      'keyPoints': keyPoints,
      'metadata': metadata,
      'confidence': confidence,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SummaryResponse.fromJson(Map<String, dynamic> json) {
    return SummaryResponse(
      summary: json['summary'] as String,
      keyPoints: (json['keyPoints'] as List<dynamic>).cast<String>(),
      metadata: Map<String, String>.from(json['metadata'] as Map),
      confidence: (json['confidence'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  List<Object?> get props => [summary, keyPoints, metadata, confidence, createdAt];
}
