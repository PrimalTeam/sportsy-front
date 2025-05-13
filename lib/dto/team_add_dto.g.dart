// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_add_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TeamAddDto _$TeamAddDtoFromJson(Map<String, dynamic> json) => TeamAddDto(
  json['name'] as String,
  TeamAddDto._uint8ListFromJson(json['icon'] as String),
);

Map<String, dynamic> _$TeamAddDtoToJson(TeamAddDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'icon': TeamAddDto._uint8ListToJson(instance.icon),
    };
