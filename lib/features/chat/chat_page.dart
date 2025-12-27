import 'package:flutter/material.dart';

import '../../core/common/utils.dart';
import '../../core/common/widgets.dart';
import '../../main.dart';

class ChatPage extends StatefulWidget {
  final int roomId;
  const ChatPage({super.key, required this.roomId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _msgController = TextEditingController();

  bool _loading = false;
  bool _wsReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      // 1) 히스토리 1회 로드
      await _loadHistory();

      // 2) WS 연결
      await _connectWs();
    });
  }

  @override
  void dispose() {
    final scope = AppScope.of(context);
    scope.chat.disconnectSocket(widget.roomId);
    _msgController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final scope = AppScope.of(context);
    setState(() => _loading = true);
    try {
      await scope.chat.refreshMessages(widget.roomId);
      await scope.chat.read(widget.roomId);
    } catch (e) {
      if (!mounted) return;
      UiUtils.snack(context, e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _connectWs() async {
    final scope = AppScope.of(context);

    final token = scope.auth.token; // ✅ AuthController에 있는 실제 getter
    if (token == null || token.isEmpty) {
      UiUtils.snack(context, 'No access token');
      return;
    }

    try {
      await scope.chat.connectSocket(
        roomId: widget.roomId,
        accessToken: token,
      );
      if (!mounted) return;
      setState(() => _wsReady = true);
    } catch (e) {
      if (!mounted) return;
      UiUtils.snack(context, 'WS connect failed: $e');
    }
  }

  void _send() {
    final scope = AppScope.of(context);

    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    if (!_wsReady) {
      UiUtils.snack(context, 'WebSocket not connected');
      return;
    }

    // WS로 보내면 서버가 DB 저장 + broadcast(나에게도) 함
    scope.chat.sendWs(widget.roomId, text);
    _msgController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final me = scope.auth.me;
    final messages = scope.chat.messages(widget.roomId);

    return AppScaffold(
      title: 'Chat Room #${widget.roomId}',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  me == null ? 'Not signed in' : 'Me: ${me.role.name} (id=${me.id})',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              Text(_wsReady ? 'WS: ON' : 'WS: OFF', style: const TextStyle(fontSize: 12)),
              IconButton(
                // 폴백/디버깅용 refresh 유지
                onPressed: _loading ? null : _loadHistory,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _loading && messages.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, i) {
                final m = messages[i];
                final isMine = me != null && m.senderId == me.id;

                return Align(
                  alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 280),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment:
                          isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Text('Sender: ${m.senderId}', style: const TextStyle(fontSize: 11)),
                            if (m.createdAt != null)
                              Text(
                                m.createdAt!.toIso8601String(),
                                style: const TextStyle(fontSize: 10),
                              ),
                            const SizedBox(height: 4),
                            Text(m.content),
                          ],
                        ),
                      ),
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
                  controller: _msgController,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                  decoration: const InputDecoration(hintText: 'Type a message...'),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 90,
                child: OutlinedButton(
                  onPressed: _send,
                  child: const Text('Send'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
