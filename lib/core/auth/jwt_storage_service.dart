import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class JwtStorageService {
  static const _jwtTokenKey = 'jwt_token';
  static const _refreshTokenKey = 'refresh_token';

  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static Future<void> storeToken(String token) async {
    await _storage.write(key: _jwtTokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return _storage.read(key: _jwtTokenKey);
  }

  static Future<void> storeRefreshToken(String refreshToken) async {
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  static Future<String?> getRefreshToken() async {
    return _storage.read(key: _refreshTokenKey);
  }

  static Future<void> clearTokens() async {
    await _storage.delete(key: _jwtTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  static String? getDataFromToken(String token, String dataType) {
    try {
      final decodedToken = JwtDecoder.decode(token);
      final value = decodedToken[dataType];
      return value?.toString();
    } catch (_) {
      return null;
    }
  }

  static Future<bool> isTokenMissingOrExpired() async {
    try {
      final token = await getToken();
      if (token == null) {
        return true;
      }
      return JwtDecoder.isExpired(token);
    } catch (_) {
      return true;
    }
  }
}
