// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_room_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetRoomDto _$GetRoomDtoFromJson(Map<String, dynamic> json) => GetRoomDto(
  json['icon'] as String?,
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  role: json['role'] as String,
);

Map<String, dynamic> _$GetRoomDtoToJson(GetRoomDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': instance.icon,
      'role': instance.role,
    };
