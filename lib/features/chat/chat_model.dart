class ChatRoom {
  ChatRoom({
    required this.roomId,
    required this.postId,
    required this.employerId,
    required this.workerId,
    required this.createdAt,
  });

  final String roomId;
  final String postId;
  final String employerId;
  final String workerId;
  final DateTime createdAt;
}

class ChatMessage {
  ChatMessage({
    required this.messageId,
    required this.roomId,
    required this.senderId,
    required this.text,
    required this.createdAt,
  });

  final String messageId;
  final String roomId;
  final String senderId;
  final String text;
  final DateTime createdAt;
}
