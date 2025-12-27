import 'package:json_annotation/json_annotation.dart';

part 'get_room_users_dto.g.dart';

@JsonSerializable()
class GetRoomUsersDto {
  final int id;
  final String role;
  final int userId;
  final int roomId;
  final UserDto user;

  GetRoomUsersDto({
    required this.id,
    required this.role,
    required this.userId,
    required this.roomId,
    required this.user,
  });

  factory GetRoomUsersDto.fromJson(Map<String, dynamic> json) =>
      _$GetRoomUsersDtoFromJson(json);
  Map<String, dynamic> toJson() => _$GetRoomUsersDtoToJson(this);
}

@JsonSerializable()
class UserDto {
  final int id;
  final String username;
  final String email;
  final List<dynamic>? roles;
  final String createdAt;

  UserDto({
    required this.id,
    required this.username,
    required this.email,
    this.roles,
    required this.createdAt,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);
  Map<String, dynamic> toJson() => _$UserDtoToJson(this);
}
