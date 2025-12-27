// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_tournament_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetTournamentDto _$GetTournamentDtoFromJson(Map<String, dynamic> json) =>
    GetTournamentDto(
      id: (json['id'] as num).toInt(),
      sportType: json['sportType'] as String,
      leaderType: json['leaderType'] as String,
      roomId: (json['roomId'] as num).toInt(),
      info: TournamentInfo.fromJson(json['info'] as Map<String, dynamic>),
      games: json['games'] as List<dynamic>? ?? [],
      teams: json['teams'] as List<dynamic>? ?? [],
      internalConfig:
          json['internalConfig'] == null
              ? null
              : TournamentInternalConfigDto.fromJson(
                json['internalConfig'] as Map<String, dynamic>,
              ),
      leader: TournamentLeaderTree.fromJson(json['leader']),
    );

Map<String, dynamic> _$GetTournamentDtoToJson(GetTournamentDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sportType': instance.sportType,
      'leaderType': instance.leaderType,
      'roomId': instance.roomId,
      'info': instance.info,
      'games': instance.games,
      'teams': instance.teams,
      'internalConfig': instance.internalConfig,
      'leader': TournamentLeaderTree.toJson(instance.leader),
    };

TournamentInfo _$TournamentInfoFromJson(Map<String, dynamic> json) =>
    TournamentInfo(
      description: json['description'] as String,
      title: json['title'] as String,
      dateStart: DateTime.parse(json['dateStart'] as String),
      dateEnd: DateTime.parse(json['dateEnd'] as String),
    );

Map<String, dynamic> _$TournamentInfoToJson(TournamentInfo instance) =>
    <String, dynamic>{
      'description': instance.description,
      'title': instance.title,
      'dateStart': instance.dateStart.toIso8601String(),
      'dateEnd': instance.dateEnd.toIso8601String(),
    };

TournamentInternalConfigDto _$TournamentInternalConfigDtoFromJson(
  Map<String, dynamic> json,
) => TournamentInternalConfigDto(
  autogenerateGamesFromLadder:
      json['autogenerateGamesFromLadder'] as bool? ?? false,
);

Map<String, dynamic> _$TournamentInternalConfigDtoToJson(
  TournamentInternalConfigDto instance,
) => <String, dynamic>{
  'autogenerateGamesFromLadder': instance.autogenerateGamesFromLadder,
};
