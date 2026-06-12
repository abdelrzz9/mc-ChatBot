import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/document_repository.dart';

class DeleteDocumentParams extends Equatable {
  final String id;

  const DeleteDocumentParams({required this.id});

  @override
  List<Object> get props => [id];
}

class DeleteDocument extends UseCase<void, DeleteDocumentParams> {
  final DocumentRepository repository;

  DeleteDocument(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteDocumentParams params) {
    return repository.deleteDocument(params.id);
  }
}
