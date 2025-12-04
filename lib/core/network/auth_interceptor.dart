import 'package:dio/dio.dart';
import 'package:sportsy_front/core/auth/jwt_storage_service.dart';
import 'package:sportsy_front/main.dart';

import 'api_client.dart';

class AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await JwtStorageService.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      final refreshed = await _refreshToken();
      if (refreshed) {
        final newToken = await JwtStorageService.getToken();
        if (newToken != null && newToken.isNotEmpty) {
          err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
        }
        try {
          final retryResponse = await ApiClient.instance.fetch(
            err.requestOptions,
          );
          return handler.resolve(retryResponse);
        } catch (retryError) {
          handler.next(err);
          return;
        }
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
    final refreshToken = await JwtStorageService.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    try {
      final response = await ApiClient.instance.post(
        '/auth/refresh/$refreshToken',
        options: Options(headers: const {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        final newAccessToken = data['access_token'] as String?;
        final newRefreshToken = data['refresh_token'] as String?;

        if (newAccessToken == null || newRefreshToken == null) {
          return false;
        }

        await JwtStorageService.storeToken(newAccessToken);
        await JwtStorageService.storeRefreshToken(newRefreshToken);
        return true;
      }
    } catch (_) {
      return false;
    }
    return false;
  }
}
