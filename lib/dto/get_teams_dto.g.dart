// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_teams_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetTeamsDto _$GetTeamsDtoFromJson(Map<String, dynamic> json) => GetTeamsDto(
  name: json['name'] as String,
  id: (json['id'] as num).toInt(),
  tournamentId: (json['tournamentId'] as num).toInt(),
  icon:
      json['icon'] == null
          ? null
          : IconDto.fromJson(json['icon'] as Map<String, dynamic>),
);

Map<String, dynamic> _$GetTeamsDtoToJson(GetTeamsDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'icon': instance.icon,
      'name': instance.name,
      'tournamentId': instance.tournamentId,
    };

IconDto _$IconDtoFromJson(Map<String, dynamic> json) => IconDto(
  type: json['type'] as String,
  data: const Base64Converter().fromJson(json['data']),
);

Map<String, dynamic> _$IconDtoToJson(IconDto instance) => <String, dynamic>{
  'type': instance.type,
  'data': const Base64Converter().toJson(instance.data),
};
