import '../../core/common/utils.dart';
import 'chat_model.dart';

class ChatApi {
  static final List<ChatRoom> _rooms = [];
  static final Map<String, List<ChatMessage>> _messagesByRoom = {};

  Future<String> getOrCreateRoom({
    required String postId,
    required String employerId,
    required String workerId,
  }) async {
    final existing = _rooms.where((r) => r.postId == postId && r.workerId == workerId).toList();
    if (existing.isNotEmpty) return existing.first.roomId;

    final roomId = UiUtils.newId();
    final room = ChatRoom(
      roomId: roomId,
      postId: postId,
      employerId: employerId,
      workerId: workerId,
      createdAt: DateTime.now(),
    );
    _rooms.add(room);
    _messagesByRoom[roomId] = [];
    return roomId;
  }

  Future<List<ChatRoom>> listRoomsForUser(String userId) async {
    final rooms = _rooms.where((r) => r.employerId == userId || r.workerId == userId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(rooms);
  }

  Future<List<ChatMessage>> listMessages(String roomId) async {
    return List.unmodifiable(_messagesByRoom[roomId] ?? []);
  }

  Future<void> sendMessage({
    required String roomId,
    required String senderId,
    required String text,
  }) async {
    final msg = ChatMessage(
      messageId: UiUtils.newId(),
      roomId: roomId,
      senderId: senderId,
      text: text,
      createdAt: DateTime.now(),
    );
    _messagesByRoom.putIfAbsent(roomId, () => []);
    _messagesByRoom[roomId]!.add(msg);
  }
}
