import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../documents/domain/entities/document_entity.dart';
import '../../../documents/domain/repositories/document_repository.dart';
import '../datasources/document_remote_datasource.dart';
import '../models/document_model.dart';

DocumentEntity _modelToDocument(DocumentModel m) => DocumentEntity(
      id: m.id,
      filename: m.filename,
      contentType: m.contentType,
      sizeBytes: m.sizeBytes,
      status: m.status,
      createdAt: m.createdAt,
    );

class DocumentRepositoryImpl implements DocumentRepository {
  final DocumentRemoteDataSource remoteDataSource;

  DocumentRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<DocumentEntity>>> getDocuments() async {
    try {
      final models = await remoteDataSource.getDocuments();
      final documents = models
          .map((e) =>
              _modelToDocument(
                DocumentModel.fromJson(e as Map<String, dynamic>),
              ))
          .toList();
      return Right(documents);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, DocumentEntity>> uploadDocument(
    String filePath,
    String fileName,
  ) async {
    try {
      final data = await remoteDataSource.uploadDocument(filePath, fileName);
      final document = _modelToDocument(DocumentModel.fromJson(data));
      return Right(document);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDocument(String id) async {
    try {
      await remoteDataSource.deleteDocument(id);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> reindexDocument(String id) async {
    try {
      await remoteDataSource.reindexDocument(id);
      return const Right(null);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
