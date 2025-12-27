import 'package:dio/dio.dart';
import 'package:sportsy_front/core/network/api_client.dart';
import 'package:sportsy_front/dto/game_create_dto.dart';
import 'package:sportsy_front/dto/game_get_dto.dart';

class GamesRemoteService {
  const GamesRemoteService._();

  static Dio get _dio => ApiClient.instance;

  static Future<Response> createGame({
    required int roomId,
    required int tournamentId,
    required GameCreateDto game,
  }) async {
    try {
      return await _dio.post(
        '/game/$roomId/$tournamentId',
        data: game.toJson(),
      );
    } on DioException catch (e) {
      throw Exception('Failed to create game: ${e.response?.data}');
    }
  }

  static Future<List<GameGetDto>> getGamesByTournament(int roomId) async {
    try {
      final response = await _dio.get('/game/getByTournament/$roomId');
      final data = response.data;
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(GameGetDto.fromJson)
            .toList();
      }
      throw Exception('Unexpected games response format: ${data.runtimeType}');
    } on DioException catch (e) {
      throw Exception(
        'Failed to fetch games: ${e.response?.data ?? e.message}',
      );
    }
  }

  static Future<void> updateGame({
    required int roomId,
    required int gameId,
    String? status,
    DateTime? dateStart,
    String? durationTime,
  }) async {
    final payload = <String, dynamic>{};
    if (status != null) payload['status'] = status;
    if (dateStart != null) payload['dateStart'] = dateStart.toIso8601String();
    if (durationTime != null) payload['durationTime'] = durationTime;

    if (payload.isEmpty) {
      return;
    }

    try {
      await _dio.patch('/game/$roomId/$gameId', data: payload);
    } on DioException catch (e) {
      final message = e.response?.data ?? e.message;
      throw Exception('Failed to update game: $message');
    }
  }

  static Future<List<String>> getGameStatuses() async {
    try {
      final response = await _dio.get('/game/getGameStatuses');
      final data = response.data;
      if (data is List) {
        return data.whereType<String>().toList();
      }
      throw Exception('Unexpected status response: ${data.runtimeType}');
    } on DioException catch (e) {
      final message = e.response?.data ?? e.message;
      throw Exception('Failed to fetch game statuses: $message');
    }
  }

  static Future<GameGetDto> getGameById({
    required int roomId,
    required int gameId,
    List<String> include = const ['teams', 'teamStatuses', 'teamStatuses.team'],
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (include.isNotEmpty) {
        queryParams['include'] = include;
      }
      final response = await _dio.get(
        '/game/$roomId/$gameId',
        queryParameters: queryParams,
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return GameGetDto.fromJson(data);
      }
      throw Exception('Unexpected game response format: ${data.runtimeType}');
    } on DioException catch (e) {
      final message = e.response?.data ?? e.message;
      throw Exception('Failed to fetch game: $message');
    }
  }

  static Future<void> deleteGame(int roomId, int gameId) async {
    try {
      await _dio.delete('/game/$roomId/$gameId');
    } on DioException catch (e) {
      final message = e.response?.data ?? e.message;
      throw Exception('Failed to delete game: $message');
    }
  }
}
