import 'package:jwt_decoder/jwt_decoder.dart';

bool isTokenExpired(String token) {
  return JwtDecoder.isExpired(token);
}