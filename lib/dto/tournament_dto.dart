import 'package:json_annotation/json_annotation.dart';
import 'package:sportsy_front/dto/team_add_dto.dart';

part 'tournament_dto.g.dart';

@JsonSerializable()
class InternalConfigDto {
  final bool autogenerateGamesFromLadder;

  InternalConfigDto({this.autogenerateGamesFromLadder = true});

  factory InternalConfigDto.fromJson(Map<String, dynamic> json) =>
      _$InternalConfigDtoFromJson(json);
  Map<String, dynamic> toJson() => _$InternalConfigDtoToJson(this);
}

@JsonSerializable()
class TournamentDto {
  final InfoDto info;
  final String sportType;
  final String leaderType;
  @JsonKey(defaultValue: [])
  final List<GamesDto> games;
  @JsonKey(defaultValue: [])
  final List<TeamAddDto> teams;
  final InternalConfigDto? internalConfig;

  TournamentDto(
    this.info,
    this.leaderType,
    this.sportType,
    this.games,
    this.teams, {
    this.internalConfig,
  });

  factory TournamentDto.fromJson(Map<String, dynamic> json) =>
      _$TournamentDtoFromJson(json);
  Map<String, dynamic> toJson() => _$TournamentDtoToJson(this);
}

@JsonSerializable()
class InfoDto {
  final String description;
  final String title;
  final DateTime dateEnd;

  InfoDto(this.dateEnd, this.description, this.title);

  factory InfoDto.fromJson(Map<String, dynamic> json) =>
      _$InfoDtoFromJson(json);
  Map<String, dynamic> toJson() => _$InfoDtoToJson(this);
}

@JsonSerializable()
class GamesDto {
  final String status;

  GamesDto(this.status);

  factory GamesDto.fromJson(Map<String, dynamic> json) =>
      _$GamesDtoFromJson(json);
  Map<String, dynamic> toJson() => _$GamesDtoToJson(this);
}
