import 'package:flutter/foundation.dart';

import '../../core/api/api_endpoints.dart';
import 'chat_api.dart';
import 'chat_model.dart';
import 'chat_socket.dart';

class ChatController extends ChangeNotifier {
  final ChatApi _api;
  ChatController(this._api);

  List<ChatRoomOut> _rooms = [];
  List<ChatRoomOut> get rooms => _rooms;

  final Map<int, List<ChatMessageOut>> _messagesByRoom = {};
  List<ChatMessageOut> messages(int roomId) => _messagesByRoom[roomId] ?? const [];

  // roomId -> socket
  final Map<int, ChatSocket> _sockets = {};

  /// baseUrl(http/https + /api)을 ws/wss + (api 제거)로 변환
  String _computeWsBaseUrl() {
    final base = ApiEndpoints.baseUrl; // 예: http://host:8000/api
    final uri = Uri.parse(base);

    final scheme = (uri.scheme == 'https') ? 'wss' : 'ws';

    // path에서 /api 또는 /api/ 제거
    var path = uri.path;
    path = path.replaceAll(RegExp(r'/api/?$'), '');

    // wsBaseUrl은 "호스트까지만" 유지하는 게 가장 안전
    // (뒤에서 /ws/chat/... 을 붙이므로)
    return uri.replace(scheme: scheme, path: path, query: '', fragment: '').toString();
  }

  Future<void> refreshRooms() async {
    _rooms = await _api.listRooms();
    notifyListeners();
  }

  Future<ChatRoomOut> createRoom({
    required int jobPostId,
    required int studentId,
  }) async {
    final room = await _api.createRoom(jobPostId: jobPostId, studentId: studentId);
    await refreshRooms();
    return room;
  }

  Future<void> refreshMessages(int roomId) async {
    _messagesByRoom[roomId] = await _api.listMessages(roomId);
    notifyListeners();
  }

  /// =========================
  /// WebSocket: connect
  /// =========================
  Future<void> connectSocket({
    required int roomId,
    required String accessToken,
  }) async {
    if (_sockets.containsKey(roomId)) return;

    final wsBaseUrl = _computeWsBaseUrl();

    final socket = ChatSocket(
      wsBaseUrl: wsBaseUrl,
      accessToken: accessToken,
      roomId: roomId,
      onMessage: (data) {
        if (data['type'] == 'message') {
          _onWsMessage(roomId, data);
        }
      },
    );

    _sockets[roomId] = socket;
    await socket.connect();
  }

  Future<void> disconnectSocket(int roomId) async {
    final s = _sockets.remove(roomId);
    await s?.disconnect();
  }

  /// =========================
  /// WebSocket: send
  /// =========================
  void sendWs(int roomId, String content) {
    _sockets[roomId]?.send(content);
  }

  void _onWsMessage(int roomId, Map<String, dynamic> payload) {
    final msg = ChatMessageOut.fromJson(payload);

    _messagesByRoom.putIfAbsent(roomId, () => []);

    // 중복 방지 (서버 echo + 히스토리 겹침 대비)
    final exists = _messagesByRoom[roomId]!.any((m) => m.id == msg.id);
    if (exists) return;

    _messagesByRoom[roomId]!.add(msg);
    notifyListeners();
  }

  /// 읽음 처리(HTTP)
  Future<void> read(int roomId) async {
    await _api.markRead(roomId);
  }
}
