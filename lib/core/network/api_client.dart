import 'package:dio/dio.dart';
import 'package:sportsy_front/core/network/api_config.dart';

import 'auth_interceptor.dart';

class ApiClient {
  ApiClient._();

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseApiUrl,
      headers: const {'Content-Type': 'application/json; charset=UTF-8'},
    ),
  )..interceptors.add(AuthInterceptor());

  static Dio get instance => _dio;
}
