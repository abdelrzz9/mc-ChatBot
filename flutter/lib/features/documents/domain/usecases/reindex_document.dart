import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/document_repository.dart';

class ReindexDocumentParams extends Equatable {
  final String id;

  const ReindexDocumentParams({required this.id});

  @override
  List<Object> get props => [id];
}

class ReindexDocument extends UseCase<void, ReindexDocumentParams> {
  final DocumentRepository repository;

  ReindexDocument(this.repository);

  @override
  Future<Either<Failure, void>> call(ReindexDocumentParams params) {
    return repository.reindexDocument(params.id);
  }
}
