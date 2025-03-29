import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class JwtStorageService {
  static const _jwtTokenKey = 'jwt_token';
  static const _refreshTokenKey = 'refresh_token';

  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  JwtStorageService();

   static Future<void> storeToken(String token) async {
    try {
      await _storage.write(key: _jwtTokenKey, value: token);
    } catch (e) {
      print("Error storing JWT token: $e");
    }
  }

  static Future<String?> getToken() async {
    try {
      return await _storage.read(key: _jwtTokenKey);
    } catch (e) {
      print("Error retrieving JWT token: $e");
      return null;
    }
  }

  static Future<void> storeRefreshToken(String refreshToken) async {
    try {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    } catch (e) {
      print("Error storing refresh token: $e");
    }
  }

  static Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      print("Error retrieving refresh token: $e");
      return null;
    }
  }

  static Future<void> clearTokens() async {
    try {
      await _storage.delete(key: _jwtTokenKey);
      await _storage.delete(key: _refreshTokenKey);
    } catch (e) {
      print("Error clearing tokens: $e");
    }
  }
}