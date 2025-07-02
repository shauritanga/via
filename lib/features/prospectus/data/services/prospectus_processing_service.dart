import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/prospectus_models.dart';
import '../../../ai_services/data/models/summary_request.dart';
import '../../../ai_services/data/services/ai_summarization_service.dart';
import '../../../translation/data/models/translation_request.dart';
import '../../../translation/data/services/real_time_translation_service.dart';
import '../../../documents/data/services/simple_pdf_service.dart';

class ProspectusProcessingService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _prospectusCollection = 'prospectus_documents';

  /// Process a PDF document as a prospectus
  static Future<ProspectusDocument> processProspectusDocument({
    required String documentId,
    required String filePath,
    required String institutionName,
    String? academicYear,
    Function(double, String)? onProgress,
  }) async {
    try {
      onProgress?.call(0.1, 'Extracting PDF content...');

      // Extract content from PDF
      final documentContent = await SimplePDFService.extractTextFromPDF(
        filePath: filePath,
        documentId: documentId,
      );

      onProgress?.call(0.3, 'Analyzing document structure...');

      // Analyze and structure the content
      final structuredContent = _analyzeDocumentStructure(
        documentContent.content,
      );

      onProgress?.call(0.5, 'Extracting courses and programs...');

      // Extract courses and programs
      final courses = await _extractCourses(structuredContent);
      final programs = await _extractPrograms(structuredContent, courses);

      onProgress?.call(0.7, 'Generating summaries...');

      // Generate summaries for each section
      final sections = await _generateSectionSummaries(structuredContent);

      onProgress?.call(0.9, 'Creating prospectus document...');

      // Create prospectus document
      final prospectusId = _firestore
          .collection(_prospectusCollection)
          .doc()
          .id;
      final prospectus = ProspectusDocument(
        id: prospectusId,
        institutionId: _generateInstitutionId(institutionName),
        institutionName: institutionName,
        title: _extractTitle(structuredContent) ?? 'Academic Prospectus',
        academicYear: academicYear ?? _extractAcademicYear(structuredContent),
        publishedDate: DateTime.now(),
        originalDocumentId: documentId,
        sections: sections,
        courses: courses,
        programs: programs,
        metadata: {
          'totalPages': documentContent.totalPages,
          'processingDate': DateTime.now().toIso8601String(),
          'extractedSections': sections.length,
          'extractedCourses': courses.length,
          'extractedPrograms': programs.length,
        },
      );

      // Save to Firestore
      await _firestore
          .collection(_prospectusCollection)
          .doc(prospectusId)
          .set(prospectus.toJson());

      onProgress?.call(1.0, 'Prospectus processing completed!');

      debugPrint('Prospectus processed successfully: ${prospectus.title}');
      return prospectus;
    } catch (e) {
      debugPrint('Error processing prospectus: $e');
      rethrow;
    }
  }

  /// Get prospectus by institution
  static Future<List<ProspectusDocument>> getProspectusByInstitution(
    String institutionId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(_prospectusCollection)
          .where('institutionId', isEqualTo: institutionId)
          .where('isActive', isEqualTo: true)
          .orderBy('publishedDate', descending: true)
          .get();

      return snapshot.docs
          .map(
            (doc) => ProspectusDocument.fromJson({'id': doc.id, ...doc.data()}),
          )
          .toList();
    } catch (e) {
      debugPrint('Error getting prospectus by institution: $e');
      return [];
    }
  }

  /// Search courses in prospectus
  static Future<List<Course>> searchCourses({
    required String prospectusId,
    String? query,
    CourseLevel? level,
    String? department,
  }) async {
    try {
      final doc = await _firestore
          .collection(_prospectusCollection)
          .doc(prospectusId)
          .get();

      if (!doc.exists) return [];

      final prospectus = ProspectusDocument.fromJson({
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      });

      var courses = prospectus.courses;

      // Filter by level
      if (level != null) {
        courses = courses.where((c) => c.level == level).toList();
      }

      // Filter by department
      if (department != null) {
        courses = courses.where((c) => c.department == department).toList();
      }

      // Search by query
      if (query != null && query.isNotEmpty) {
        courses = courses.where((course) {
          final searchText =
              '${course.code} ${course.title} ${course.description}'
                  .toLowerCase();
          return searchText.contains(query.toLowerCase()) ||
              _calculateSimilarity(
                    course.title.toLowerCase(),
                    query.toLowerCase(),
                  ) >
                  0.3;
        }).toList();
      }

      return courses;
    } catch (e) {
      debugPrint('Error searching courses: $e');
      return [];
    }
  }

  /// Get course details with voice-friendly description
  static Future<Map<String, dynamic>> getCourseDetails({
    required String prospectusId,
    required String courseId,
    String language = 'en',
  }) async {
    try {
      final courses = await searchCourses(prospectusId: prospectusId);
      final course = courses.firstWhere((c) => c.id == courseId);

      // Generate voice-friendly description
      final voiceDescription = await _generateVoiceFriendlyDescription(
        course,
        language,
      );

      // Get prerequisites information
      final prerequisiteDetails = await _getPrerequisiteDetails(
        prospectusId,
        course.prerequisites,
      );

      return {
        'course': course,
        'voiceDescription': voiceDescription,
        'prerequisiteDetails': prerequisiteDetails,
        'relatedCourses': await _getRelatedCourses(prospectusId, course),
      };
    } catch (e) {
      debugPrint('Error getting course details: $e');
      return {};
    }
  }

  /// Translate prospectus content
  static Future<ProspectusDocument> translateProspectus({
    required String prospectusId,
    required String targetLanguage,
    Function(double, String)? onProgress,
  }) async {
    try {
      final doc = await _firestore
          .collection(_prospectusCollection)
          .doc(prospectusId)
          .get();

      if (!doc.exists) {
        throw Exception('Prospectus not found');
      }

      final prospectus = ProspectusDocument.fromJson({
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      });

      onProgress?.call(0.1, 'Preparing translation...');

      // Translate sections
      final translatedSections = <ProspectusSection, ProspectusContent>{};
      var progress = 0.1;
      final progressIncrement = 0.6 / prospectus.sections.length;

      for (final entry in prospectus.sections.entries) {
        final section = entry.key;
        final content = entry.value;

        onProgress?.call(progress, 'Translating ${section.name}...');

        final translationRequest = TranslationRequest(
          text: content.content,
          fromLanguage: 'en',
          toLanguage: targetLanguage,
          type: TranslationType.academic,
        );

        final translationResponse =
            await RealTimeTranslationService.translateText(translationRequest);

        final translatedContent = content.copyWith(
          translations: {
            ...content.translations,
            targetLanguage: translationResponse.translatedText,
          },
        );

        translatedSections[section] = translatedContent;
        progress += progressIncrement;
      }

      onProgress?.call(0.8, 'Translating courses...');

      // Translate courses
      final translatedCourses = <Course>[];
      for (final course in prospectus.courses) {
        final titleTranslation = await RealTimeTranslationService.translateText(
          TranslationRequest(
            text: course.title,
            fromLanguage: 'en',
            toLanguage: targetLanguage,
            type: TranslationType.academic,
          ),
        );

        final descriptionTranslation =
            await RealTimeTranslationService.translateText(
              TranslationRequest(
                text: course.description,
                fromLanguage: 'en',
                toLanguage: targetLanguage,
                type: TranslationType.academic,
              ),
            );

        final translatedCourse = course.copyWith(
          translations: {
            ...course.translations,
            '${targetLanguage}_title': titleTranslation.translatedText,
            '${targetLanguage}_description':
                descriptionTranslation.translatedText,
          },
        );

        translatedCourses.add(translatedCourse);
      }

      onProgress?.call(0.9, 'Finalizing translation...');

      // Create translated prospectus
      final translatedProspectus = prospectus.copyWith(
        sections: translatedSections,
        courses: translatedCourses,
        metadata: {
          ...prospectus.metadata,
          'translations': [
            ...(prospectus.metadata['translations'] as List? ?? []),
            targetLanguage,
          ],
          'lastTranslated': DateTime.now().toIso8601String(),
        },
      );

      // Update in Firestore
      await _firestore
          .collection(_prospectusCollection)
          .doc(prospectusId)
          .update(translatedProspectus.toJson());

      onProgress?.call(1.0, 'Translation completed!');

      debugPrint('Prospectus translated to $targetLanguage');
      return translatedProspectus;
    } catch (e) {
      debugPrint('Error translating prospectus: $e');
      rethrow;
    }
  }

  // Private helper methods

  static Map<String, dynamic> _analyzeDocumentStructure(String content) {
    final sections = <String, String>{};
    final lines = content.split('\n');

    String currentSection = 'overview';
    StringBuffer currentContent = StringBuffer();

    for (final line in lines) {
      final trimmedLine = line.trim();

      if (_isSectionHeader(trimmedLine)) {
        // Save previous section
        if (currentContent.isNotEmpty) {
          sections[currentSection] = currentContent.toString().trim();
        }

        // Start new section
        currentSection = _identifySection(trimmedLine);
        currentContent = StringBuffer();
      } else {
        currentContent.writeln(line);
      }
    }

    // Save last section
    if (currentContent.isNotEmpty) {
      sections[currentSection] = currentContent.toString().trim();
    }

    return {
      'sections': sections,
      'totalLines': lines.length,
      'identifiedSections': sections.keys.toList(),
    };
  }

  static bool _isSectionHeader(String line) {
    // Check for common section header patterns
    final headerPatterns = [
      RegExp(r'^[A-Z][A-Z\s]{2,}$'), // ALL CAPS
      RegExp(r'^\d+\.\s+[A-Z]'), // "1. Title"
      RegExp(r'^[A-Z][a-z\s]+:$'), // "Title:"
      RegExp(r'^[A-Z][a-z\s]+ Requirements$'), // "Admission Requirements"
    ];

    return headerPatterns.any((pattern) => pattern.hasMatch(line)) &&
        line.length < 100;
  }

  static String _identifySection(String header) {
    final headerLower = header.toLowerCase();

    if (headerLower.contains('admission') ||
        headerLower.contains('requirement')) {
      return 'admissionRequirements';
    } else if (headerLower.contains('course') ||
        headerLower.contains('curriculum')) {
      return 'courses';
    } else if (headerLower.contains('program') ||
        headerLower.contains('degree')) {
      return 'programs';
    } else if (headerLower.contains('fee') ||
        headerLower.contains('cost') ||
        headerLower.contains('tuition')) {
      return 'fees';
    } else if (headerLower.contains('scholarship') ||
        headerLower.contains('financial aid')) {
      return 'scholarships';
    } else if (headerLower.contains('facilit') ||
        headerLower.contains('campus')) {
      return 'facilities';
    } else if (headerLower.contains('faculty') ||
        headerLower.contains('staff')) {
      return 'faculty';
    } else if (headerLower.contains('calendar') ||
        headerLower.contains('schedule')) {
      return 'calendar';
    } else if (headerLower.contains('policy') ||
        headerLower.contains('regulation')) {
      return 'policies';
    } else if (headerLower.contains('contact') ||
        headerLower.contains('address')) {
      return 'contact';
    } else {
      return 'other';
    }
  }

  static Future<List<Course>> _extractCourses(
    Map<String, dynamic> structuredContent,
  ) async {
    final courses = <Course>[];
    final sections = structuredContent['sections'] as Map<String, String>;

    // Look for course information in relevant sections
    final courseSections = ['courses', 'programs', 'curriculum'];

    for (final sectionName in courseSections) {
      if (sections.containsKey(sectionName)) {
        final sectionContent = sections[sectionName]!;
        final extractedCourses = await _parseCourseContent(sectionContent);
        courses.addAll(extractedCourses);
      }
    }

    return courses;
  }

  static Future<List<Course>> _parseCourseContent(String content) async {
    final courses = <Course>[];
    final lines = content.split('\n');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      // Look for course code patterns (e.g., "CS101", "MATH 201", "ENG-101")
      final courseCodePattern = RegExp(
        r'^([A-Z]{2,4}[-\s]?\d{3,4})\s*[-:]?\s*(.+)$',
      );
      final match = courseCodePattern.firstMatch(line);

      if (match != null) {
        final courseCode = match.group(1)!.replaceAll(RegExp(r'[-\s]'), '');
        final titleAndDescription = match.group(2)!;

        // Extract title and description
        final parts = titleAndDescription.split('.');
        final title = parts.first.trim();
        final description = parts.length > 1
            ? parts.skip(1).join('.').trim()
            : title;

        // Extract credits (look for patterns like "3 credits", "(3)", "3 cr")
        final creditPattern = RegExp(r'(\d+)\s*(credit|cr|unit)s?|\((\d+)\)');
        final creditMatch = creditPattern.firstMatch(line);
        final credits = creditMatch != null
            ? int.tryParse(
                    creditMatch.group(1) ?? creditMatch.group(3) ?? '3',
                  ) ??
                  3
            : 3;

        final course = Course(
          id: courseCode,
          code: courseCode,
          title: title,
          description: description,
          level: _determineCourseLevel(courseCode),
          type: CourseType.core,
          credits: credits,
          prerequisites: [],
          corequisites: [],
          translations: {},
          metadata: {'extractedFromLine': i + 1, 'originalText': line},
        );

        courses.add(course);
      }
    }

    return courses;
  }

  static CourseLevel _determineCourseLevel(String courseCode) {
    final numberMatch = RegExp(r'\d+').firstMatch(courseCode);
    if (numberMatch != null) {
      final number = int.tryParse(numberMatch.group(0)!) ?? 100;
      if (number < 100) return CourseLevel.certificate;
      if (number < 200) return CourseLevel.diploma;
      if (number < 400) return CourseLevel.undergraduate;
      if (number < 600) return CourseLevel.postgraduate;
      return CourseLevel.doctoral;
    }
    return CourseLevel.undergraduate;
  }

  static Future<List<Program>> _extractPrograms(
    Map<String, dynamic> structuredContent,
    List<Course> courses,
  ) async {
    final programs = <Program>[];
    final sections = structuredContent['sections'] as Map<String, String>;

    // Look for program information
    if (sections.containsKey('programs')) {
      final programContent = sections['programs']!;
      final extractedPrograms = await _parseProgramContent(
        programContent,
        courses,
      );
      programs.addAll(extractedPrograms);
    }

    return programs;
  }

  static Future<List<Program>> _parseProgramContent(
    String content,
    List<Course> courses,
  ) async {
    final programs = <Program>[];

    // This is a simplified implementation
    // In a real app, you'd have more sophisticated program extraction logic

    final programPatterns = [
      RegExp(r'Bachelor\s+of\s+([A-Za-z\s]+)', caseSensitive: false),
      RegExp(r'Master\s+of\s+([A-Za-z\s]+)', caseSensitive: false),
      RegExp(r'Diploma\s+in\s+([A-Za-z\s]+)', caseSensitive: false),
      RegExp(r'Certificate\s+in\s+([A-Za-z\s]+)', caseSensitive: false),
    ];

    for (final pattern in programPatterns) {
      final matches = pattern.allMatches(content);
      for (final match in matches) {
        final programName = match.group(0)!;
        final field = match.group(1)!.trim();

        final level = _determineProgramLevel(programName);
        final duration = _estimateDuration(level);
        final totalCredits = _estimateCredits(level);

        final program = Program(
          id: programName.replaceAll(RegExp(r'\s+'), '_').toLowerCase(),
          name: programName,
          description: 'A comprehensive $programName program in $field',
          level: level,
          durationYears: duration,
          totalCredits: totalCredits,
          requiredCourses: courses
              .where((c) => c.level == level)
              .map((c) => c.id)
              .take(10)
              .toList(),
          electiveCourses: [],
          admissionRequirements: {},
          fees: {},
          translations: {},
          metadata: {'extractedField': field, 'originalText': programName},
        );

        programs.add(program);
      }
    }

    return programs;
  }

  static CourseLevel _determineProgramLevel(String programName) {
    final nameLower = programName.toLowerCase();
    if (nameLower.contains('certificate')) return CourseLevel.certificate;
    if (nameLower.contains('diploma')) return CourseLevel.diploma;
    if (nameLower.contains('bachelor')) return CourseLevel.undergraduate;
    if (nameLower.contains('master')) return CourseLevel.postgraduate;
    if (nameLower.contains('phd') || nameLower.contains('doctor')) {
      return CourseLevel.doctoral;
    }
    return CourseLevel.undergraduate;
  }

  static int _estimateDuration(CourseLevel level) {
    switch (level) {
      case CourseLevel.certificate:
        return 1;
      case CourseLevel.diploma:
        return 2;
      case CourseLevel.undergraduate:
        return 4;
      case CourseLevel.postgraduate:
        return 2;
      case CourseLevel.doctoral:
        return 4;
    }
  }

  static int _estimateCredits(CourseLevel level) {
    switch (level) {
      case CourseLevel.certificate:
        return 30;
      case CourseLevel.diploma:
        return 60;
      case CourseLevel.undergraduate:
        return 120;
      case CourseLevel.postgraduate:
        return 60;
      case CourseLevel.doctoral:
        return 90;
    }
  }

  static Future<Map<ProspectusSection, ProspectusContent>>
  _generateSectionSummaries(Map<String, dynamic> structuredContent) async {
    final sections = <ProspectusSection, ProspectusContent>{};
    final sectionData = structuredContent['sections'] as Map<String, String>;

    for (final entry in sectionData.entries) {
      final sectionName = entry.key;
      final content = entry.value;

      if (content.isNotEmpty) {
        // Generate summary
        final summaryRequest = SummaryRequest(
          content: content,
          length: SummaryLength.medium,
          type: SummaryType.academic,
          context: 'university prospectus section',
        );

        final summaryResponse = await AISummarizationService.summarizeContent(
          summaryRequest,
        );

        final section = ProspectusSection.values.firstWhere(
          (s) => s.name == sectionName,
          orElse: () => ProspectusSection.other,
        );

        final prospectusContent = ProspectusContent(
          section: section,
          title: _formatSectionTitle(sectionName),
          content: content,
          summary: summaryResponse.summary,
          keyPoints: summaryResponse.keyPoints,
          translations: {},
          pageNumber: 1, // TODO: Extract actual page numbers
          metadata: {
            'wordCount': content.split(' ').length,
            'summaryConfidence': summaryResponse.confidence,
          },
        );

        sections[section] = prospectusContent;
      }
    }

    return sections;
  }

  static String _formatSectionTitle(String sectionName) {
    return sectionName
        .split(RegExp(r'(?=[A-Z])'))
        .map(
          (word) =>
              word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1),
        )
        .join(' ')
        .trim();
  }

  static String? _extractTitle(Map<String, dynamic> structuredContent) {
    final sections = structuredContent['sections'] as Map<String, String>;

    // Look for title in overview section
    if (sections.containsKey('overview')) {
      final overview = sections['overview']!;
      final lines = overview.split('\n');

      for (final line in lines.take(5)) {
        final trimmed = line.trim();
        if (trimmed.isNotEmpty &&
            trimmed.length > 10 &&
            trimmed.length < 100 &&
            !trimmed.contains('©') &&
            !trimmed.contains('www.')) {
          return trimmed;
        }
      }
    }

    return null;
  }

  static String _extractAcademicYear(Map<String, dynamic> structuredContent) {
    final sections = structuredContent['sections'] as Map<String, String>;
    final currentYear = DateTime.now().year;

    // Look for year patterns in the content
    final yearPattern = RegExp(r'20\d{2}[-/]20\d{2}|20\d{2}');

    for (final content in sections.values) {
      final match = yearPattern.firstMatch(content);
      if (match != null) {
        return match.group(0)!;
      }
    }

    // Default to current academic year
    return '$currentYear-${currentYear + 1}';
  }

  static String _generateInstitutionId(String institutionName) {
    return institutionName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }

  static Future<String> _generateVoiceFriendlyDescription(
    Course course,
    String language,
  ) async {
    final description =
        '''
Course: ${course.title}
Code: ${course.code}
Credits: ${course.credits}
Level: ${course.level.name}
Description: ${course.description}
${course.prerequisites.isNotEmpty ? 'Prerequisites: ${course.prerequisites.join(', ')}' : ''}
''';

    if (language != 'en') {
      final translationRequest = TranslationRequest(
        text: description,
        fromLanguage: 'en',
        toLanguage: language,
        type: TranslationType.academic,
      );

      final translation = await RealTimeTranslationService.translateText(
        translationRequest,
      );
      return translation.translatedText;
    }

    return description;
  }

  static Future<List<Course>> _getPrerequisiteDetails(
    String prospectusId,
    List<String> prerequisites,
  ) async {
    if (prerequisites.isEmpty) return [];

    final courses = await searchCourses(prospectusId: prospectusId);
    return courses.where((c) => prerequisites.contains(c.code)).toList();
  }

  static Future<List<Course>> _getRelatedCourses(
    String prospectusId,
    Course course,
  ) async {
    final courses = await searchCourses(prospectusId: prospectusId);

    return courses
        .where(
          (c) =>
              c.id != course.id &&
              (c.department == course.department ||
                  c.level == course.level ||
                  c.code.substring(0, 2) == course.code.substring(0, 2)),
        )
        .take(5)
        .toList();
  }

  /// Simple string similarity calculation
  static double _calculateSimilarity(String a, String b) {
    if (a == b) return 1.0;
    if (a.isEmpty || b.isEmpty) return 0.0;

    // Simple character-based similarity
    final longer = a.length > b.length ? a : b;
    final shorter = a.length > b.length ? b : a;

    if (longer.isEmpty) return 1.0;

    final editDistance = _levenshteinDistance(longer, shorter);
    return (longer.length - editDistance) / longer.length;
  }

  /// Calculate Levenshtein distance between two strings
  static int _levenshteinDistance(String a, String b) {
    final matrix = List.generate(
      a.length + 1,
      (i) => List.generate(b.length + 1, (j) => 0),
    );

    for (int i = 0; i <= a.length; i++) {
      matrix[i][0] = i;
    }

    for (int j = 0; j <= b.length; j++) {
      matrix[0][j] = j;
    }

    for (int i = 1; i <= a.length; i++) {
      for (int j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1, // deletion
          matrix[i][j - 1] + 1, // insertion
          matrix[i - 1][j - 1] + cost, // substitution
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return matrix[a.length][b.length];
  }
}
