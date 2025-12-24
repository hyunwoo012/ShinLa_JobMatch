import '../../core/common/utils.dart';
import '../profile/profile_model.dart';
import '../profile/profile_controller.dart';
import 'auth_model.dart';

/// 지금은 Mock. 나중에 DioClient로 교체하면 됨.
class AuthApi {
  static final Map<String, String> _pwByUsername = {};
  static final Map<String, AuthUser> _userByUsername = {};
  static final Map<String, UserProfile> _profileByUserId = {};

  Future<AuthUser> signup({
    required String username,
    required String password,
    required UserRole role,
  }) async {
    if (_userByUsername.containsKey(username)) {
      throw Exception('이미 존재하는 아이디입니다.');
    }
    final userId = UiUtils.newId();
    final user = AuthUser(userId: userId, username: username, role: role);
    _userByUsername[username] = user;
    _pwByUsername[username] = password;

    // 프로필 기본 생성
    _profileByUserId[userId] = UserProfile(
      userId: userId,
      name: username,
      role: role,
      bio: '',
    );

    return user;
  }

  Future<AuthUser> login({
    required String username,
    required String password,
  }) async {
    final user = _userByUsername[username];
    if (user == null) throw Exception('존재하지 않는 아이디입니다.');
    if (_pwByUsername[username] != password) throw Exception('비밀번호가 틀렸습니다.');
    return user;
  }

  Future<UserProfile> getMyProfile(String userId) async {
    final profile = _profileByUserId[userId];
    if (profile == null) throw Exception('프로필이 없습니다.');
    return profile;
  }

  Future<UserProfile> updateMyProfile(UserProfile updated) async {
    _profileByUserId[updated.userId] = updated;
    return updated;
  }

  /// ProfileController가 AuthApi 저장소를 그대로 쓰도록 연결(간단 연동)
  void bindProfileController(ProfileController controller, String userId) async {
    final p = await getMyProfile(userId);
    controller.setProfile(p);
  }
}
