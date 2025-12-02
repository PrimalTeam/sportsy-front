class UserProfileDto {
  final int id;
  final String username;
  final String email;
  final List<String> roles;
  final DateTime createdAt;

  UserProfileDto({
    required this.id,
    required this.username,
    required this.email,
    required this.roles,
    required this.createdAt,
  });

  factory UserProfileDto.fromJson(Map<String, dynamic> json) {
    return UserProfileDto(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      roles: (json['roles'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
