import 'package:flutter/material.dart';

import '../../core/common/utils.dart';
import '../../core/common/widgets.dart';
import '../../main.dart';
import '../job/job_list_page.dart';
import 'auth_model.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key, required this.role});
  final UserRole role;

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _id = TextEditingController();
  final _pw = TextEditingController();
  final _pw2 = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _id.dispose();
    _pw.dispose();
    _pw2.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final state = AppScope.of(context);
    final username = _id.text.trim();
    final password = _pw.text.trim();
    final password2 = _pw2.text.trim();

    if (username.isEmpty || password.isEmpty) {
      UiUtils.snack(context, '아이디/비밀번호를 입력하세요.');
      return;
    }
    if (password != password2) {
      UiUtils.snack(context, '비밀번호 확인이 일치하지 않습니다.');
      return;
    }

    setState(() => _loading = true);
    try {
      await state.auth.signup(username, password, widget.role);

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
      title: '회원가입',
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
          const SizedBox(height: 10),
          TextField(
            controller: _pw2,
            decoration: const InputDecoration(labelText: '비밀번호 확인'),
            obscureText: true,
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            text: _loading ? '처리중...' : '가입 완료',
            onPressed: _loading ? null : _submit,
          ),
        ],
      ),
    );
  }
}
