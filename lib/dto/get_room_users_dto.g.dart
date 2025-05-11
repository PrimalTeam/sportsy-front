// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_room_users_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetRoomUsersDto _$GetRoomUsersDtoFromJson(Map<String, dynamic> json) =>
    GetRoomUsersDto(
      json['roles'] as List<dynamic>?,
      id: (json['id'] as num).toInt(),
      username: json['username'] as String,
      email: json['email'] as String,
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$GetRoomUsersDtoToJson(GetRoomUsersDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'email': instance.email,
      'roles': instance.roles,
      'createdAt': instance.createdAt,
    };
