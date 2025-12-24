import 'package:flutter/foundation.dart';

import '../auth/auth_api.dart';
import 'profile_api.dart';
import 'profile_model.dart';

class ProfileController extends ChangeNotifier {
  UserProfile? _profile;
  UserProfile? get profile => _profile;

  void setProfile(UserProfile p) {
    _profile = p;
    notifyListeners();
  }

  Future<void> loadFromAuthApi(AuthApi authApi, String userId) async {
    final api = ProfileApi(authApi);
    _profile = await api.getMe(userId);
    notifyListeners();
  }

  Future<void> update(AuthApi authApi, UserProfile updated) async {
    final api = ProfileApi(authApi);
    _profile = await api.updateMe(updated);
    notifyListeners();
  }
}
