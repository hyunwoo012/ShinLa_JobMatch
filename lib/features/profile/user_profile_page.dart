import 'package:flutter/material.dart';

import '../../core/common/utils.dart';
import '../../core/common/widgets.dart';
import '../../main.dart';
import 'profile_model.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key, required this.profile});
  final UserProfile profile;

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late final TextEditingController _name;
  late final TextEditingController _bio;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.profile.name);
    _bio = TextEditingController(text: widget.profile.bio);
  }

  @override
  void dispose() {
    _name.dispose();
    _bio.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final state = AppScope.of(context);
    final me = state.auth.me;
    if (me == null) return;

    final name = _name.text.trim();
    final bio = _bio.text.trim();

    if (name.isEmpty) {
      UiUtils.snack(context, '이름을 입력하세요.');
      return;
    }

    setState(() => _loading = true);
    try {
      final updated = widget.profile.copyWith(name: name, bio: bio);
      await state.profile.update(state.auth.api, updated);
      if (!mounted) return;
      UiUtils.snack(context, '저장 완료');
      Navigator.pop(context);
    } catch (e) {
      UiUtils.snack(context, e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: '프로필 편집',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(controller: _name, decoration: const InputDecoration(labelText: '이름')),
          const SizedBox(height: 10),
          TextField(
            controller: _bio,
            maxLines: 4,
            decoration: const InputDecoration(labelText: '소개'),
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            text: _loading ? '처리중...' : '저장',
            onPressed: _loading ? null : _save,
          ),
        ],
      ),
    );
  }
}
