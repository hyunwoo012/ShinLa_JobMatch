import 'package:flutter/foundation.dart';

import 'auth_api.dart';
import 'auth_model.dart';

class AuthController extends ChangeNotifier {
  final _api = AuthApi();

  AuthUser? _me;

  AuthUser? get me => _me;
  bool get isLoggedIn => _me != null;

  Future<void> signup(String username, String password, UserRole role) async {
    _me = await _api.signup(username: username, password: password, role: role);
    notifyListeners();
  }

  Future<void> login(String username, String password) async {
    _me = await _api.login(username: username, password: password);
    notifyListeners();
  }

  void logout() {
    _me = null;
    notifyListeners();
  }

  AuthApi get api => _api;
}
