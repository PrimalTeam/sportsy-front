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
}
