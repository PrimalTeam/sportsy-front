import 'package:dio/dio.dart';
import 'package:sportsy_front/core/network/api_client.dart';
import 'package:sportsy_front/dto/create_room_dto.dart';
import 'package:sportsy_front/dto/get_room_dto.dart';
import 'package:sportsy_front/dto/room_info_dto.dart';

class RoomsRemoteService {
  const RoomsRemoteService._();

  static Dio get _dio => ApiClient.instance;

  static Future<Response> createRoom(CreateRoomDto createRoomDto) async {
    try {
      return await _dio.post('/room/create', data: createRoomDto.toJson());
    } on DioException catch (e) {
      throw Exception('Failed to create room: ${e.response?.data}');
    }
  }

  static Future<List<GetRoomDto>> getRooms() async {
    try {
      final response = await _dio.get('/user/rooms');
      final data = response.data as List<dynamic>;
      return data
          .whereType<Map<String, dynamic>>()
          .map(GetRoomDto.fromJson)
          .toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch rooms: ${e.response?.data}');
    }
  }

  static Future<RoomInfoDto> getRoomInfo(int roomId) async {
    try {
      final response = await _dio.get(
        '/room/$roomId?include=tournament.games.teams&include=tournament.teams.games',
      );
      final data = response.data as Map<String, dynamic>;
      return RoomInfoDto.fromJson(data);
    } on DioException catch (e) {
      throw Exception('Failed to fetch room informations: ${e.response?.data}');
    }
  }

  static Future<Response> deleteRoom(int roomId) async {
    try {
      return await _dio.delete('/room/$roomId');
    } on DioException catch (e) {
      throw Exception('Failed to delete Room: ${e.response?.data}');
    }
  }
}
