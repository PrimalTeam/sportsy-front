import 'package:dio/dio.dart';
import 'package:sportsy_front/core/network/api_client.dart';
import 'package:sportsy_front/dto/weather_forecast_dto.dart';

class WeatherRemoteService {
  const WeatherRemoteService._();

  static Dio get _dio => ApiClient.instance;

  static Future<WeatherForecastDto> getForecastByCoordinates({
    required double lat,
    required double lon,
  }) async {
    try {
      final response = await _dio.get(
        '/weather/forecast/coordinates',
        queryParameters: {
          'lat': lat,
          'lon': lon,
        },
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return WeatherForecastDto.fromJson(data);
      }
      throw Exception('Unexpected weather response shape');
    } on DioException catch (e) {
      final message = e.response?.data ?? e.message;
      throw Exception('Failed to fetch weather by coordinates: $message');
    }
  }

  static Future<WeatherForecastDto> getForecastByCity(String city) async {
    try {
      final response = await _dio.get(
        '/weather/forecast/city',
        queryParameters: {'city': city},
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return WeatherForecastDto.fromJson(data);
      }
      throw Exception('Unexpected weather response shape');
    } on DioException catch (e) {
      final message = e.response?.data ?? e.message;
      throw Exception('Failed to fetch weather by city: $message');
    }
  }
}
