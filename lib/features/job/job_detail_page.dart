import 'package:flutter/material.dart';

import '../../core/common/utils.dart';
import '../../core/common/widgets.dart';
import '../../main.dart';
import '../auth/auth_model.dart';
import '../chat/chat_page.dart';
import 'job_edit_page.dart';
import 'job_model.dart';

class JobDetailPage extends StatelessWidget {
  const JobDetailPage({super.key, required this.post});
  final JobPost post;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final me = state.auth.me;
    if (me == null) {
      return const AppScaffold(title: '상세', body: Center(child: Text('로그인이 필요합니다.')));
    }

    final isMyPost = post.employerId == me.userId;
    final isEmployer = me.role == UserRole.employer;

    return AppScaffold(
      title: '공고 상세',
      actions: [
        if (isMyPost && isEmployer)
          IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => JobEditPage(post: post)),
              );
              if (!context.mounted) return;
              Navigator.pop(context); // 최신 데이터 반영 위해 상세를 닫고 목록에서 refresh 유도
            },
            icon: const Icon(Icons.edit_outlined),
          ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LabeledBox(
            label: '제목',
            child: Text(post.title),
          ),
          const SizedBox(height: 10),
          LabeledBox(
            label: '가게 / 시급',
            child: Text('${post.shopName} / ${post.wage}'),
          ),
          const SizedBox(height: 10),
          LabeledBox(
            label: '내용',
            child: Text(post.content.isEmpty ? '(내용 없음)' : post.content),
          ),
          const SizedBox(height: 10),
          LabeledBox(
            label: '작성자',
            child: Text(post.employerId),
          ),
          const Spacer(),
          if (isMyPost && isEmployer)
            PrimaryButton(
              text: '삭제',
              onPressed: () async {
                try {
                  await state.jobs.delete(requesterId: me.userId, id: post.id);
                  if (!context.mounted) return;
                  UiUtils.snack(context, '삭제 완료');
                  Navigator.pop(context);
                } catch (e) {
                  UiUtils.snack(context, e.toString().replaceFirst('Exception: ', ''));
                }
              },
            )
          else
            PrimaryButton(
              text: '채팅으로 지원하기',
              onPressed: () async {
                try {
                  final roomId = await state.chats.getOrCreateRoom(
                    postId: post.id,
                    employerId: post.employerId,
                    workerId: me.userId,
                  );
                  if (!context.mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ChatPage(roomId: roomId)),
                  );
                } catch (e) {
                  UiUtils.snack(context, e.toString().replaceFirst('Exception: ', ''));
                }
              },
            ),
        ],
      ),
    );
  }
}
