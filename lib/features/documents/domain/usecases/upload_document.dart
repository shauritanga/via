import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/document.dart';
import '../repositories/document_repository.dart';

class UploadDocument implements UseCase<Document, UploadDocumentParams> {
  final DocumentRepository repository;

  UploadDocument(this.repository);

  @override
  Future<Either<Failure, Document>> call(UploadDocumentParams params) async {
    return await repository.uploadDocument(
      filePath: params.filePath,
      title: params.title,
      description: params.description,
      tags: params.tags,
    );
  }
}

class UploadDocumentParams extends Equatable {
  final String filePath;
  final String title;
  final String? description;
  final List<String>? tags;

  const UploadDocumentParams({
    required this.filePath,
    required this.title,
    this.description,
    this.tags,
  });

  @override
  List<Object?> get props => [filePath, title, description, tags];
}
