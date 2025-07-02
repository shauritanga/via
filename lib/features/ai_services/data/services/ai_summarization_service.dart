import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/summary_request.dart';
import '../../../../core/config/api_config.dart';

class AISummarizationService {
  // Use configuration from ApiConfig
  static String get _baseUrl => ApiConfig.openAiBaseUrl;

  // Use local summarization when API key is not configured
  static bool get _useLocalSummarization => ApiConfig.useLocalServices;

  /// Summarize content using AI or local algorithms
  static Future<SummaryResponse> summarizeContent(
    SummaryRequest request,
  ) async {
    try {
      if (_useLocalSummarization) {
        return await _localSummarization(request);
      } else {
        return await _aiSummarization(request);
      }
    } catch (e) {
      debugPrint('Summarization error: $e');
      // Fallback to local summarization
      return await _localSummarization(request);
    }
  }

  /// AI-powered summarization using OpenAI
  static Future<SummaryResponse> _aiSummarization(
    SummaryRequest request,
  ) async {
    final prompt = _buildPrompt(request);

    final response = await http.post(
      Uri.parse('$_baseUrl/chat/completions'),
      headers: ApiConfig.openAiHeaders,
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {
            'role': 'system',
            'content':
                'You are an expert academic content summarizer specializing in university prospectuses and course descriptions.',
          },
          {'role': 'user', 'content': prompt},
        ],
        'max_tokens': _getMaxTokens(request.length),
        'temperature': 0.3,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'] as String;

      return _parseAIResponse(content, request);
    } else {
      throw Exception('AI API error: ${response.statusCode}');
    }
  }

  /// Local summarization using extractive methods
  static Future<SummaryResponse> _localSummarization(
    SummaryRequest request,
  ) async {
    final sentences = _splitIntoSentences(request.content);
    final scores = _scoreSentences(sentences, request);
    final topSentences = _selectTopSentences(sentences, scores, request.length);

    final summary = topSentences.join(' ');
    final keyPoints = _extractKeyPoints(request.content, request.type);

    return SummaryResponse(
      summary: summary,
      keyPoints: keyPoints,
      metadata: {
        'method': 'local_extractive',
        'sentences_analyzed': sentences.length.toString(),
        'summary_ratio': (topSentences.length / sentences.length)
            .toStringAsFixed(2),
      },
      confidence: 0.75, // Local summarization confidence
      createdAt: DateTime.now(),
    );
  }

  static String _buildPrompt(SummaryRequest request) {
    final lengthInstruction = switch (request.length) {
      SummaryLength.brief => 'Provide a brief summary in 2-3 sentences',
      SummaryLength.medium =>
        'Provide a medium-length summary in 4-6 sentences',
      SummaryLength.detailed => 'Provide a detailed summary in 8-12 sentences',
    };

    final typeInstruction = switch (request.type) {
      SummaryType.overview => 'Focus on providing a general overview',
      SummaryType.keyPoints => 'Extract and list the key points',
      SummaryType.academic => 'Focus on academic requirements and structure',
      SummaryType.course => 'Focus on course content, objectives, and outcomes',
    };

    String prompt =
        '''
$lengthInstruction of the following content.
$typeInstruction.
Language: ${request.language}
${request.context != null ? 'Context: ${request.context}' : ''}
${request.focusAreas != null ? 'Focus on: ${request.focusAreas!.join(', ')}' : ''}

Content:
${request.content}

Please provide:
1. A clear summary
2. Key points (as bullet points)
3. Any important details that shouldn't be missed
''';

    return prompt;
  }

  static int _getMaxTokens(SummaryLength length) {
    return switch (length) {
      SummaryLength.brief => 150,
      SummaryLength.medium => 300,
      SummaryLength.detailed => 500,
    };
  }

  static SummaryResponse _parseAIResponse(
    String content,
    SummaryRequest request,
  ) {
    final lines = content
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();

    String summary = '';
    List<String> keyPoints = [];

    bool inKeyPoints = false;
    for (final line in lines) {
      if (line.toLowerCase().contains('key points') ||
          line.toLowerCase().contains('bullet points')) {
        inKeyPoints = true;
        continue;
      }

      if (inKeyPoints &&
          (line.startsWith('•') ||
              line.startsWith('-') ||
              line.startsWith('*'))) {
        keyPoints.add(line.replaceFirst(RegExp(r'^[•\-*]\s*'), '').trim());
      } else if (!inKeyPoints) {
        summary += '$line ';
      }
    }

    if (summary.isEmpty) {
      summary = content; // Fallback to full content
    }

    return SummaryResponse(
      summary: summary.trim(),
      keyPoints: keyPoints,
      metadata: {
        'method': 'ai_openai',
        'model': 'gpt-3.5-turbo',
        'language': request.language,
      },
      confidence: 0.9,
      createdAt: DateTime.now(),
    );
  }

  static List<String> _splitIntoSentences(String text) {
    return text
        .split(RegExp(r'[.!?]+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty && s.length > 10)
        .toList();
  }

  static Map<int, double> _scoreSentences(
    List<String> sentences,
    SummaryRequest request,
  ) {
    final scores = <int, double>{};
    final keywords = _extractKeywords(request.content);

    for (int i = 0; i < sentences.length; i++) {
      double score = 0.0;
      final sentence = sentences[i].toLowerCase();

      // Position score (first and last sentences are often important)
      if (i == 0 || i == sentences.length - 1) {
        score += 0.3;
      }

      // Length score (prefer medium-length sentences)
      final words = sentence.split(' ').length;
      if (words >= 10 && words <= 30) {
        score += 0.2;
      }

      // Keyword score
      for (final keyword in keywords) {
        if (sentence.contains(keyword.toLowerCase())) {
          score += 0.1;
        }
      }

      // Academic indicators for prospectus content
      final academicTerms = [
        'course',
        'program',
        'degree',
        'requirement',
        'credit',
        'semester',
        'faculty',
      ];
      for (final term in academicTerms) {
        if (sentence.contains(term)) {
          score += 0.15;
        }
      }

      scores[i] = score;
    }

    return scores;
  }

  static List<String> _selectTopSentences(
    List<String> sentences,
    Map<int, double> scores,
    SummaryLength length,
  ) {
    final targetCount = switch (length) {
      SummaryLength.brief => 3,
      SummaryLength.medium => 5,
      SummaryLength.detailed => 8,
    };

    final sortedIndices = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final selectedIndices =
        sortedIndices.take(targetCount).map((e) => e.key).toList()..sort();

    return selectedIndices.map((i) => sentences[i]).toList();
  }

  static List<String> _extractKeywords(String text) {
    final words = text.toLowerCase().split(RegExp(r'\W+'));
    final wordFreq = <String, int>{};

    for (final word in words) {
      if (word.length > 3 && !_isStopWord(word)) {
        wordFreq[word] = (wordFreq[word] ?? 0) + 1;
      }
    }

    return wordFreq.entries
        .where((e) => e.value > 1)
        .map((e) => e.key)
        .take(10)
        .toList();
  }

  static List<String> _extractKeyPoints(String content, SummaryType type) {
    final keyPoints = <String>[];

    // Look for bullet points or numbered lists
    final bulletRegex = RegExp(r'^[\s]*[•\-*]\s*(.+)$', multiLine: true);
    final numberRegex = RegExp(r'^[\s]*\d+[\.\)]\s*(.+)$', multiLine: true);

    final bulletMatches = bulletRegex.allMatches(content);
    final numberMatches = numberRegex.allMatches(content);

    for (final match in bulletMatches) {
      keyPoints.add(match.group(1)?.trim() ?? '');
    }

    for (final match in numberMatches) {
      keyPoints.add(match.group(1)?.trim() ?? '');
    }

    // If no structured points found, extract based on type
    if (keyPoints.isEmpty) {
      keyPoints.addAll(_extractImplicitKeyPoints(content, type));
    }

    return keyPoints.take(5).toList();
  }

  static List<String> _extractImplicitKeyPoints(
    String content,
    SummaryType type,
  ) {
    final points = <String>[];

    switch (type) {
      case SummaryType.course:
        // Look for course-specific information
        if (content.toLowerCase().contains('prerequisite')) {
          points.add('Has prerequisite requirements');
        }
        if (content.toLowerCase().contains('credit')) {
          final creditMatch = RegExp(
            r'(\d+)\s*credit',
          ).firstMatch(content.toLowerCase());
          if (creditMatch != null) {
            points.add('${creditMatch.group(1)} credit hours');
          }
        }
        break;
      case SummaryType.academic:
        // Look for academic structure
        if (content.toLowerCase().contains('semester')) {
          points.add('Semester-based program');
        }
        if (content.toLowerCase().contains('internship')) {
          points.add('Includes internship component');
        }
        break;
      default:
        break;
    }

    return points;
  }

  static bool _isStopWord(String word) {
    const stopWords = {
      'the',
      'a',
      'an',
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
      'is',
      'are',
      'was',
      'were',
      'be',
      'been',
      'have',
      'has',
      'had',
      'do',
      'does',
      'did',
      'will',
      'would',
      'could',
      'should',
      'may',
      'might',
      'must',
      'can',
      'this',
      'that',
      'these',
      'those',
    };
    return stopWords.contains(word);
  }
}
