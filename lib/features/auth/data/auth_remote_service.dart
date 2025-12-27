import 'package:dio/dio.dart';
import 'package:sportsy_front/core/auth/jwt_storage_service.dart';
import 'package:sportsy_front/core/network/api_client.dart';
import 'package:sportsy_front/dto/auth_dto.dart';

class AuthRemoteService {
  const AuthRemoteService._();

  static Dio get _dio => ApiClient.instance;

  static Future<Response> login(LoginDto login) async {
    try {
      final response = await _dio.post('/auth/login', data: login.toJson());
      final data = response.data as Map<String, dynamic>;
      final jwtToken = data['access_token'] as String?;
      final refreshToken = data['refresh_token'] as String?;

      if (jwtToken != null) {
        await JwtStorageService.storeToken(jwtToken);
      }
      if (refreshToken != null) {
        await JwtStorageService.storeRefreshToken(refreshToken);
      }

      return response;
    } on DioException catch (e) {
      final reason =
          e.message ?? e.response?.data?.toString() ?? 'Unknown network error';
      throw Exception('Failed to login: $reason');
    }
  }

  static Future<Response> register(RegisterDto register) async {
    try {
      return await _dio.post('/auth/register', data: register.toJson());
    } on DioException catch (e) {
      throw Exception('Failed to register: ${e.response?.data}');
    }
  }

  static Future<Response> healthCheck() async {
    try {
      return await _dio.get('/user/dateinfo');
    } on DioException catch (e) {
      throw Exception('Failed to reach server: ${e.response?.data}');
    }
  }
}
