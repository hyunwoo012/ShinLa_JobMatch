class ApiEndpoints {
  static const String baseUrl = 'http://localhost:8080'; // 실서버 연결 시 변경

  // Auth
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';
  static const String me = '/auth/me';

  // Jobs
  static const String jobs = '/jobs';
  static String jobDetail(String id) => '/jobs/$id';

  // Chat
  static const String chatRooms = '/chats/rooms';
  static String chatRoomDetail(String id) => '/chats/rooms/$id';

  // Profile
  static const String profile = '/profile';
  static String profileById(String userId) => '/profile/$userId';
}
