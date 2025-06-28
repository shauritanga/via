import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/document.dart';
import '../entities/document_content.dart';

abstract class DocumentRepository {
  Future<Either<Failure, List<Document>>> getDocuments();
  Future<Either<Failure, Document>> getDocumentById(String id);
  Future<Either<Failure, DocumentContent>> getDocumentContent(String documentId);
  Future<Either<Failure, Document>> uploadDocument({
    required String filePath,
    required String title,
    String? description,
    List<String>? tags,
  });
  Future<Either<Failure, void>> deleteDocument(String documentId);
  Future<Either<Failure, void>> updateDocument(Document document);
  Future<Either<Failure, void>> updateLastAccessedTime(String documentId);
}
