import 'package:equatable/equatable.dart';

class DocumentContent extends Equatable {
  final String documentId;
  final List<PageContent> pages;
  final String fullText;
  final Map<String, dynamic> metadata;

  const DocumentContent({
    required this.documentId,
    required this.pages,
    required this.fullText,
    required this.metadata,
  });

  @override
  List<Object> get props => [documentId, pages, fullText, metadata];

  DocumentContent copyWith({
    String? documentId,
    List<PageContent>? pages,
    String? fullText,
    Map<String, dynamic>? metadata,
  }) {
    return DocumentContent(
      documentId: documentId ?? this.documentId,
      pages: pages ?? this.pages,
      fullText: fullText ?? this.fullText,
      metadata: metadata ?? this.metadata,
    );
  }
}

class PageContent extends Equatable {
  final int pageNumber;
  final String text;
  final List<Section> sections;

  const PageContent({
    required this.pageNumber,
    required this.text,
    required this.sections,
  });

  @override
  List<Object> get props => [pageNumber, text, sections];

  PageContent copyWith({
    int? pageNumber,
    String? text,
    List<Section>? sections,
  }) {
    return PageContent(
      pageNumber: pageNumber ?? this.pageNumber,
      text: text ?? this.text,
      sections: sections ?? this.sections,
    );
  }
}

class Section extends Equatable {
  final String title;
  final String content;
  final int startPosition;
  final int endPosition;
  final SectionType type;

  const Section({
    required this.title,
    required this.content,
    required this.startPosition,
    required this.endPosition,
    required this.type,
  });

  @override
  List<Object> get props => [title, content, startPosition, endPosition, type];

  Section copyWith({
    String? title,
    String? content,
    int? startPosition,
    int? endPosition,
    SectionType? type,
  }) {
    return Section(
      title: title ?? this.title,
      content: content ?? this.content,
      startPosition: startPosition ?? this.startPosition,
      endPosition: endPosition ?? this.endPosition,
      type: type ?? this.type,
    );
  }
}

enum SectionType {
  heading,
  paragraph,
  list,
  table,
  image,
  other,
}
