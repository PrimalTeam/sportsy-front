import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:sportsy_front/core/network/api_client.dart';
import 'package:sportsy_front/dto/get_teams_dto.dart';
import 'package:sportsy_front/dto/team_details_dto.dart';
import 'package:sportsy_front/dto/team_add_dto.dart';

class TeamsRemoteService {
  const TeamsRemoteService._();

  static Dio get _dio => ApiClient.instance;

  static Future<Response> addTeam(int roomId, TeamAddDto teamAddDto) async {
    try {
      return await _dio.post('/team/$roomId', data: teamAddDto.toJson());
    } on DioException catch (e) {
      throw Exception('Failed to add team: ${e.response?.data}');
    }
  }

  static Future<List<GetTeamsDto>> getTeamsOfTournament(
    int roomId,
  ) async {
    try {
      final response = await _dio.get('/team/getByTournament/$roomId');
      final data = response.data;

      late final List<dynamic> list;
      if (data is Map<String, dynamic> && data.containsKey('teams')) {
        list = data['teams'] as List<dynamic>;
      } else if (data is List) {
        list = data;
      } else {
        throw Exception('Unexpected response format: ${data.runtimeType}');
      }

      return list
          .map((e) => GetTeamsDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(
        'Failed to fetch teams of tournament: ${e.response?.data}',
      );
    }
  }

  static Future<Response> updateTeam({
    required int roomId,
    required int id,
    required String name,
    Uint8List? icon,
  }) async {
    try {
      final body = {'name': name, if (icon != null) 'icon': base64Encode(icon)};
      return await _dio.patch('/team/$roomId/$id', data: body);
    } on DioException catch (e) {
      throw Exception('Failed to update team: ${e.response?.data}');
    }
  }

  static Future<TeamDetailsDto> getTeamDetails({
    required int roomId,
    required int teamId,
  }) async {
    try {
      final response = await _dio.get('/team/$roomId/$teamId');
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception(
          'Unexpected team detail format: ${data.runtimeType}',
        );
      }
      return TeamDetailsDto.fromJson(data);
    } on DioException catch (e) {
      throw Exception('Failed to fetch team details: ${e.response?.data}');
    }
  }
}
