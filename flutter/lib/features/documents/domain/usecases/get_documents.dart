import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/document_entity.dart';
import '../repositories/document_repository.dart';

class GetDocuments extends UseCase<List<DocumentEntity>, NoParams> {
  final DocumentRepository repository;

  GetDocuments(this.repository);

  @override
  Future<Either<Failure, List<DocumentEntity>>> call(NoParams params) {
    return repository.getDocuments();
  }
}
