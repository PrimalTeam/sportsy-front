import 'package:dio/dio.dart';
import 'api.dart';
import 'jwt_logic.dart';
import '../../dto/auth_dto.dart';

class AuthService {
  static final String baseUrl = '$hosturl/auth';
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
    ),
  );
  
  static Future<Response> login(LoginDto login) async {
    try {
      final response = await _dio.post(
        '/login',
        data: login.toJson(),
      );
      
      final data = response.data;
      final jwtToken = data['access_token']; // JWT token
      final refreshToken = data['refresh_token']; // Refresh token

      JwtStorageService.storeToken(jwtToken);
      JwtStorageService.storeRefreshToken(refreshToken);

      return response;
    } on DioException catch (e) {
      print("Login error: ${e.response?.data}");
      throw Exception('Failed to login: ${e.response?.data}');
    }
  }

  static Future<Response> register(RegisterDto register) async {
    try {
      final response = await _dio.post(
        '/register',
        data: register.toJson(),
      );
      return response;
    } on DioException catch (e) {
      print("Registration error: ${e.response?.data}");
      throw Exception('Failed to register: ${e.response?.data}');
    }
  }
}