import 'package:freezed_annotation/freezed_annotation.dart';

part 'document_model.freezed.dart';
part 'document_model.g.dart';

@freezed
abstract class DocumentModel with _$DocumentModel {
  const factory DocumentModel({
    required String id,
    required String filename,
    @JsonKey(name: 'content_type') String? contentType,
    @JsonKey(name: 'size_bytes') int? sizeBytes,
    String? status,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _DocumentModel;

  factory DocumentModel.fromJson(Map<String, dynamic> json) =>
      _$DocumentModelFromJson(json);
}
