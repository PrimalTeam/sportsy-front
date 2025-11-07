import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
class JwtStorageService {
  static const _jwtTokenKey = 'jwt_token';
  static const _refreshTokenKey = 'refresh_token';

  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  JwtStorageService();

  static Future<void> storeToken(String token) async {
    print('Storing Access Token: $token');
    await _storage.write(key: _jwtTokenKey, value: token);
  }

  static Future<String?> getToken() async {
    String? token = await _storage.read(key: _jwtTokenKey);
    print('Retrieved Access Token: $token');
    return token;
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
    static String? getDataFromToken(token, String dataType) {
    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      return decodedToken[dataType].toString();
    } catch (e) {
      print("Error retrieving token data: $e");
      return null;
    }
  }

  static Future<bool> isTokenMissingOrExpired() async {
    try {
      final token = await getToken();
      if (token == null || JwtDecoder.isExpired(token)) {
        return true;
      }
      return false;
    } catch (e) {
      print("Error checking token status: $e");
      return true;
    }
  }
}