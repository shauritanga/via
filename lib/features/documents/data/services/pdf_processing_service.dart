import 'dart:io';
import 'package:pdfx/pdfx.dart' as pdfx;
import '../../../../core/errors/failures.dart';
import '../../domain/entities/document_content.dart';

class PDFProcessingService {
  static const int maxFileSizeBytes = 50 * 1024 * 1024; // 50MB
  static const List<String> supportedExtensions = ['.pdf'];

  /// Validates if the file is a supported PDF
  static bool isValidPDFFile(String filePath) {
    final file = File(filePath);
    if (!file.existsSync()) return false;

    final extension = filePath.toLowerCase().split('.').last;
    if (!supportedExtensions.contains('.$extension')) return false;

    if (file.lengthSync() > maxFileSizeBytes) return false;

    return true;
  }

  /// Extracts text content and structure from PDF
  static Future<DocumentContent> extractContentFromPDF({
    required String filePath,
    required String documentId,
  }) async {
    try {
      if (!isValidPDFFile(filePath)) {
        throw const DocumentParsingFailure('Invalid PDF file');
      }

      final document = await pdfx.PdfDocument.openFile(filePath);
      final pageCount = document.pagesCount;

      final pages = <PageContent>[];
      final fullTextBuffer = StringBuffer();

      for (int i = 1; i <= pageCount; i++) {
        final page = await document.getPage(i);

        // For now, create placeholder text since pdfx doesn't have direct text extraction
        final extractedText =
            'Page $i content - Text extraction not implemented yet';

        // Parse sections within the page
        final sections = _parseSectionsFromText(extractedText, i);

        final pageContent = PageContent(
          pageNumber: i,
          text: extractedText,
          sections: sections,
        );

        pages.add(pageContent);
        fullTextBuffer.write(extractedText);
        if (i < pageCount) fullTextBuffer.write('\n\n');

        await page.close();
      }

      await document.close();

      return DocumentContent(
        documentId: documentId,
        pages: pages,
        fullText: fullTextBuffer.toString(),
        metadata: {
          'totalPages': pageCount,
          'extractedAt': DateTime.now().toIso8601String(),
          'processingVersion': '1.0',
        },
      );
    } catch (e) {
      if (e is Failure) rethrow;
      throw DocumentParsingFailure('Failed to extract PDF content: $e');
    }
  }

  /// Parses sections from extracted text
  static List<Section> _parseSectionsFromText(String text, int pageNumber) {
    final sections = <Section>[];

    if (text.isEmpty) return sections;

    // Split text into paragraphs
    final paragraphs = text
        .split('\n\n')
        .where((p) => p.trim().isNotEmpty)
        .toList();

    int currentPosition = 0;

    for (int i = 0; i < paragraphs.length; i++) {
      final paragraph = paragraphs[i].trim();
      if (paragraph.isEmpty) continue;

      final sectionType = _determineSectionType(paragraph);
      final title = _extractSectionTitle(paragraph, sectionType);

      final section = Section(
        title: title,
        content: paragraph,
        startPosition: currentPosition,
        endPosition: currentPosition + paragraph.length,
        type: sectionType,
      );

      sections.add(section);
      currentPosition += paragraph.length + 2; // +2 for \n\n
    }

    return sections;
  }

  /// Determines the type of section based on content
  static SectionType _determineSectionType(String text) {
    final trimmedText = text.trim();

    // Check for headings (simple heuristics)
    if (_isHeading(trimmedText)) {
      return SectionType.heading;
    }

    // Check for lists
    if (_isList(trimmedText)) {
      return SectionType.list;
    }

    // Check for tables (basic detection)
    if (_isTable(trimmedText)) {
      return SectionType.table;
    }

    // Default to paragraph
    return SectionType.paragraph;
  }

  /// Checks if text is likely a heading
  static bool _isHeading(String text) {
    // Heuristics for heading detection
    if (text.length < 5 || text.length > 100) return false;

    // Check for common heading patterns
    if (RegExp(r'^\d+\.?\s+[A-Z]').hasMatch(text)) {
      return true; // "1. Title" or "1 Title"
    }
    if (RegExp(r'^[A-Z][A-Z\s]{2,}$').hasMatch(text)) {
      return true; // "ALL CAPS TITLE"
    }
    if (RegExp(r'^[A-Z][a-z\s]+$').hasMatch(text) &&
        text.split(' ').length <= 8) {
      return true; // "Title Case"
    }

    return false;
  }

  /// Checks if text is likely a list
  static bool _isList(String text) {
    final lines = text.split('\n');
    if (lines.length < 2) return false;

    int listItems = 0;
    for (final line in lines) {
      final trimmed = line.trim();
      if (RegExp(r'^[-•*]\s+').hasMatch(trimmed) || // Bullet points
          RegExp(r'^\d+\.?\s+').hasMatch(trimmed) || // Numbered lists
          RegExp(r'^[a-zA-Z]\.?\s+').hasMatch(trimmed)) {
        // Lettered lists
        listItems++;
      }
    }

    return listItems >=
        lines.length * 0.5; // At least 50% of lines are list items
  }

  /// Checks if text is likely a table
  static bool _isTable(String text) {
    final lines = text.split('\n');
    if (lines.length < 2) return false;

    // Look for consistent column separators
    int tabSeparatedLines = 0;
    int pipeSeparatedLines = 0;

    for (final line in lines) {
      if (line.contains('\t') && line.split('\t').length > 2) {
        tabSeparatedLines++;
      }
      if (line.contains('|') && line.split('|').length > 2) {
        pipeSeparatedLines++;
      }
    }

    return (tabSeparatedLines >= lines.length * 0.5) ||
        (pipeSeparatedLines >= lines.length * 0.5);
  }

  /// Extracts title from section content
  static String _extractSectionTitle(String content, SectionType type) {
    switch (type) {
      case SectionType.heading:
        // For headings, the entire content is usually the title
        return content.trim();
      case SectionType.list:
        // For lists, use the first line or a generic title
        final firstLine = content.split('\n').first.trim();
        return firstLine.length > 50 ? 'List' : firstLine;
      case SectionType.table:
        return 'Table';
      case SectionType.paragraph:
        // For paragraphs, use the first few words
        final words = content.trim().split(' ');
        if (words.length <= 5) return content.trim();
        return '${words.take(5).join(' ')}...';
      default:
        return 'Section';
    }
  }

  /// Gets PDF metadata
  static Future<Map<String, dynamic>> getPDFMetadata(String filePath) async {
    try {
      final document = await pdfx.PdfDocument.openFile(filePath);
      final pageCount = document.pagesCount;

      // Get first page to estimate content
      final firstPage = await document.getPage(1);
      // Placeholder text since pdfx doesn't have direct text extraction
      final extractedText = 'Sample PDF content for metadata estimation';

      await firstPage.close();
      await document.close();

      // Estimate reading time (average 200 words per minute)
      final wordCount = extractedText.split(' ').length * pageCount;
      final estimatedReadingTimeMinutes = (wordCount / 200).ceil();

      return {
        'pageCount': pageCount,
        'estimatedWordCount': wordCount,
        'estimatedReadingTimeMinutes': estimatedReadingTimeMinutes,
        'hasText': extractedText.isNotEmpty,
        'language': _detectLanguage(extractedText),
      };
    } catch (e) {
      throw DocumentParsingFailure('Failed to get PDF metadata: $e');
    }
  }

  /// Simple language detection
  static String _detectLanguage(String text) {
    if (text.isEmpty) return 'unknown';

    // Simple heuristics for English vs Swahili
    final swahiliWords = [
      'na',
      'ya',
      'wa',
      'za',
      'la',
      'kwa',
      'ni',
      'si',
      'hii',
      'hiyo',
    ];
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
    ];

    final words = text.toLowerCase().split(' ').take(100).toList();

    int swahiliCount = 0;
    int englishCount = 0;

    for (final word in words) {
      if (swahiliWords.contains(word)) swahiliCount++;
      if (englishWords.contains(word)) englishCount++;
    }

    if (swahiliCount > englishCount) return 'sw';
    if (englishCount > swahiliCount) return 'en';

    return 'en'; // Default to English
  }

  /// Validates PDF file integrity
  static Future<bool> validatePDFIntegrity(String filePath) async {
    try {
      final document = await pdfx.PdfDocument.openFile(filePath);
      final pageCount = document.pagesCount;

      if (pageCount <= 0) {
        await document.close();
        return false;
      }

      // Try to access first and last page
      final firstPage = await document.getPage(1);
      await firstPage.close();

      if (pageCount > 1) {
        final lastPage = await document.getPage(pageCount);
        await lastPage.close();
      }

      await document.close();
      return true;
    } catch (e) {
      return false;
    }
  }
}
