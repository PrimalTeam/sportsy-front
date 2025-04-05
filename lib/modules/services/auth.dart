import 'package:dio/dio.dart';
import 'package:sportsy_front/modules/services/auth_interceptor.dart';
import 'api.dart';
import 'jwt_logic.dart';
import '../../dto/auth_dto.dart';

class AuthService extends Interceptor {
  
  static final String baseUrl = hosturl;
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
    ),
  )..interceptors.add(AuthInterceptor()); // Pass Dio instance

  static Dio get dio => _dio; // Public getter for _dio

  static Future<Response> login(LoginDto login) async {
    try {
      final response = await _dio.post(
        '/auth/login',
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
        '/auth/register',
        data: register.toJson(),
      );
      return response;
    } on DioException catch (e) {
      print("Registration error: ${e.response?.data}");
      throw Exception('Failed to register: ${e.response?.data}');
    }
  }

    static Future<Response> test() async {
    try {
      final response = await _dio.get(
        '/user/dateinfo',
      );
      return response;
    } on DioException catch (e) {
      print("Registration error: ${e.response?.data}");
      throw Exception('Failed to register: ${e.response?.data}');
    }
  }
}