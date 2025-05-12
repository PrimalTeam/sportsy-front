// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_room_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateRoomDto _$CreateRoomDtoFromJson(Map<String, dynamic> json) =>
    CreateRoomDto(
      json['name'] as String,
      TournamentDto.fromJson(json['tournament'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CreateRoomDtoToJson(CreateRoomDto instance) =>
    <String, dynamic>{'name': instance.name, 'tournament': instance.tournament};
