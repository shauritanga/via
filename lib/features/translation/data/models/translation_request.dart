import 'package:equatable/equatable.dart';

class TranslationRequest extends Equatable {
  final String text;
  final String fromLanguage;
  final String toLanguage;
  final TranslationType type;
  final Map<String, dynamic>? context;

  const TranslationRequest({
    required this.text,
    required this.fromLanguage,
    required this.toLanguage,
    this.type = TranslationType.general,
    this.context,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'fromLanguage': fromLanguage,
      'toLanguage': toLanguage,
      'type': type.name,
      'context': context,
    };
  }

  factory TranslationRequest.fromJson(Map<String, dynamic> json) {
    return TranslationRequest(
      text: json['text'] as String,
      fromLanguage: json['fromLanguage'] as String,
      toLanguage: json['toLanguage'] as String,
      type: TranslationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TranslationType.general,
      ),
      context: json['context'] as Map<String, dynamic>?,
    );
  }

  @override
  List<Object?> get props => [text, fromLanguage, toLanguage, type, context];
}

class TranslationResponse extends Equatable {
  final String translatedText;
  final String originalText;
  final String fromLanguage;
  final String toLanguage;
  final double confidence;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  const TranslationResponse({
    required this.translatedText,
    required this.originalText,
    required this.fromLanguage,
    required this.toLanguage,
    required this.confidence,
    required this.metadata,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'translatedText': translatedText,
      'originalText': originalText,
      'fromLanguage': fromLanguage,
      'toLanguage': toLanguage,
      'confidence': confidence,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TranslationResponse.fromJson(Map<String, dynamic> json) {
    return TranslationResponse(
      translatedText: json['translatedText'] as String,
      originalText: json['originalText'] as String,
      fromLanguage: json['fromLanguage'] as String,
      toLanguage: json['toLanguage'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      metadata: Map<String, dynamic>.from(json['metadata'] as Map),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  List<Object?> get props => [
        translatedText,
        originalText,
        fromLanguage,
        toLanguage,
        confidence,
        metadata,
        createdAt,
      ];
}

enum TranslationType {
  general,
  academic,
  technical,
  course,
  prospectus,
}

class SupportedLanguage extends Equatable {
  final String code;
  final String name;
  final String nativeName;
  final bool isSupported;

  const SupportedLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
    this.isSupported = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'nativeName': nativeName,
      'isSupported': isSupported,
    };
  }

  factory SupportedLanguage.fromJson(Map<String, dynamic> json) {
    return SupportedLanguage(
      code: json['code'] as String,
      name: json['name'] as String,
      nativeName: json['nativeName'] as String,
      isSupported: json['isSupported'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [code, name, nativeName, isSupported];
}

class TranslationCache extends Equatable {
  final String key;
  final TranslationResponse translation;
  final DateTime expiresAt;

  const TranslationCache({
    required this.key,
    required this.translation,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  static String generateKey(String text, String fromLang, String toLang) {
    return '${text.hashCode}_${fromLang}_$toLang';
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'translation': translation.toJson(),
      'expiresAt': expiresAt.toIso8601String(),
    };
  }

  factory TranslationCache.fromJson(Map<String, dynamic> json) {
    return TranslationCache(
      key: json['key'] as String,
      translation: TranslationResponse.fromJson(json['translation'] as Map<String, dynamic>),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }

  @override
  List<Object?> get props => [key, translation, expiresAt];
}
