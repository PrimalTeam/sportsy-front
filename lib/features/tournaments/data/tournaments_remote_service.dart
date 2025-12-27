import 'package:dio/dio.dart';
import 'package:sportsy_front/core/network/api_client.dart';
import 'package:sportsy_front/dto/get_tournament_dto.dart';

class TournamentsRemoteService {
  const TournamentsRemoteService._();

  static Dio get _dio => ApiClient.instance;

  static Future<GetTournamentDto> getTournament({
    required int roomId,
    required int tournamentId,
    List<String>? includes,
  }) async {
    final queryParameters = <String, dynamic>{};
    if (includes != null && includes.isNotEmpty) {
      queryParameters['include'] = includes;
    }

    try {
      final response = await _dio.get(
        '/tournament/$roomId/$tournamentId',
        queryParameters: queryParameters.isEmpty ? null : queryParameters,
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return GetTournamentDto.fromJson(data);
      }
      throw Exception('Unexpected tournament response: ${data.runtimeType}');
    } on DioException catch (e) {
      final message = e.response?.data ?? e.message;
      throw Exception('Failed to fetch tournament: $message');
    }
  }

  static Future<void> updateAutogenerateConfig({
    required int roomId,
    required int tournamentId,
    required bool autogenerate,
  }) async {
    try {
      await _dio.patch(
        '/tournament/$roomId/$tournamentId',
        data: {
          'internalConfig': {'autogenerateGamesFromLadder': autogenerate},
        },
      );
    } on DioException catch (e) {
      final message = e.response?.data ?? e.message;
      throw Exception('Failed to update tournament config: $message');
    }
  }
}
