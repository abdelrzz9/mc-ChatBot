import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/document_entity.dart';

abstract class DocumentRepository {
  Future<Either<Failure, List<DocumentEntity>>> getDocuments();
  Future<Either<Failure, DocumentEntity>> uploadDocument(
    String filePath,
    String fileName,
  );
  Future<Either<Failure, void>> deleteDocument(String id);
  Future<Either<Failure, void>> reindexDocument(String id);
}
