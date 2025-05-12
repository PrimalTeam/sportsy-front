// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_info_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoomInfoDto _$RoomInfoDtoFromJson(Map<String, dynamic> json) => RoomInfoDto(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  icon: json['icon'] as String?,
  tournament:
      json['tournament'] == null
          ? null
          : GetTournamentDto.fromJson(
            json['tournament'] as Map<String, dynamic>,
          ),
);

Map<String, dynamic> _$RoomInfoDtoToJson(RoomInfoDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': instance.icon,
      'tournament': instance.tournament,
    };
