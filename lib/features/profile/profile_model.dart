import '../auth/auth_model.dart';

class UserProfile {
  UserProfile({
    required this.userId,
    required this.name,
    required this.role,
    required this.bio,
  });

  final String userId;
  final String name;
  final UserRole role;
  final String bio;

  UserProfile copyWith({String? name, String? bio}) {
    return UserProfile(
      userId: userId,
      name: name ?? this.name,
      role: role,
      bio: bio ?? this.bio,
    );
  }
}
