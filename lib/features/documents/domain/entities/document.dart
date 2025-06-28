import 'package:equatable/equatable.dart';

class Document extends Equatable {
  final String id;
  final String title;
  final String fileName;
  final String filePath;
  final String downloadUrl;
  final int sizeInBytes;
  final DateTime uploadedAt;
  final DateTime lastAccessedAt;
  final String userId;
  final List<String> tags;
  final String description;
  final int totalPages;
  final String language;

  const Document({
    required this.id,
    required this.title,
    required this.fileName,
    required this.filePath,
    required this.downloadUrl,
    required this.sizeInBytes,
    required this.uploadedAt,
    required this.lastAccessedAt,
    required this.userId,
    required this.tags,
    required this.description,
    required this.totalPages,
    required this.language,
  });

  @override
  List<Object> get props => [
        id,
        title,
        fileName,
        filePath,
        downloadUrl,
        sizeInBytes,
        uploadedAt,
        lastAccessedAt,
        userId,
        tags,
        description,
        totalPages,
        language,
      ];

  Document copyWith({
    String? id,
    String? title,
    String? fileName,
    String? filePath,
    String? downloadUrl,
    int? sizeInBytes,
    DateTime? uploadedAt,
    DateTime? lastAccessedAt,
    String? userId,
    List<String>? tags,
    String? description,
    int? totalPages,
    String? language,
  }) {
    return Document(
      id: id ?? this.id,
      title: title ?? this.title,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      sizeInBytes: sizeInBytes ?? this.sizeInBytes,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      userId: userId ?? this.userId,
      tags: tags ?? this.tags,
      description: description ?? this.description,
      totalPages: totalPages ?? this.totalPages,
      language: language ?? this.language,
    );
  }
}
