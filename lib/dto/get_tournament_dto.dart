import 'package:json_annotation/json_annotation.dart';

part 'get_tournament_dto.g.dart';

@JsonSerializable()
class GetTournamentDto {
  final int id;
  final String sportType;
  final String leaderType;
  final int roomId;
  final TournamentInfo info;
  @JsonKey(defaultValue: [])
  final List games;
  @JsonKey(defaultValue: [])
  final List teams;

  GetTournamentDto({
    required this.id,
    required this.sportType,
    required this.leaderType,
    required this.roomId,
    required this.info,
    required this.games,
    required this.teams
  });

  factory GetTournamentDto.fromJson(Map<String, dynamic> json) =>
      _$GetTournamentDtoFromJson(json);

  Map<String, dynamic> toJson() => _$GetTournamentDtoToJson(this);
}

@JsonSerializable()
class TournamentInfo {
  final String description;
  final String title;
  final DateTime dateStart;
  final DateTime dateEnd;

  TournamentInfo({
    required this.description,
    required this.title,
    required this.dateStart,
    required this.dateEnd,
  });

  factory TournamentInfo.fromJson(Map<String, dynamic> json) =>
      _$TournamentInfoFromJson(json);

  Map<String, dynamic> toJson() => _$TournamentInfoToJson(this);
}
