import 'package:dio/dio.dart';
import 'jwt_logic.dart';
import 'auth.dart';
import '../../main.dart';

class AuthInterceptor extends Interceptor {
@override
Future<void> onRequest(
  RequestOptions options,
  RequestInterceptorHandler handler,
) async {
  final token = await JwtStorageService.getToken();
  print('Adding Authorization Header: Bearer $token');

  if (token != null && token.isNotEmpty) {
    options.headers['Authorization'] = 'Bearer $token';
  }
  handler.next(options);
}

@override
void onError(DioException err, ErrorInterceptorHandler handler) async {
  print('Dio Error: ${err.response?.data}');
  if (err.response?.statusCode == 401) {
    bool success = await _refreshToken();
    if (success) {
      String? newToken = await JwtStorageService.getToken();
      err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
      return handler.resolve(await AuthService.dio.fetch(err.requestOptions));
    } else {
      await JwtStorageService.clearTokens();
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    }
  }
  handler.next(err);
}

Future<bool> _refreshToken() async {
  try {
    String? refreshToken = await JwtStorageService.getRefreshToken();
    print('Refresh Token: $refreshToken');
    if (refreshToken == null || refreshToken.isEmpty) {
      print('Refresh token is null or empty');
      return false;
    }

    Response response = await AuthService.dio.post(
      '/auth/refresh/$refreshToken',
      options: Options(
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    print('Refresh Response: ${response.data}');

    if (response.statusCode == 201) {
      String newAccessToken = response.data['access_token'];
      String newRefreshToken = response.data['refresh_token'];

      await JwtStorageService.storeToken(newAccessToken);
      await JwtStorageService.storeRefreshToken(newRefreshToken);

      print('New Access Token: $newAccessToken');
      print('New Refresh Token: $newRefreshToken');

      return true;
    }
  } catch (e) {
    print('Refresh token failed: $e');
    if (e is DioException) {
      print('Dio Error: ${e.response?.data}');
    }
  }
  return false;
}
}
