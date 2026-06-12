import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/document_entity.dart';
import '../../domain/repositories/document_repository.dart';

class DocumentState {
  final List<DocumentEntity> documents;
  final bool isLoading;
  final bool isUploading;
  final double uploadProgress;
  final String? error;
  final String? successMessage;

  const DocumentState({
    this.documents = const [],
    this.isLoading = false,
    this.isUploading = false,
    this.uploadProgress = 0,
    this.error,
    this.successMessage,
  });

  DocumentState copyWith({
    List<DocumentEntity>? documents,
    bool? isLoading,
    bool? isUploading,
    double? uploadProgress,
    String? error,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return DocumentState(
      documents: documents ?? this.documents,
      isLoading: isLoading ?? this.isLoading,
      isUploading: isUploading ?? this.isUploading,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      error: clearError ? null : error ?? this.error,
      successMessage:
          clearSuccess ? null : successMessage ?? this.successMessage,
    );
  }

  static const initial = DocumentState();
}

class DocumentController extends StateNotifier<DocumentState> {
  final DocumentRepository _repository;

  DocumentController(this._repository) : super(DocumentState.initial);

  Future<void> loadDocuments() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _repository.getDocuments();
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (documents) => state = state.copyWith(
        documents: documents,
        isLoading: false,
      ),
    );
  }

  Future<void> uploadDocument(String filePath, String fileName) async {
    state = state.copyWith(
      isUploading: true,
      uploadProgress: 0,
      clearError: true,
      clearSuccess: true,
    );

    final result = await _repository.uploadDocument(filePath, fileName);
    result.fold(
      (failure) => state = state.copyWith(
        isUploading: false,
        error: failure.message,
      ),
      (document) => state = state.copyWith(
        isUploading: false,
        uploadProgress: 1,
        documents: [document, ...state.documents],
        successMessage: '${document.filename} uploaded successfully',
      ),
    );
  }

  Future<void> deleteDocument(String id) async {
    final result = await _repository.deleteDocument(id);
    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (_) => state = state.copyWith(
        documents: state.documents.where((d) => d.id != id).toList(),
        successMessage: 'Document deleted successfully',
      ),
    );
  }

  Future<void> reindexDocument(String id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _repository.reindexDocument(id);
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (_) => state = state.copyWith(
        isLoading: false,
        successMessage: 'Document reindexed successfully',
      ),
    );
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void clearSuccess() {
    state = state.copyWith(clearSuccess: true);
  }
}
