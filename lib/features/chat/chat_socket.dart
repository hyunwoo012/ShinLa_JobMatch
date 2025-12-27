import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

typedef OnMessage = void Function(Map<String, dynamic> data);

class ChatSocket {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  final String wsBaseUrl; // 예: ws://host:8000  또는 wss://host
  final String accessToken;
  final int roomId;
  final OnMessage onMessage;

  bool _connected = false;

  ChatSocket({
    required this.wsBaseUrl,
    required this.accessToken,
    required this.roomId,
    required this.onMessage,
  });

  bool get isConnected => _connected;

  Future<void> connect() async {
    if (_connected) return;

    // 서버: /ws/chat/{roomId}?token=...
    final url =
        '$wsBaseUrl/ws/chat/$roomId?token=${Uri.encodeComponent(accessToken)}';

    _channel = WebSocketChannel.connect(Uri.parse(url));
    _connected = true;

    _subscription = _channel!.stream.listen(
          (event) {
        // FastAPI send_json -> 문자열 JSON으로 들어오는 것이 일반적
        final decoded = jsonDecode(event as String);
        if (decoded is Map<String, dynamic>) {
          onMessage(decoded);
        }
      },
      onError: (_) {
        _connected = false;
      },
      onDone: () {
        _connected = false;
      },
    );
  }

  void send(String content) {
    if (!_connected || _channel == null) return;

    // 서버가 receive_json() 후 data["content"]를 읽음
    _channel!.sink.add(jsonEncode({"content": content}));
  }

  Future<void> disconnect() async {
    await _subscription?.cancel();
    await _channel?.sink.close();
    _subscription = null;
    _channel = null;
    _connected = false;
  }
}
