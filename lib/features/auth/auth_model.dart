enum UserRole { employer, worker }

class AuthUser {
  AuthUser({
    required this.userId,
    required this.username,
    required this.role,
  });

  final String userId;
  final String username;
  final UserRole role;

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'username': username,
    'role': role.name,
  };

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      userId: json['userId'] as String,
      username: json['username'] as String,
      role: UserRole.values.firstWhere((e) => e.name == json['role']),
    );
  }
}
