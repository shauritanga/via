import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/document_content.dart';

class DocumentContentModel extends DocumentContent {
  const DocumentContentModel({
    required super.documentId,
    required super.pages,
    required super.fullText,
    required super.metadata,
  });

  factory DocumentContentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DocumentContentModel(
      documentId: doc.id,
      pages:
          (data['pages'] as List<dynamic>?)
              ?.map(
                (page) =>
                    PageContentModel.fromMap(page as Map<String, dynamic>),
              )
              .toList() ??
          [],
      fullText: data['fullText'] ?? '',
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  factory DocumentContentModel.fromJson(Map<String, dynamic> json) {
    return DocumentContentModel(
      documentId: json['documentId'] ?? '',
      pages:
          (json['pages'] as List<dynamic>?)
              ?.map(
                (page) =>
                    PageContentModel.fromMap(page as Map<String, dynamic>),
              )
              .toList() ??
          [],
      fullText: json['fullText'] ?? '',
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  factory DocumentContentModel.fromEntity(DocumentContent content) {
    return DocumentContentModel(
      documentId: content.documentId,
      pages: content.pages,
      fullText: content.fullText,
      metadata: content.metadata,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'pages': pages.map((page) => (page as PageContentModel).toMap()).toList(),
      'fullText': fullText,
      'metadata': metadata,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'documentId': documentId,
      'pages': pages.map((page) => (page as PageContentModel).toMap()).toList(),
      'fullText': fullText,
      'metadata': metadata,
    };
  }
}

class PageContentModel extends PageContent {
  const PageContentModel({
    required super.pageNumber,
    required super.text,
    required super.sections,
  });

  factory PageContentModel.fromMap(Map<String, dynamic> map) {
    return PageContentModel(
      pageNumber: map['pageNumber'] ?? 0,
      text: map['text'] ?? '',
      sections:
          (map['sections'] as List<dynamic>?)
              ?.map(
                (section) =>
                    SectionModel.fromMap(section as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pageNumber': pageNumber,
      'text': text,
      'sections': sections
          .map((section) => (section as SectionModel).toMap())
          .toList(),
    };
  }
}

class SectionModel extends Section {
  const SectionModel({
    required super.title,
    required super.content,
    required super.startPosition,
    required super.endPosition,
    required super.type,
  });

  factory SectionModel.fromMap(Map<String, dynamic> map) {
    return SectionModel(
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      startPosition: map['startPosition'] ?? 0,
      endPosition: map['endPosition'] ?? 0,
      type: SectionType.values.firstWhere(
        (type) => type.toString() == map['type'],
        orElse: () => SectionType.other,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'startPosition': startPosition,
      'endPosition': endPosition,
      'type': type.toString(),
    };
  }
}
