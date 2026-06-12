class User {
  final String id;
  final String email;
  final String? displayName;
  final String? createdAt;

  const User({
    required this.id,
    required this.email,
    this.displayName,
    this.createdAt,
  });
}
