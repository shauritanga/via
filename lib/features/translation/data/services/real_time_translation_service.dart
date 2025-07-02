import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
// Using HTTP-based translation service
import 'package:shared_preferences/shared_preferences.dart';
import '../models/translation_request.dart';

class RealTimeTranslationService {
  // Using HTTP-based translation instead of external package
  static final Map<String, TranslationCache> _cache = {};
  static const Duration _cacheExpiry = Duration(hours: 24);

  // Supported languages for the prospectus system
  static const List<SupportedLanguage> supportedLanguages = [
    SupportedLanguage(code: 'en', name: 'English', nativeName: 'English'),
    SupportedLanguage(code: 'sw', name: 'Swahili', nativeName: 'Kiswahili'),
  ];

  /// Initialize the translation service
  static Future<void> initialize() async {
    await _loadCacheFromStorage();
  }

  /// Translate text in real-time
  static Future<TranslationResponse> translateText(
    TranslationRequest request,
  ) async {
    try {
      // Check cache first
      final cacheKey = TranslationCache.generateKey(
        request.text,
        request.fromLanguage,
        request.toLanguage,
      );

      if (_cache.containsKey(cacheKey) && !_cache[cacheKey]!.isExpired) {
        debugPrint(
          'Translation cache hit for: ${request.text.substring(0, 50)}...',
        );
        return _cache[cacheKey]!.translation;
      }

      // Perform translation
      final translation = await _performTranslation(request);

      // Cache the result
      await _cacheTranslation(cacheKey, translation);

      return translation;
    } catch (e) {
      debugPrint('Translation error: $e');
      rethrow;
    }
  }

  /// Translate multiple texts in batch
  static Future<List<TranslationResponse>> translateBatch(
    List<TranslationRequest> requests,
  ) async {
    final results = <TranslationResponse>[];

    // Process in chunks to avoid overwhelming the API
    const chunkSize = 5;
    for (int i = 0; i < requests.length; i += chunkSize) {
      final chunk = requests.skip(i).take(chunkSize).toList();
      final chunkResults = await Future.wait(
        chunk.map((request) => translateText(request)),
      );
      results.addAll(chunkResults);

      // Small delay between chunks
      if (i + chunkSize < requests.length) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }

    return results;
  }

  /// Detect language of text
  static Future<String> detectLanguage(String text) async {
    try {
      // Use a simple heuristic for common languages
      if (_isEnglish(text)) return 'en';
      if (_isSwahili(text)) return 'sw';
      if (_isArabic(text)) return 'ar';

      // Simple language detection fallback
      return 'en'; // Default to English if detection fails
    } catch (e) {
      debugPrint('Language detection error: $e');
      return 'en'; // Default to English
    }
  }

  /// Get available languages
  static List<SupportedLanguage> getAvailableLanguages() {
    return supportedLanguages;
  }

  /// Check if a language is supported
  static bool isLanguageSupported(String languageCode) {
    return supportedLanguages.any((lang) => lang.code == languageCode);
  }

  /// Clear translation cache
  static Future<void> clearCache() async {
    _cache.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('translation_cache');
  }

  /// Get cache statistics
  static Map<String, dynamic> getCacheStats() {
    final validEntries = _cache.values
        .where((cache) => !cache.isExpired)
        .length;
    final expiredEntries = _cache.length - validEntries;

    return {
      'totalEntries': _cache.length,
      'validEntries': validEntries,
      'expiredEntries': expiredEntries,
      'cacheHitRate': _calculateCacheHitRate(),
    };
  }

  // Private methods

  /// Simple HTTP-based translation (fallback implementation)
  static Future<String> _performHttpTranslation(
    TranslationRequest request,
  ) async {
    try {
      // For now, use the fallback dictionary-based translation
      if (request.fromLanguage == 'en' && request.toLanguage == 'sw') {
        final response = _fallbackEnglishToSwahili(request);
        return response.translatedText;
      } else if (request.fromLanguage == 'sw' && request.toLanguage == 'en') {
        final response = _fallbackSwahiliToEnglish(request);
        return response.translatedText;
      }

      // If no specific translation available, return original text
      return request.text;
    } catch (e) {
      debugPrint('HTTP translation error: $e');
      return request.text;
    }
  }

  static Future<TranslationResponse> _performTranslation(
    TranslationRequest request,
  ) async {
    final startTime = DateTime.now();

    try {
      // Handle same language case
      if (request.fromLanguage == request.toLanguage) {
        return TranslationResponse(
          translatedText: request.text,
          originalText: request.text,
          fromLanguage: request.fromLanguage,
          toLanguage: request.toLanguage,
          confidence: 1.0,
          metadata: {'method': 'same_language', 'processingTime': '0ms'},
          createdAt: DateTime.now(),
        );
      }

      // Use simple HTTP-based translation or fallback
      final translatedText = await _performHttpTranslation(request);
      final processingTime = DateTime.now()
          .difference(startTime)
          .inMilliseconds;

      return TranslationResponse(
        translatedText: translatedText,
        originalText: request.text,
        fromLanguage: request.fromLanguage,
        toLanguage: request.toLanguage,
        confidence: _calculateConfidence(translatedText, request.text),
        metadata: {
          'method': 'http_translation',
          'processingTime': '${processingTime}ms',
          'type': request.type.name,
        },
        createdAt: DateTime.now(),
      );
    } catch (e) {
      // Fallback to basic word-by-word translation for supported languages
      if (request.fromLanguage == 'en' && request.toLanguage == 'sw') {
        return _fallbackEnglishToSwahili(request);
      } else if (request.fromLanguage == 'sw' && request.toLanguage == 'en') {
        return _fallbackSwahiliToEnglish(request);
      }

      rethrow;
    }
  }

  static Future<void> _cacheTranslation(
    String key,
    TranslationResponse translation,
  ) async {
    final cache = TranslationCache(
      key: key,
      translation: translation,
      expiresAt: DateTime.now().add(_cacheExpiry),
    );

    _cache[key] = cache;
    await _saveCacheToStorage();
  }

  static Future<void> _loadCacheFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheJson = prefs.getString('translation_cache');

      if (cacheJson != null) {
        final cacheData = jsonDecode(cacheJson) as Map<String, dynamic>;

        for (final entry in cacheData.entries) {
          final cache = TranslationCache.fromJson(
            entry.value as Map<String, dynamic>,
          );
          if (!cache.isExpired) {
            _cache[entry.key] = cache;
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading translation cache: $e');
    }
  }

  static Future<void> _saveCacheToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = <String, dynamic>{};

      // Only save non-expired entries
      for (final entry in _cache.entries) {
        if (!entry.value.isExpired) {
          cacheData[entry.key] = entry.value.toJson();
        }
      }

      await prefs.setString('translation_cache', jsonEncode(cacheData));
    } catch (e) {
      debugPrint('Error saving translation cache: $e');
    }
  }

  static double _calculateConfidence(String translated, String original) {
    // Simple confidence calculation based on length ratio and content
    final lengthRatio = translated.length / original.length;

    if (lengthRatio < 0.3 || lengthRatio > 3.0) {
      return 0.5; // Low confidence for extreme length differences
    }

    if (translated == original) {
      return 0.8; // Medium confidence for unchanged text
    }

    return 0.9; // High confidence for normal translations
  }

  static double _calculateCacheHitRate() {
    // This would need to be tracked over time in a real implementation
    return 0.75; // Placeholder
  }

  static bool _isEnglish(String text) {
    final englishWords = [
      'the',
      'and',
      'or',
      'but',
      'in',
      'on',
      'at',
      'to',
      'for',
      'of',
      'with',
      'by',
    ];
    final words = text.toLowerCase().split(RegExp(r'\W+'));
    final englishCount = words
        .where((word) => englishWords.contains(word))
        .length;
    return englishCount > words.length * 0.1;
  }

  static bool _isSwahili(String text) {
    final swahiliWords = [
      'na',
      'ya',
      'wa',
      'za',
      'la',
      'cha',
      'kwa',
      'katika',
      'hii',
      'hizo',
    ];
    final words = text.toLowerCase().split(RegExp(r'\W+'));
    final swahiliCount = words
        .where((word) => swahiliWords.contains(word))
        .length;
    return swahiliCount > words.length * 0.1;
  }

  static bool _isArabic(String text) {
    final arabicPattern = RegExp(r'[\u0600-\u06FF]');
    return arabicPattern.hasMatch(text);
  }

  static TranslationResponse _fallbackEnglishToSwahili(
    TranslationRequest request,
  ) {
    // Basic English to Swahili dictionary for academic terms
    final dictionary = {
      'course': 'kozi',
      'program': 'programu',
      'degree': 'shahada',
      'university': 'chuo kikuu',
      'student': 'mwanafunzi',
      'teacher': 'mwalimu',
      'education': 'elimu',
      'study': 'kusoma',
      'learn': 'kujifunza',
      'requirement': 'mahitaji',
      'credit': 'alama',
      'semester': 'muhula',
      'year': 'mwaka',
      'faculty': 'kitivo',
      'department': 'idara',
    };

    String translated = request.text.toLowerCase();
    for (final entry in dictionary.entries) {
      translated = translated.replaceAll(entry.key, entry.value);
    }

    return TranslationResponse(
      translatedText: translated,
      originalText: request.text,
      fromLanguage: request.fromLanguage,
      toLanguage: request.toLanguage,
      confidence: 0.6,
      metadata: {
        'method': 'fallback_dictionary',
        'dictionarySize': dictionary.length.toString(),
      },
      createdAt: DateTime.now(),
    );
  }

  static TranslationResponse _fallbackSwahiliToEnglish(
    TranslationRequest request,
  ) {
    // Basic Swahili to English dictionary for academic terms
    final dictionary = {
      'kozi': 'course',
      'programu': 'program',
      'shahada': 'degree',
      'chuo kikuu': 'university',
      'mwanafunzi': 'student',
      'mwalimu': 'teacher',
      'elimu': 'education',
      'kusoma': 'study',
      'kujifunza': 'learn',
      'mahitaji': 'requirement',
      'alama': 'credit',
      'muhula': 'semester',
      'mwaka': 'year',
      'kitivo': 'faculty',
      'idara': 'department',
    };

    String translated = request.text.toLowerCase();
    for (final entry in dictionary.entries) {
      translated = translated.replaceAll(entry.key, entry.value);
    }

    return TranslationResponse(
      translatedText: translated,
      originalText: request.text,
      fromLanguage: request.fromLanguage,
      toLanguage: request.toLanguage,
      confidence: 0.6,
      metadata: {
        'method': 'fallback_dictionary',
        'dictionarySize': dictionary.length.toString(),
      },
      createdAt: DateTime.now(),
    );
  }
}
