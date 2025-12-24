/// 실시간(WebSocket)용 자리.
/// 지금 MVP에서는 사용하지 않고, 나중에 Socket.IO / WebSocket으로 교체할 수 있게 파일만 유지합니다.
class ChatSocket {
  Future<void> connect() async {}
  Future<void> disconnect() async {}
}
