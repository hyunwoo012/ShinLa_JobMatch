import 'package:flutter/material.dart';

import '../../core/common/utils.dart';
import '../../core/common/widgets.dart';
import '../../main.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.roomId});
  final String roomId;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _text = TextEditingController();
  bool _loaded = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;

    final state = AppScope.of(context);
    state.chats.loadMessages(widget.roomId);
  }

  Future<void> _send() async {
    final state = AppScope.of(context);
    final me = state.auth.me;
    if (me == null) return;

    final t = _text.text.trim();
    if (t.isEmpty) return;

    _text.clear();
    await state.chats.send(roomId: widget.roomId, senderId: me.userId, text: t);

    if (!mounted) return;
    UiUtils.snack(context, '전송됨');
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final me = state.auth.me;

    final msgs = state.chats.messagesOf(widget.roomId);

    return AppScaffold(
      title: '채팅',
      body: me == null
          ? const Center(child: Text('로그인이 필요합니다.'))
          : Column(
        children: [
          Expanded(
            child: ListView.separated(
              itemCount: msgs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (context, idx) {
                final m = msgs[idx];
                final mine = m.senderId == me.userId;
                return Align(
                  alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 280),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(mine ? '나' : m.senderId,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(m.text),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _text,
                  decoration: const InputDecoration(labelText: '메시지 입력'),
                ),
              ),
              const SizedBox(width: 8),
              PrimaryButton(text: '전송', onPressed: _send),
            ],
          ),
        ],
      ),
    );
  }
}
