import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/document.dart';

class DocumentModel extends Document {
  const DocumentModel({
    required super.id,
    required super.title,
    required super.fileName,
    required super.filePath,
    required super.downloadUrl,
    required super.sizeInBytes,
    required super.uploadedAt,
    required super.lastAccessedAt,
    required super.userId,
    required super.tags,
    required super.description,
    required super.totalPages,
    required super.language,
  });

  factory DocumentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DocumentModel(
      id: doc.id,
      title: data['title'] ?? '',
      fileName: data['fileName'] ?? '',
      filePath: data['filePath'] ?? '',
      downloadUrl: data['downloadUrl'] ?? '',
      sizeInBytes: data['sizeInBytes'] ?? 0,
      uploadedAt: (data['uploadedAt'] as Timestamp).toDate(),
      lastAccessedAt: (data['lastAccessedAt'] as Timestamp).toDate(),
      userId: data['userId'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      description: data['description'] ?? '',
      totalPages: data['totalPages'] ?? 0,
      language: data['language'] ?? 'en',
    );
  }

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      fileName: json['fileName'] ?? '',
      filePath: json['filePath'] ?? '',
      downloadUrl: json['downloadUrl'] ?? '',
      sizeInBytes: json['sizeInBytes'] ?? 0,
      uploadedAt: json['uploadedAt'] != null
          ? DateTime.parse(json['uploadedAt'])
          : DateTime.now(),
      lastAccessedAt: json['lastAccessedAt'] != null
          ? DateTime.parse(json['lastAccessedAt'])
          : DateTime.now(),
      userId: json['userId'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      description: json['description'] ?? '',
      totalPages: json['totalPages'] ?? 0,
      language: json['language'] ?? 'en',
    );
  }

  factory DocumentModel.fromEntity(Document document) {
    return DocumentModel(
      id: document.id,
      title: document.title,
      fileName: document.fileName,
      filePath: document.filePath,
      downloadUrl: document.downloadUrl,
      sizeInBytes: document.sizeInBytes,
      uploadedAt: document.uploadedAt,
      lastAccessedAt: document.lastAccessedAt,
      userId: document.userId,
      tags: document.tags,
      description: document.description,
      totalPages: document.totalPages,
      language: document.language,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'fileName': fileName,
      'filePath': filePath,
      'downloadUrl': downloadUrl,
      'sizeInBytes': sizeInBytes,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
      'lastAccessedAt': Timestamp.fromDate(lastAccessedAt),
      'userId': userId,
      'tags': tags,
      'description': description,
      'totalPages': totalPages,
      'language': language,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'fileName': fileName,
      'filePath': filePath,
      'downloadUrl': downloadUrl,
      'sizeInBytes': sizeInBytes,
      'uploadedAt': uploadedAt.toIso8601String(),
      'lastAccessedAt': lastAccessedAt.toIso8601String(),
      'userId': userId,
      'tags': tags,
      'description': description,
      'totalPages': totalPages,
      'language': language,
    };
  }

  @override
  @override
  DocumentModel copyWith({
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
    return DocumentModel(
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
