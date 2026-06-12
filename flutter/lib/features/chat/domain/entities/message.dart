class Message {
  final String id;
  final String? conversationId;
  final String role;
  final String content;
  final String? createdAt;

  const Message({
    required this.id,
    this.conversationId,
    required this.role,
    required this.content,
    this.createdAt,
  });
}
