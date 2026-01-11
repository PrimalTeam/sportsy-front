import 'dart:convert';

class WeatherForecastDto {
  const WeatherForecastDto({
    required this.city,
    required this.country,
    required this.forecast,
  });

  final String city;
  final String country;
  final List<ForecastItemDto> forecast;

  factory WeatherForecastDto.fromJson(Map<String, dynamic> json) {
    final rawForecast = json['forecast'];
    return WeatherForecastDto(
      city: json['city'] as String? ?? '',
      country: json['country'] as String? ?? '',
      forecast: _parseForecast(rawForecast),
    );
  }

  static List<ForecastItemDto> _parseForecast(dynamic raw) {
    if (raw == null) return const <ForecastItemDto>[];
    if (raw is String) {
      final trimmed = raw.trim();
      if (trimmed.isEmpty) return const <ForecastItemDto>[];
      try {
        final decoded = jsonDecode(trimmed);
        raw = decoded;
      } catch (_) {
        return const <ForecastItemDto>[];
      }
    }
    if (raw is List) {
      return raw
          .whereType<Map<String, dynamic>>()
          .map(ForecastItemDto.fromJson)
          .toList();
    }
    return const <ForecastItemDto>[];
  }
}

class ForecastItemDto {
  const ForecastItemDto({
    required this.dateTime,
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.pressure,
    required this.description,
    required this.icon,
    required this.windSpeed,
    required this.clouds,
    required this.pop,
  });

  final String dateTime;
  final double temperature;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final int pressure;
  final String description;
  final String icon;
  final double windSpeed;
  final int clouds;
  final double pop;

  factory ForecastItemDto.fromJson(Map<String, dynamic> json) {
    double _asDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) {
        final parsed = double.tryParse(value);
        return parsed ?? 0;
      }
      return 0;
    }

    int _asInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value);
        return parsed ?? 0;
      }
      return 0;
    }

    return ForecastItemDto(
      dateTime: json['dateTime'] as String? ?? '',
      temperature: _asDouble(json['temperature']),
      feelsLike: _asDouble(json['feelsLike']),
      tempMin: _asDouble(json['tempMin']),
      tempMax: _asDouble(json['tempMax']),
      humidity: _asInt(json['humidity']),
      pressure: _asInt(json['pressure']),
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      windSpeed: _asDouble(json['windSpeed']),
      clouds: _asInt(json['clouds']),
      pop: _asDouble(json['pop']),
    );
  }
}
