import 'package:json_annotation/json_annotation.dart';
import 'get_tournament_dto.dart';

part 'room_info_dto.g.dart';

@JsonSerializable()
class RoomInfoDto {
  final int id;
  final String name;
  final String? icon;
  final GetTournamentDto? tournament;

  RoomInfoDto({
    required this.id,
    required this.name,
    this.icon,
    this.tournament,
  });

  factory RoomInfoDto.fromJson(Map<String, dynamic> json) =>
      _$RoomInfoDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RoomInfoDtoToJson(this);
}
