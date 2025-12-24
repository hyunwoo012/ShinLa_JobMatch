import 'package:flutter/material.dart';

import '../../core/common/utils.dart';
import '../../core/common/widgets.dart';
import '../../main.dart';
import 'user_profile_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final me = state.auth.me;
    final p = state.profile.profile;

    return AppScaffold(
      title: '프로필',
      body: me == null
          ? const Center(child: Text('로그인이 필요합니다.'))
          : Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LabeledBox(
            label: '계정',
            child: Text('userId: ${me.userId}\nusername: ${me.username}\nrole: ${me.role.name}'),
          ),
          const SizedBox(height: 12),
          LabeledBox(
            label: '프로필',
            child: Text(p == null ? '(없음)' : 'name: ${p.name}\nbio: ${p.bio}'),
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            text: '프로필 편집',
            onPressed: () {
              if (p == null) {
                UiUtils.snack(context, '프로필을 먼저 불러오지 못했습니다.');
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => UserProfilePage(profile: p)),
              );
            },
          ),
        ],
      ),
    );
  }
}
