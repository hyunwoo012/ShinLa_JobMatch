import 'package:flutter/material.dart';

import '../../core/common/widgets.dart';
import '../../main.dart';
import 'chat_page.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;

    final state = AppScope.of(context);
    final me = state.auth.me;
    if (me != null) {
      state.chats.refreshRooms(me.userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final me = state.auth.me;

    return AppScaffold(
      title: '채팅 목록',
      body: me == null
          ? const Center(child: Text('로그인이 필요합니다.'))
          : ListView.separated(
        itemCount: state.chats.rooms.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, idx) {
          final r = state.chats.rooms[idx];
          final peer = r.employerId == me.userId ? r.workerId : r.employerId;
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ChatPage(roomId: r.roomId)),
              );
            },
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('상대: $peer', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text('공고ID: ${r.postId}'),
                    Text('방ID: ${r.roomId}'),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
