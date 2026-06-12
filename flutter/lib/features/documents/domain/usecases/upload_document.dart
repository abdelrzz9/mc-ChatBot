import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/document_entity.dart';
import '../repositories/document_repository.dart';

class UploadDocumentParams extends Equatable {
  final String filePath;
  final String fileName;

  const UploadDocumentParams({
    required this.filePath,
    required this.fileName,
  });

  @override
  List<Object> get props => [filePath, fileName];
}

class UploadDocument extends UseCase<DocumentEntity, UploadDocumentParams> {
  final DocumentRepository repository;

  UploadDocument(this.repository);

  @override
  Future<Either<Failure, DocumentEntity>> call(
    UploadDocumentParams params,
  ) {
    return repository.uploadDocument(params.filePath, params.fileName);
  }
}
