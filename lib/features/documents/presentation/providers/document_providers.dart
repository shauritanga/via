import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/dependency_injection.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/document.dart';
import '../../domain/entities/document_content.dart';
import '../../domain/usecases/get_documents.dart';
import '../../domain/usecases/get_document_content.dart';
import '../../domain/usecases/delete_document.dart';
import '../../domain/usecases/upload_and_process_document.dart';

// Document list state
enum DocumentListState { loading, loaded, error, empty }

class DocumentListData {
  final DocumentListState state;
  final List<Document> documents;
  final String? errorMessage;
  final DateTime? lastUpdated;

  const DocumentListData({
    required this.state,
    this.documents = const [],
    this.errorMessage,
    this.lastUpdated,
  });

  DocumentListData copyWith({
    DocumentListState? state,
    List<Document>? documents,
    String? errorMessage,
    DateTime? lastUpdated,
  }) {
    return DocumentListData(
      state: state ?? this.state,
      documents: documents ?? this.documents,
      errorMessage: errorMessage ?? this.errorMessage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

// Document list notifier
class DocumentListNotifier extends StateNotifier<DocumentListData> {
  final GetDocuments _getDocuments;
  final DeleteDocument _deleteDocument;

  DocumentListNotifier(this._getDocuments, this._deleteDocument)
    : super(const DocumentListData(state: DocumentListState.loading)) {
    loadDocuments();
  }

  Future<void> loadDocuments() async {
    try {
      state = state.copyWith(
        state: DocumentListState.loading,
        errorMessage: null,
      );

      final result = await _getDocuments(NoParams());

      result.fold(
        (failure) {
          state = state.copyWith(
            state: DocumentListState.error,
            errorMessage: failure.toString(),
          );
        },
        (documents) {
          state = state.copyWith(
            state: documents.isEmpty
                ? DocumentListState.empty
                : DocumentListState.loaded,
            documents: documents,
            lastUpdated: DateTime.now(),
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        state: DocumentListState.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> deleteDocument(String documentId) async {
    try {
      final result = await _deleteDocument(
        DeleteDocumentParams(documentId: documentId),
      );

      result.fold(
        (failure) {
          state = state.copyWith(
            state: DocumentListState.error,
            errorMessage: failure.toString(),
          );
        },
        (_) {
          // Remove the document from the list
          final updatedDocuments = state.documents
              .where((doc) => doc.id != documentId)
              .toList();

          state = state.copyWith(
            documents: updatedDocuments,
            state: updatedDocuments.isEmpty
                ? DocumentListState.empty
                : DocumentListState.loaded,
            lastUpdated: DateTime.now(),
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        state: DocumentListState.error,
        errorMessage: e.toString(),
      );
    }
  }

  void clearError() {
    if (state.state == DocumentListState.error) {
      state = state.copyWith(
        state: state.documents.isEmpty
            ? DocumentListState.empty
            : DocumentListState.loaded,
        errorMessage: null,
      );
    }
  }

  void refresh() {
    loadDocuments();
  }
}

// Upload state
enum UploadState { idle, uploading, processing, completed, error }

class UploadData {
  final UploadState state;
  final double progress;
  final String? statusMessage;
  final String? errorMessage;
  final Document? uploadedDocument;

  const UploadData({
    required this.state,
    this.progress = 0.0,
    this.statusMessage,
    this.errorMessage,
    this.uploadedDocument,
  });

  UploadData copyWith({
    UploadState? state,
    double? progress,
    String? statusMessage,
    String? errorMessage,
    Document? uploadedDocument,
  }) {
    return UploadData(
      state: state ?? this.state,
      progress: progress ?? this.progress,
      statusMessage: statusMessage ?? this.statusMessage,
      errorMessage: errorMessage ?? this.errorMessage,
      uploadedDocument: uploadedDocument ?? this.uploadedDocument,
    );
  }
}

// Upload notifier
class UploadNotifier extends StateNotifier<UploadData> {
  final UploadWithProgress _uploadWithProgress;

  UploadNotifier(this._uploadWithProgress)
    : super(const UploadData(state: UploadState.idle));

  Future<void> uploadDocument({
    required String filePath,
    required String title,
    String? description,
    List<String>? tags,
  }) async {
    try {
      state = state.copyWith(
        state: UploadState.uploading,
        progress: 0.0,
        errorMessage: null,
        statusMessage: 'Starting upload...',
      );

      final result = await _uploadWithProgress(
        UploadWithProgressParams(
          filePath: filePath,
          title: title,
          description: description,
          tags: tags,
          onProgress: (progress, status) {
            state = state.copyWith(
              progress: progress,
              statusMessage: status,
              state: progress < 1.0
                  ? UploadState.uploading
                  : UploadState.processing,
            );
          },
        ),
      );

      result.fold(
        (failure) {
          state = state.copyWith(
            state: UploadState.error,
            errorMessage: failure.toString(),
          );
        },
        (document) {
          state = state.copyWith(
            state: UploadState.completed,
            uploadedDocument: document,
            progress: 1.0,
            statusMessage: 'Upload completed successfully!',
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        state: UploadState.error,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() {
    state = const UploadData(state: UploadState.idle);
  }

  void clearError() {
    if (state.state == UploadState.error) {
      state = state.copyWith(state: UploadState.idle, errorMessage: null);
    }
  }
}

// Providers
final documentListProvider =
    StateNotifierProvider<DocumentListNotifier, DocumentListData>((ref) {
      return DocumentListNotifier(sl<GetDocuments>(), sl<DeleteDocument>());
    });

final uploadProvider = StateNotifierProvider<UploadNotifier, UploadData>((ref) {
  return UploadNotifier(sl<UploadWithProgress>());
});

// Document content provider
final documentContentProvider = FutureProviderFamily<DocumentContent, String>((
  ref,
  documentId,
) async {
  final getDocumentContent = sl<GetDocumentContent>();
  final result = await getDocumentContent(
    GetDocumentContentParams(documentId: documentId),
  );

  return result.fold((failure) => throw failure, (content) => content);
});

// Selected document provider
final selectedDocumentProvider = StateProvider<Document?>((ref) => null);

// Document search provider
final documentSearchProvider = StateProvider<String>((ref) => '');

// Filtered documents provider
final filteredDocumentsProvider = Provider<List<Document>>((ref) {
  final documents = ref.watch(documentListProvider).documents;
  final searchQuery = ref.watch(documentSearchProvider);

  if (searchQuery.isEmpty) return documents;

  final query = searchQuery.toLowerCase();
  return documents.where((doc) {
    return doc.title.toLowerCase().contains(query) ||
        doc.description.toLowerCase().contains(query) ||
        doc.tags.any((tag) => tag.toLowerCase().contains(query));
  }).toList();
});

// Document statistics provider
final documentStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final documents = ref.watch(documentListProvider).documents;

  if (documents.isEmpty) {
    return {
      'totalDocuments': 0,
      'totalPages': 0,
      'averagePages': 0.0,
      'languages': <String>[],
      'recentUploads': 0,
    };
  }

  final totalPages = documents.fold<int>(0, (sum, doc) => sum + doc.totalPages);
  final averagePages = totalPages / documents.length;

  final languages = documents.map((doc) => doc.language).toSet().toList();

  final now = DateTime.now();
  final recentUploads = documents.where((doc) {
    final daysSinceUpload = now.difference(doc.uploadedAt).inDays;
    return daysSinceUpload <= 7;
  }).length;

  return {
    'totalDocuments': documents.length,
    'totalPages': totalPages,
    'averagePages': averagePages,
    'languages': languages,
    'recentUploads': recentUploads,
  };
});

// Recently accessed documents provider
final recentDocumentsProvider = Provider<List<Document>>((ref) {
  final documents = ref.watch(documentListProvider).documents;

  final sortedDocuments = List<Document>.from(documents);
  sortedDocuments.sort((a, b) => b.lastAccessedAt.compareTo(a.lastAccessedAt));

  return sortedDocuments.take(5).toList();
});

// Document by language provider
final documentsByLanguageProvider = Provider<Map<String, List<Document>>>((
  ref,
) {
  final documents = ref.watch(documentListProvider).documents;

  final Map<String, List<Document>> grouped = {};

  for (final doc in documents) {
    if (!grouped.containsKey(doc.language)) {
      grouped[doc.language] = [];
    }
    grouped[doc.language]!.add(doc);
  }

  return grouped;
});

// Upload progress provider
final uploadProgressProvider = Provider<double>((ref) {
  final uploadData = ref.watch(uploadProvider);
  return uploadData.progress;
});

// Is uploading provider
final isUploadingProvider = Provider<bool>((ref) {
  final uploadData = ref.watch(uploadProvider);
  return uploadData.state == UploadState.uploading ||
      uploadData.state == UploadState.processing;
});
