import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../documents/domain/entities/document_content.dart';
import '../entities/voice_command.dart';
import '../repositories/voice_repository.dart';

class ReadDocumentContent implements UseCase<void, ReadDocumentContentParams> {
  final VoiceRepository voiceRepository;

  ReadDocumentContent(this.voiceRepository);

  @override
  Future<Either<Failure, void>> call(ReadDocumentContentParams params) async {
    try {
      String textToRead = '';

      switch (params.readingMode) {
        case ReadingMode.fullDocument:
          textToRead = params.documentContent.fullText;
          break;
        case ReadingMode.currentPage:
          if (params.pageNumber != null && 
              params.pageNumber! > 0 && 
              params.pageNumber! <= params.documentContent.pages.length) {
            final page = params.documentContent.pages[params.pageNumber! - 1];
            textToRead = page.text;
          } else {
            return const Left(DocumentNotFoundFailure('Invalid page number'));
          }
          break;
        case ReadingMode.specificSection:
          if (params.sectionName != null) {
            final section = _findSection(params.documentContent, params.sectionName!);
            if (section != null) {
              textToRead = section.content;
            } else {
              return const Left(DocumentNotFoundFailure('Section not found'));
            }
          } else {
            return const Left(DocumentNotFoundFailure('Section name not provided'));
          }
          break;
        case ReadingMode.pageRange:
          if (params.startPage != null && params.endPage != null) {
            textToRead = _getPageRangeText(
              params.documentContent, 
              params.startPage!, 
              params.endPage!,
            );
          } else {
            return const Left(DocumentNotFoundFailure('Page range not provided'));
          }
          break;
      }

      if (textToRead.isEmpty) {
        return const Left(DocumentNotFoundFailure('No content to read'));
      }

      // Apply reading preferences
      textToRead = _processTextForReading(textToRead, params.readingPreferences);

      return await voiceRepository.speakText(
        text: textToRead,
        language: params.language,
        settings: params.ttsSettings,
      );
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(TextToSpeechFailure('Failed to read document content: $e'));
    }
  }

  Section? _findSection(DocumentContent content, String sectionName) {
    final normalizedSectionName = sectionName.toLowerCase().trim();
    
    for (final page in content.pages) {
      for (final section in page.sections) {
        if (section.title.toLowerCase().contains(normalizedSectionName) ||
            normalizedSectionName.contains(section.title.toLowerCase())) {
          return section;
        }
      }
    }
    return null;
  }

  String _getPageRangeText(DocumentContent content, int startPage, int endPage) {
    final buffer = StringBuffer();
    final validStartPage = startPage.clamp(1, content.pages.length);
    final validEndPage = endPage.clamp(validStartPage, content.pages.length);

    for (int i = validStartPage - 1; i < validEndPage; i++) {
      if (i > validStartPage - 1) {
        buffer.write('\n\n'); // Page separator
      }
      buffer.write(content.pages[i].text);
    }

    return buffer.toString();
  }

  String _processTextForReading(String text, ReadingPreferences? preferences) {
    if (preferences == null) return text;

    String processedText = text;

    // Remove excessive whitespace
    processedText = processedText.replaceAll(RegExp(r'\s+'), ' ');

    // Add pauses for punctuation if enabled
    if (preferences.addPausesForPunctuation) {
      processedText = processedText.replaceAll('.', '. ');
      processedText = processedText.replaceAll(',', ', ');
      processedText = processedText.replaceAll(';', '; ');
      processedText = processedText.replaceAll(':', ': ');
    }

    // Skip certain elements if requested
    if (preferences.skipPageNumbers) {
      processedText = processedText.replaceAll(RegExp(r'Page \d+'), '');
      processedText = processedText.replaceAll(RegExp(r'\d+'), '');
    }

    if (preferences.skipFootnotes) {
      processedText = processedText.replaceAll(RegExp(r'\[\d+\]'), '');
      processedText = processedText.replaceAll(RegExp(r'\(\d+\)'), '');
    }

    // Spell out abbreviations if enabled
    if (preferences.spellOutAbbreviations) {
      processedText = _expandAbbreviations(processedText, preferences.language);
    }

    return processedText.trim();
  }

  String _expandAbbreviations(String text, String language) {
    final abbreviations = _getAbbreviations(language);
    
    String expandedText = text;
    abbreviations.forEach((abbrev, expansion) {
      expandedText = expandedText.replaceAll(
        RegExp(r'\b' + RegExp.escape(abbrev) + r'\b', caseSensitive: false),
        expansion,
      );
    });

    return expandedText;
  }

  Map<String, String> _getAbbreviations(String language) {
    if (language == 'sw') {
      return {
        'Dr.': 'Daktari',
        'Prof.': 'Profesa',
        'Mr.': 'Bwana',
        'Mrs.': 'Bi',
        'Ms.': 'Bi',
        'Ltd.': 'Limited',
        'Co.': 'Company',
        'Inc.': 'Incorporated',
        'etc.': 'na kadhalika',
        'vs.': 'dhidi ya',
        'i.e.': 'yaani',
        'e.g.': 'kwa mfano',
      };
    } else {
      return {
        'Dr.': 'Doctor',
        'Prof.': 'Professor',
        'Mr.': 'Mister',
        'Mrs.': 'Missus',
        'Ms.': 'Miss',
        'Ltd.': 'Limited',
        'Co.': 'Company',
        'Inc.': 'Incorporated',
        'etc.': 'et cetera',
        'vs.': 'versus',
        'i.e.': 'that is',
        'e.g.': 'for example',
        'CEO': 'Chief Executive Officer',
        'CFO': 'Chief Financial Officer',
        'CTO': 'Chief Technology Officer',
        'USA': 'United States of America',
        'UK': 'United Kingdom',
        'EU': 'European Union',
      };
    }
  }
}

class ReadDocumentContentParams extends Equatable {
  final DocumentContent documentContent;
  final ReadingMode readingMode;
  final String language;
  final TTSSettings? ttsSettings;
  final ReadingPreferences? readingPreferences;
  final int? pageNumber;
  final String? sectionName;
  final int? startPage;
  final int? endPage;

  const ReadDocumentContentParams({
    required this.documentContent,
    required this.readingMode,
    required this.language,
    this.ttsSettings,
    this.readingPreferences,
    this.pageNumber,
    this.sectionName,
    this.startPage,
    this.endPage,
  });

  @override
  List<Object?> get props => [
        documentContent,
        readingMode,
        language,
        ttsSettings,
        readingPreferences,
        pageNumber,
        sectionName,
        startPage,
        endPage,
      ];
}

enum ReadingMode {
  fullDocument,
  currentPage,
  specificSection,
  pageRange,
}

class ReadingPreferences extends Equatable {
  final bool addPausesForPunctuation;
  final bool skipPageNumbers;
  final bool skipFootnotes;
  final bool spellOutAbbreviations;
  final bool announcePageNumbers;
  final bool announceSectionTitles;
  final String language;
  final double readingSpeed;

  const ReadingPreferences({
    this.addPausesForPunctuation = true,
    this.skipPageNumbers = true,
    this.skipFootnotes = false,
    this.spellOutAbbreviations = true,
    this.announcePageNumbers = true,
    this.announceSectionTitles = true,
    required this.language,
    this.readingSpeed = 1.0,
  });

  @override
  List<Object> get props => [
        addPausesForPunctuation,
        skipPageNumbers,
        skipFootnotes,
        spellOutAbbreviations,
        announcePageNumbers,
        announceSectionTitles,
        language,
        readingSpeed,
      ];

  ReadingPreferences copyWith({
    bool? addPausesForPunctuation,
    bool? skipPageNumbers,
    bool? skipFootnotes,
    bool? spellOutAbbreviations,
    bool? announcePageNumbers,
    bool? announceSectionTitles,
    String? language,
    double? readingSpeed,
  }) {
    return ReadingPreferences(
      addPausesForPunctuation: addPausesForPunctuation ?? this.addPausesForPunctuation,
      skipPageNumbers: skipPageNumbers ?? this.skipPageNumbers,
      skipFootnotes: skipFootnotes ?? this.skipFootnotes,
      spellOutAbbreviations: spellOutAbbreviations ?? this.spellOutAbbreviations,
      announcePageNumbers: announcePageNumbers ?? this.announcePageNumbers,
      announceSectionTitles: announceSectionTitles ?? this.announceSectionTitles,
      language: language ?? this.language,
      readingSpeed: readingSpeed ?? this.readingSpeed,
    );
  }
}
