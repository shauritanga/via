import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/document_repository.dart';

class DeleteDocument implements UseCase<void, DeleteDocumentParams> {
  final DocumentRepository repository;

  DeleteDocument(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteDocumentParams params) async {
    return await repository.deleteDocument(params.documentId);
  }
}

class DeleteDocumentParams extends Equatable {
  final String documentId;

  const DeleteDocumentParams({required this.documentId});

  @override
  List<Object> get props => [documentId];
}
