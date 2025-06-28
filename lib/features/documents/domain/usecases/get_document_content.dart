import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/document_content.dart';
import '../repositories/document_repository.dart';

class GetDocumentContent implements UseCase<DocumentContent, GetDocumentContentParams> {
  final DocumentRepository repository;

  GetDocumentContent(this.repository);

  @override
  Future<Either<Failure, DocumentContent>> call(GetDocumentContentParams params) async {
    return await repository.getDocumentContent(params.documentId);
  }
}

class GetDocumentContentParams extends Equatable {
  final String documentId;

  const GetDocumentContentParams({required this.documentId});

  @override
  List<Object> get props => [documentId];
}
