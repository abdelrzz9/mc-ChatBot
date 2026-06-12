class DocumentEntity {
  final String id;
  final String filename;
  final String? contentType;
  final int? sizeBytes;
  final String? status;
  final String? createdAt;

  const DocumentEntity({
    required this.id,
    required this.filename,
    this.contentType,
    this.sizeBytes,
    this.status,
    this.createdAt,
  });
}
