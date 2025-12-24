import 'package:flutter/material.dart';

import '../../core/common/utils.dart';
import '../../core/common/widgets.dart';
import '../../main.dart';
import '../auth/auth_model.dart';
import '../chat/chat_list_page.dart';
import '../profile/profile_page.dart';
import 'job_register_page.dart';
import 'job_detail_page.dart';
import 'job_model.dart';

class JobListPage extends StatefulWidget {
  const JobListPage({super.key});

  @override
  State<JobListPage> createState() => _JobListPageState();
}

class _JobListPageState extends State<JobListPage> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    AppScope.of(context).jobs.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final me = state.auth.me;

    if (me == null) {
      return const AppScaffold(
        title: '구인 게시판',
        body: Center(child: Text('로그인이 필요합니다.')),
      );
    }

    final isEmployer = me.role == UserRole.employer;

    return AppScaffold(
      title: '구인 게시판',
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatListPage()));
          },
          icon: const Icon(Icons.chat_bubble_outline),
          tooltip: '채팅',
        ),
        IconButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
          },
          icon: const Icon(Icons.person_outline),
          tooltip: '프로필',
        ),
      ],
      fab: isEmployer
          ? FloatingActionButton(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const JobRegisterPage()),
          );
          if (!context.mounted) return;
          state.jobs.refresh();
        },
        child: const Icon(Icons.add),
      )
          : null,
      body: Column(
        children: [
          LabeledBox(
            label: '내 정보',
            child: Text('ID: ${me.username} / ROLE: ${me.role.name}'),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => state.jobs.refresh(),
              child: ListView.separated(
                itemCount: state.jobs.items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, idx) {
                  final JobPost post = state.jobs.items[idx];
                  return InkWell(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => JobDetailPage(post: post)),
                      );
                      if (!context.mounted) return;
                      state.jobs.refresh();
                    },
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(post.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Text('가게: ${post.shopName}'),
                            Text('시급: ${post.wage}'),
                            Text('작성자: ${post.employerId}'),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          OutlineButton(
            text: '로그아웃',
            onPressed: () {
              state.auth.logout();
              UiUtils.snack(context, '로그아웃되었습니다.');
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
    );
  }
}
