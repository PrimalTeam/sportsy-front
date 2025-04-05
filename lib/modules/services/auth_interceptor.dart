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

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token'; // Remove the Authorization header
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      bool success = await _refreshToken();
       await JwtStorageService.clearTokens();
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
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
      if (refreshToken == null || refreshToken.isEmpty) return false;

      Response response = await AuthService.dio.post(
        '/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        String newAccessToken = response.data['access_token'];
        String newRefreshToken = response.data['refresh_token'];

        await JwtStorageService.storeToken(newAccessToken);
        await JwtStorageService.storeRefreshToken(newRefreshToken);

        return true;
      }
    } catch (e) {
      print('Refresh token failed: $e');
    }
    return false;
  }
}
