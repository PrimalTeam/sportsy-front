import 'package:dio/dio.dart';
import 'package:sportsy_front/dto/add_user_to_room_dto.dart';
import 'package:sportsy_front/dto/create_room_dto.dart';
import 'package:sportsy_front/dto/get_room_dto.dart';
import 'package:sportsy_front/dto/get_room_users_dto.dart';
import 'package:sportsy_front/dto/get_teams_dto.dart';
import 'package:sportsy_front/dto/get_tournament_dto.dart';
import 'package:sportsy_front/dto/room_info_dto.dart';
import 'package:sportsy_front/dto/team_add_dto.dart';
import 'package:sportsy_front/modules/services/auth_interceptor.dart';
import 'api.dart';
import 'jwt_logic.dart';
import '../../dto/auth_dto.dart';

class AuthService extends Interceptor {
  
  static final String baseUrl = hosturl;
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
    ),
  )..interceptors.add(AuthInterceptor()); // Pass Dio instance

  static Dio get dio => _dio; // Public getter for _dio

  static Future<Response> login(LoginDto login) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: login.toJson(),
      );
      
      final data = response.data;
      final jwtToken = data['access_token']; // JWT token
      final refreshToken = data['refresh_token']; // Refresh token

      JwtStorageService.storeToken(jwtToken);
      JwtStorageService.storeRefreshToken(refreshToken);

      return response;
    } on DioException catch (e) {
      print("Login error: ${e.response?.data}");
      throw Exception('Failed to login: ${e.response?.data}');
    }
  }

  static Future<Response> register(RegisterDto register) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: register.toJson(),
      );
      return response;
    } on DioException catch (e) {
      throw Exception('Failed to register: ${e.response?.data}');
    }
  }

    static Future<Response> test() async {
    try {
      final response = await _dio.get(
        '/user/dateinfo',
      );
      return response;
    } on DioException catch (e) {
      print("Registration error: ${e.response?.data}");
      throw Exception('Failed to register: ${e.response?.data}');
    }
  }

  static Future<Response> createRoom(CreateRoomDto createRoomDto) async {
    try {
      final Map<String, dynamic> data = createRoomDto.toJson();
      final response = await _dio.post(
        '/room/create',
        data: data,
      );
      return response;
    } on DioException catch (e) {
      print("Error during romm creation. Please try again: ${e.response?.data}");
      throw Exception('Failed to create room: ${e.response?.data}');
    }
  }

  static Future<List<GetRoomDto>> getRooms() async {
  try {
    final response = await _dio.get('/user/rooms'); 
    final List<dynamic> data = response.data;
    return data.map((room) => GetRoomDto.fromJson(room)).toList();
  } on DioException catch (e) {
    print("Error fetching rooms: ${e.response?.data}");
    throw Exception('Failed to fetch rooms: ${e.response?.data}');
  }
}

static Future<List<GetRoomUsersDto>> getRoomUsers(int roomId) async {
  try {
    final response = await _dio.get('/room/users/$roomId');

    print(response.data.runtimeType);
    print(response.data);

    final data = response.data as List;

    return data.map((user) =>
      GetRoomUsersDto.fromJson(user as Map<String, dynamic>)
    ).toList();
  } on DioException catch (e) {
    print("Error fetching room users: ${e.response?.data}");
    throw Exception('Failed to fetch room users: ${e.response?.data}');
  }
}
  static Future<Response> addUserToRoom(AddUserToRoomDto addUserToRoomDto, roomId) async {
    try {
      final Map<String, dynamic> data = addUserToRoomDto.toJson();
      final response = await _dio.post(
        '/roomUser/addUser/$roomId',
        data: data,
      );
      return response;
    } on DioException catch (e) {
      print("Error during adding User, please try again!: ${e.response?.data}");
      throw Exception('Failed to add User to Room: ${e.response?.data}');
    }
  }
  static Future<Response> deleteRoom(roomId) async {
    try {
      final response = await _dio.delete(
        '/room/$roomId',
      );
      return response;
    } on DioException catch (e) {
      print("Error during deleting Room, please try again!: ${e.response?.data}");
      throw Exception('Failed to delete Room: ${e.response?.data}');
    }
  }
    static Future<Response> deleteUser(roomId, userId) async {
    try {
      final response = await _dio.delete(
        '/roomUser/$roomId/$userId',
      );
      return response;
    } on DioException catch (e) {
      print("Error during deleting User from Room, please try again!: ${e.response?.data}");
      throw Exception('Failed to delete User from Room: ${e.response?.data}');
    }
  }

  static Future<RoomInfoDto> getRoomInfo(int roomId) async {
  try {
    final response = await _dio.get('/room/$roomId?include=tournament.games.teams&include=tournament.teams.games'); 
    final data = response.data as Map<String, dynamic>;
    return RoomInfoDto.fromJson(data);
  } on DioException catch (e) {
    print("Error fetching room informations: ${e.response?.data}");
    throw Exception('Failed to fetch room informations: ${e.response?.data}');
  }
}

static Future<Response> addTeam(TeamAddDto teamAddDto, int roomId) async {
  try {
    final Map<String, dynamic> data = teamAddDto.toJson(); 
    final response = await _dio.post(
      '/team/$roomId',
      data: data,
    );
    return response;
  } on DioException catch (e) {
    print("Error adding team: ${e.response?.data}"); 
    throw Exception('Failed to add team: ${e.response?.data}'); 
  }
}

static Future<List<GetTeamsDto>> getTeamsOfTournament(int tournamentId) async {
  try {
    final response = await _dio.get('/team/getByTournament/$tournamentId');
    final data = response.data;

    List<dynamic> list;
    if (data is Map<String, dynamic> && data.containsKey('teams')) {
      list = (data['teams'] as List<dynamic>);
    } else if (data is List) {
      list = data;
    } else {
      throw Exception('Unexpected response format: ${data.runtimeType}');
    }

    return list.map((team) => GetTeamsDto.fromJson(team as Map<String, dynamic>)).toList();
  } on DioException catch (e) {
    print('Error fetching teams of tournament: ${e.response?.data}');
    throw Exception('Failed to fetch teams of tournament: ${e.response?.data}');
  }
}
}