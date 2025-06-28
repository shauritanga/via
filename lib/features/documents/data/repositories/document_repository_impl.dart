import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/document.dart';
import '../../domain/entities/document_content.dart';
import '../../domain/repositories/document_repository.dart';
import '../datasources/document_remote_datasource.dart';
import '../datasources/document_local_datasource.dart';
import '../models/document_model.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  final DocumentRemoteDataSource remoteDataSource;
  final DocumentLocalDataSource localDataSource;

  DocumentRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<Document>>> getDocuments() async {
    try {
      // Try to get from remote first
      final remoteDocuments = await remoteDataSource.getDocuments();
      
      // Cache the results
      await localDataSource.cacheDocuments(remoteDocuments);
      
      return Right(remoteDocuments);
    } catch (e) {
      // If remote fails, try to get from cache
      try {
        final cachedDocuments = await localDataSource.getCachedDocuments();
        if (cachedDocuments.isNotEmpty) {
          return Right(cachedDocuments);
        }
        
        // If no cache, return the original error
        if (e is Failure) {
          return Left(e);
        }
        return Left(ServerFailure('Failed to get documents: $e'));
      } catch (cacheError) {
        if (e is Failure) {
          return Left(e);
        }
        return Left(ServerFailure('Failed to get documents: $e'));
      }
    }
  }

  @override
  Future<Either<Failure, Document>> getDocumentById(String id) async {
    try {
      final document = await remoteDataSource.getDocumentById(id);
      return Right(document);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(ServerFailure('Failed to get document: $e'));
    }
  }

  @override
  Future<Either<Failure, DocumentContent>> getDocumentContent(String documentId) async {
    try {
      // Try to get from cache first for better performance
      final cachedContent = await localDataSource.getCachedDocumentContent(documentId);
      if (cachedContent != null) {
        return Right(cachedContent);
      }

      // If not in cache, get from remote
      final remoteContent = await remoteDataSource.getDocumentContent(documentId);
      
      // Cache the content
      await localDataSource.cacheDocumentContent(remoteContent);
      
      return Right(remoteContent);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(ServerFailure('Failed to get document content: $e'));
    }
  }

  @override
  Future<Either<Failure, Document>> uploadDocument({
    required String filePath,
    required String title,
    String? description,
    List<String>? tags,
  }) async {
    try {
      final document = await remoteDataSource.uploadDocument(
        filePath: filePath,
        title: title,
        description: description,
        tags: tags,
      );

      // Refresh cache
      try {
        final documents = await remoteDataSource.getDocuments();
        await localDataSource.cacheDocuments(documents);
      } catch (_) {
        // Cache refresh failed, but upload succeeded
      }

      return Right(document);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(ServerFailure('Failed to upload document: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDocument(String documentId) async {
    try {
      await remoteDataSource.deleteDocument(documentId);
      
      // Remove from cache
      await localDataSource.removeCachedDocument(documentId);
      
      return const Right(null);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(ServerFailure('Failed to delete document: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateDocument(Document document) async {
    try {
      final documentModel = DocumentModel.fromEntity(document);
      await remoteDataSource.updateDocument(documentModel);
      
      // Refresh cache
      try {
        final documents = await remoteDataSource.getDocuments();
        await localDataSource.cacheDocuments(documents);
      } catch (_) {
        // Cache refresh failed, but update succeeded
      }
      
      return const Right(null);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(ServerFailure('Failed to update document: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateLastAccessedTime(String documentId) async {
    try {
      await remoteDataSource.updateLastAccessedTime(documentId);
      
      // Refresh cache
      try {
        final documents = await remoteDataSource.getDocuments();
        await localDataSource.cacheDocuments(documents);
      } catch (_) {
        // Cache refresh failed, but update succeeded
      }
      
      return const Right(null);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(ServerFailure('Failed to update last accessed time: $e'));
    }
  }
}
