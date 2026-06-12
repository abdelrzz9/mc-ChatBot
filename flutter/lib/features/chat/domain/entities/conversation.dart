class Conversation {
  final String id;
  final String title;
  final String? createdAt;
  final String? updatedAt;

  const Conversation({
    required this.id,
    required this.title,
    this.createdAt,
    this.updatedAt,
  });
}
