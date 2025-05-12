// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_room_users_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetRoomUsersDto _$GetRoomUsersDtoFromJson(Map<String, dynamic> json) =>
    GetRoomUsersDto(
      id: (json['id'] as num).toInt(),
      role: json['role'] as String,
      userId: (json['userId'] as num).toInt(),
      roomId: (json['roomId'] as num).toInt(),
      user: UserDto.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GetRoomUsersDtoToJson(GetRoomUsersDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'role': instance.role,
      'userId': instance.userId,
      'roomId': instance.roomId,
      'user': instance.user,
    };

UserDto _$UserDtoFromJson(Map<String, dynamic> json) => UserDto(
  id: (json['id'] as num).toInt(),
  username: json['username'] as String,
  email: json['email'] as String,
  roles: json['roles'] as List<dynamic>?,
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$UserDtoToJson(UserDto instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'email': instance.email,
  'roles': instance.roles,
  'createdAt': instance.createdAt,
};
