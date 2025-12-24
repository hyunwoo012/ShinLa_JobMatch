import 'package:dio/dio.dart';
import 'api_endpoints.dart';

class DioClient {
  DioClient._() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Content-Type': 'application/json'},
    ));
  }

  static final DioClient instance = DioClient._();
  late final Dio _dio;

  Dio get dio => _dio;

  void setAuthToken(String? token) {
    if (token == null || token.isEmpty) {
      _dio.options.headers.remove('Authorization');
    } else {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }
}
