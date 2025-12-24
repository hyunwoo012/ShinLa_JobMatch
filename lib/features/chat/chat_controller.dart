import 'package:flutter/foundation.dart';
import 'chat_api.dart';
import 'chat_model.dart';

class ChatController extends ChangeNotifier {
  final _api = ChatApi();

  List<ChatRoom> _rooms = [];
  List<ChatRoom> get rooms => _rooms;

  final Map<String, List<ChatMessage>> _messages = {};
  List<ChatMessage> messagesOf(String roomId) => _messages[roomId] ?? const [];

  Future<void> refreshRooms(String userId) async {
    _rooms = await _api.listRoomsForUser(userId);
    notifyListeners();
  }

  Future<String> getOrCreateRoom({
    required String postId,
    required String employerId,
    required String workerId,
  }) async {
    final roomId = await _api.getOrCreateRoom(
      postId: postId,
      employerId: employerId,
      workerId: workerId,
    );
    return roomId;
  }

  Future<void> loadMessages(String roomId) async {
    _messages[roomId] = await _api.listMessages(roomId);
    notifyListeners();
  }

  Future<void> send({
    required String roomId,
    required String senderId,
    required String text,
  }) async {
    await _api.sendMessage(roomId: roomId, senderId: senderId, text: text);
    await loadMessages(roomId);
  }
}
