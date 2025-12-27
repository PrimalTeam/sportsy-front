import 'package:dio/dio.dart';
import 'package:sportsy_front/core/network/api_client.dart';

class TeamStatusRemoteService {
  const TeamStatusRemoteService._();

  static Dio get _dio => ApiClient.instance;

  static Future<void> updateTeamScore({
    required int roomId,
    required int gameId,
    required int teamId,
    required num score,
  }) async {
    try {
      await _dio.patch(
        '/teamStatus/$roomId/$gameId/$teamId',
        data: {'score': score},
      );
    } on DioException catch (e) {
      final message = e.response?.data ?? e.message;
      throw Exception('Failed to update team score: $message');
    }
  }
}
