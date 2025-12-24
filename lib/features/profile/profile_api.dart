import '../auth/auth_api.dart';
import 'profile_model.dart';

/// MVP에서는 AuthApi 저장소를 재사용.
/// 실서버로 가면 Profile 전용 API로 분리하면 됨.
class ProfileApi {
  ProfileApi(this._authApi);

  final AuthApi _authApi;

  Future<UserProfile> getMe(String userId) => _authApi.getMyProfile(userId);
  Future<UserProfile> updateMe(UserProfile profile) => _authApi.updateMyProfile(profile);
}
