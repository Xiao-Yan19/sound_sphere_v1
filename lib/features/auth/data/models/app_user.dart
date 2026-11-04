class AppUser {
  const AppUser({
    required this.id,
    required this.username,
    required this.displayName,
    required this.email,
    this.avatar,
    this.bio = '',
  });

  final String id;
  final String username;
  final String displayName;
  final String email;
  final String? avatar;
  final String bio;

  /// Display name if set, otherwise the username.
  String get shownName => displayName.isNotEmpty ? displayName : username;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      username: json['username'] as String,
      displayName: (json['displayName'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      avatar: json['avatar'] as String?,
      bio: (json['bio'] as String?) ?? '',
    );
  }
}
