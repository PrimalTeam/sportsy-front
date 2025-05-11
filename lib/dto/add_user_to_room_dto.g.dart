// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_user_to_room_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddUserToRoomDto _$AddUserToRoomDtoFromJson(Map<String, dynamic> json) =>
    AddUserToRoomDto(
      role: json['role'] as String,
      identifier: json['identifier'] as String,
      identifierType: json['identifierType'] as String,
    );

Map<String, dynamic> _$AddUserToRoomDtoToJson(AddUserToRoomDto instance) =>
    <String, dynamic>{
      'role': instance.role,
      'identifier': instance.identifier,
      'identifierType': instance.identifierType,
    };
