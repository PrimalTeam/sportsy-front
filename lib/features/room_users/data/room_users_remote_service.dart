import 'package:dio/dio.dart';
import 'package:sportsy_front/core/network/api_client.dart';
import 'package:sportsy_front/dto/add_user_to_room_dto.dart';
import 'package:sportsy_front/dto/get_room_users_dto.dart';

class RoomUsersRemoteService {
  const RoomUsersRemoteService._();

  static Dio get _dio => ApiClient.instance;

  static Future<List<GetRoomUsersDto>> getRoomUsers(int roomId) async {
    try {
      final response = await _dio.get('/room/users/$roomId');
      final data = response.data as List<dynamic>;
      return data
          .whereType<Map<String, dynamic>>()
          .map(GetRoomUsersDto.fromJson)
          .toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch room users: ${e.response?.data}');
    }
  }

  static Future<Response> addUserToRoom(
    int roomId,
    AddUserToRoomDto addUserToRoomDto,
  ) async {
    try {
      return await _dio.post(
        '/roomUser/addUser/$roomId',
        data: addUserToRoomDto.toJson(),
      );
    } on DioException catch (e) {
      throw Exception('Failed to add User to Room: ${e.response?.data}');
    }
  }

  static Future<Response> deleteUser(int roomId, int userId) async {
    try {
      return await _dio.delete('/roomUser/$roomId/$userId');
    } on DioException catch (e) {
      throw Exception('Failed to delete User from Room: ${e.response?.data}');
    }
  }

  static Future<Response> updateRoomUser({
    required int roomId,
    required String identifier,
    required String identifierType,
    required String role,
  }) async {
    try {
      final body = {
        'roomId': roomId,
        'identifier': identifier,
        'identifierType': identifierType,
        'role': role,
      };
      return await _dio.patch('/roomUser/$roomId', data: body);
    } on DioException catch (e) {
      throw Exception('Failed to update Room User: ${e.response?.data}');
    }
  }
}
