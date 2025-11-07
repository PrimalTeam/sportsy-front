// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tournament_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TournamentDto _$TournamentDtoFromJson(Map<String, dynamic> json) =>
    TournamentDto(
      InfoDto.fromJson(json['info'] as Map<String, dynamic>),
      json['leaderType'] as String,
      json['sportType'] as String,
      (json['games'] as List<dynamic>?)
              ?.map((e) => GamesDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      (json['teams'] as List<dynamic>?)
              ?.map((e) => TeamAddDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$TournamentDtoToJson(TournamentDto instance) =>
    <String, dynamic>{
      'info': instance.info,
      'sportType': instance.sportType,
      'leaderType': instance.leaderType,
      'games': instance.games,
      'teams': instance.teams,
    };

InfoDto _$InfoDtoFromJson(Map<String, dynamic> json) => InfoDto(
  DateTime.parse(json['dateEnd'] as String),
  json['description'] as String,
  json['title'] as String,
);

Map<String, dynamic> _$InfoDtoToJson(InfoDto instance) => <String, dynamic>{
  'description': instance.description,
  'title': instance.title,
  'dateEnd': instance.dateEnd.toIso8601String(),
};

GamesDto _$GamesDtoFromJson(Map<String, dynamic> json) =>
    GamesDto(json['status'] as String);

Map<String, dynamic> _$GamesDtoToJson(GamesDto instance) => <String, dynamic>{
  'status': instance.status,
};
