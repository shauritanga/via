import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/document.dart';
import '../entities/document_content.dart';
import '../repositories/document_repository.dart';
import '../../data/services/pdf_processing_service.dart';

class UploadAndProcessDocument implements UseCase<Document, UploadAndProcessDocumentParams> {
  final DocumentRepository repository;

  UploadAndProcessDocument(this.repository);

  @override
  Future<Either<Failure, Document>> call(UploadAndProcessDocumentParams params) async {
    try {
      // Step 1: Validate the file
      if (!PDFProcessingService.isValidPDFFile(params.filePath)) {
        return const Left(DocumentParsingFailure('Invalid PDF file'));
      }

      // Step 2: Validate PDF integrity
      final isValid = await PDFProcessingService.validatePDFIntegrity(params.filePath);
      if (!isValid) {
        return const Left(DocumentParsingFailure('Corrupted PDF file'));
      }

      // Step 3: Get PDF metadata
      final metadata = await PDFProcessingService.getPDFMetadata(params.filePath);
      
      // Step 4: Upload the document file first
      final uploadResult = await repository.uploadDocument(
        filePath: params.filePath,
        title: params.title,
        description: params.description,
        tags: params.tags,
      );

      return uploadResult.fold(
        (failure) => Left(failure),
        (document) async {
          try {
            // Step 5: Process the PDF content
            final documentContent = await PDFProcessingService.extractContentFromPDF(
              filePath: params.filePath,
              documentId: document.id,
            );

            // Step 6: Update document with metadata
            final updatedDocument = document.copyWith(
              totalPages: metadata['pageCount'] as int,
              language: metadata['language'] as String,
              description: params.description ?? 
                'PDF document with ${metadata['pageCount']} pages. ' +
                'Estimated reading time: ${metadata['estimatedReadingTimeMinutes']} minutes.',
            );

            // Step 7: Save the updated document
            final updateResult = await repository.updateDocument(updatedDocument);
            
            return updateResult.fold(
              (failure) => Left(failure),
              (_) {
                // Step 8: Store the document content
                // Note: In a real implementation, you'd save the content to Firestore
                // For now, we'll assume it's handled by the repository
                
                return Right(updatedDocument);
              },
            );
          } catch (e) {
            // If processing fails, we should clean up the uploaded document
            await repository.deleteDocument(document.id);
            
            if (e is Failure) {
              return Left(e);
            }
            return Left(DocumentParsingFailure('Failed to process PDF content: $e'));
          }
        },
      );
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(ServerFailure('Failed to upload and process document: $e'));
    }
  }
}

class UploadAndProcessDocumentParams extends Equatable {
  final String filePath;
  final String title;
  final String? description;
  final List<String>? tags;
  final bool processContent;
  final String? expectedLanguage;

  const UploadAndProcessDocumentParams({
    required this.filePath,
    required this.title,
    this.description,
    this.tags,
    this.processContent = true,
    this.expectedLanguage,
  });

  @override
  List<Object?> get props => [
        filePath,
        title,
        description,
        tags,
        processContent,
        expectedLanguage,
      ];
}

// Progress callback for upload operations
typedef UploadProgressCallback = void Function(double progress, String status);

class UploadWithProgress implements UseCase<Document, UploadWithProgressParams> {
  final DocumentRepository repository;

  UploadWithProgress(this.repository);

  @override
  Future<Either<Failure, Document>> call(UploadWithProgressParams params) async {
    try {
      // Report initial progress
      params.onProgress?.call(0.0, 'Validating file...');

      // Step 1: Validate the file
      if (!PDFProcessingService.isValidPDFFile(params.filePath)) {
        return const Left(DocumentParsingFailure('Invalid PDF file'));
      }

      params.onProgress?.call(0.1, 'Checking file integrity...');

      // Step 2: Validate PDF integrity
      final isValid = await PDFProcessingService.validatePDFIntegrity(params.filePath);
      if (!isValid) {
        return const Left(DocumentParsingFailure('Corrupted PDF file'));
      }

      params.onProgress?.call(0.2, 'Analyzing document...');

      // Step 3: Get PDF metadata
      final metadata = await PDFProcessingService.getPDFMetadata(params.filePath);
      
      params.onProgress?.call(0.3, 'Uploading file...');

      // Step 4: Upload the document file
      final uploadResult = await repository.uploadDocument(
        filePath: params.filePath,
        title: params.title,
        description: params.description,
        tags: params.tags,
      );

      return uploadResult.fold(
        (failure) => Left(failure),
        (document) async {
          try {
            params.onProgress?.call(0.6, 'Processing content...');

            // Step 5: Process the PDF content
            final documentContent = await PDFProcessingService.extractContentFromPDF(
              filePath: params.filePath,
              documentId: document.id,
            );

            params.onProgress?.call(0.8, 'Updating document metadata...');

            // Step 6: Update document with metadata
            final updatedDocument = document.copyWith(
              totalPages: metadata['pageCount'] as int,
              language: metadata['language'] as String,
              description: params.description ?? 
                'PDF document with ${metadata['pageCount']} pages. ' +
                'Estimated reading time: ${metadata['estimatedReadingTimeMinutes']} minutes.',
            );

            // Step 7: Save the updated document
            final updateResult = await repository.updateDocument(updatedDocument);
            
            return updateResult.fold(
              (failure) => Left(failure),
              (_) {
                params.onProgress?.call(1.0, 'Upload completed successfully!');
                return Right(updatedDocument);
              },
            );
          } catch (e) {
            // If processing fails, clean up
            await repository.deleteDocument(document.id);
            
            if (e is Failure) {
              return Left(e);
            }
            return Left(DocumentParsingFailure('Failed to process PDF content: $e'));
          }
        },
      );
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(ServerFailure('Failed to upload and process document: $e'));
    }
  }
}

class UploadWithProgressParams extends Equatable {
  final String filePath;
  final String title;
  final String? description;
  final List<String>? tags;
  final UploadProgressCallback? onProgress;

  const UploadWithProgressParams({
    required this.filePath,
    required this.title,
    this.description,
    this.tags,
    this.onProgress,
  });

  @override
  List<Object?> get props => [filePath, title, description, tags];
}
