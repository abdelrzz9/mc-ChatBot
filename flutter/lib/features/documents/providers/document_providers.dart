import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../di/injection_container.dart';
import '../domain/repositories/document_repository.dart';
import '../presentation/controllers/document_controller.dart';

final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  return sl<DocumentRepository>();
});

final documentControllerProvider =
    StateNotifierProvider<DocumentController, DocumentState>((ref) {
  return DocumentController(ref.watch(documentRepositoryProvider));
});
