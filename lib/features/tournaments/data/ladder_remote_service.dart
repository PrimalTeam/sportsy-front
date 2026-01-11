import 'package:dio/dio.dart';
import 'package:sportsy_front/core/network/api_client.dart';
import 'package:sportsy_front/dto/get_tournament_dto.dart';

class LadderRemoteService {
  const LadderRemoteService._();

  static Dio get _dio => ApiClient.instance;

  static Future<TournamentLeaderTree?> updateLadder({
    required int roomId,
  }) async {
    try {
      final response = await _dio.get('/ladder/update/$roomId');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final mainLadder = data['mainLadder'];
        final preGames = data['preGames'];
        return TournamentLeaderTree.fromJson({
          'mainLadder': mainLadder,
          'preGames': preGames,
          'type': data['type'],
        });
      }
      return null;
    } on DioException catch (e) {
      final message = e.response?.data ?? e.message;
      throw Exception('Failed to update ladder: $message');
    }
  }

  static Future<void> generateLadder({
    required int roomId,
    bool resetExistingGames = false,
  }) async {
    try {
      await _dio.get(
        '/ladder/generateLadder/$roomId',
        queryParameters: resetExistingGames ? const {'reset': true} : null,
      );
    } on DioException catch (e) {
      final message = e.response?.data ?? e.message;
      throw Exception('Failed to generate ladder: $message');
    }
  }

  static Future<void> deleteLadder({
    required int roomId,
    bool resetGames = true,
  }) async {
    try {
      await _dio.delete(
        '/ladder/delete/$roomId',
        queryParameters: {'resetGames': resetGames},
      );
    } on DioException catch (e) {
      final message = e.response?.data ?? e.message;
      throw Exception('Failed to delete ladder: $message');
    }
  }

  static Future<void> resetGames({
    required int roomId,
    required int tournamentId,
  }) async {
    try {
      await _dio.post('/game/reset/$roomId/$tournamentId');
    } on DioException catch (e) {
      final message = e.response?.data ?? e.message;
      throw Exception('Failed to reset tournament games: $message');
    }
  }
}
