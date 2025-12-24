import 'package:flutter/material.dart';

import 'core/common/theme.dart';
import 'features/auth/auth_controller.dart';
import 'features/auth/role_select_page.dart';
import 'features/chat/chat_controller.dart';
import 'features/job/job_controller.dart';
import 'features/profile/profile_controller.dart';

/// App 전역 상태/DI 스코프(Provider 없이 InheritedNotifier로 주입)
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({
    super.key,
    required AppState state,
    required Widget child,
  }) : super(notifier: state, child: child);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found. Wrap your app with AppScope.');
    return scope!.notifier!;
  }
}

/// 전역 컨트롤러 모음 (Listenable로 묶어서 setState 없이 리빌드 유도)
class AppState extends ChangeNotifier {
  AppState()
      : auth = AuthController(),
        jobs = JobController(),
        chats = ChatController(),
        profile = ProfileController();

  final AuthController auth;
  final JobController jobs;
  final ChatController chats;
  final ProfileController profile;

  /// 각 하위 컨트롤러가 변경되면 AppState도 notify해서 화면 갱신
  void wireUp() {
    void forward() => notifyListeners();
    auth.addListener(forward);
    jobs.addListener(forward);
    chats.addListener(forward);
    profile.addListener(forward);
  }

  @override
  void dispose() {
    auth.dispose();
    jobs.dispose();
    chats.dispose();
    profile.dispose();
    super.dispose();
  }
}

void main() {
  final state = AppState()..wireUp();
  runApp(AppScope(
    state: state,
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShinLa JobMatch',
      theme: AppTheme.light(),
      home: const RoleSelectPage(),
    );
  }
}
