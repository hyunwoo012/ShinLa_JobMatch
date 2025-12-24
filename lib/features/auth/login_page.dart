import 'package:flutter/material.dart';

import '../../core/common/utils.dart';
import '../../core/common/widgets.dart';
import '../../main.dart';
import '../job/job_list_page.dart';

import 'auth_model.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.role});

  final UserRole role;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _id = TextEditingController();
  final _pw = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _id.dispose();
    _pw.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final state = AppScope.of(context);
    final username = _id.text.trim();
    final password = _pw.text.trim();

    if (username.isEmpty || password.isEmpty) {
      UiUtils.snack(context, '아이디/비밀번호를 입력하세요.');
      return;
    }

    setState(() => _loading = true);
    try {
      await state.auth.login(username, password);
      // (선택) 역할 불일치 체크는 서버가 해야 하지만, MVP에서 간단히 안내만.
      if (state.auth.me!.role != widget.role) {
        UiUtils.snack(context, '주의: 선택한 역할과 가입 역할이 다릅니다.');
      }

      // 프로필 로드
      await state.profile.loadFromAuthApi(state.auth.api, state.auth.me!.userId);

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const JobListPage()),
            (route) => false,
      );
    } catch (e) {
      UiUtils.snack(context, e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: '로그인',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LabeledBox(
            label: '역할',
            child: Text(widget.role == UserRole.worker ? '구직자' : '구인자'),
          ),
          const SizedBox(height: 12),
          TextField(controller: _id, decoration: const InputDecoration(labelText: '아이디')),
          const SizedBox(height: 10),
          TextField(
            controller: _pw,
            decoration: const InputDecoration(labelText: '비밀번호'),
            obscureText: true,
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            text: _loading ? '처리중...' : '로그인',
            onPressed: _loading ? null : _submit,
          ),
        ],
      ),
    );
  }
}
