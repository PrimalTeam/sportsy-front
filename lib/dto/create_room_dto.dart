import 'package:json_annotation/json_annotation.dart';
import 'package:sportsy_front/dto/tournament_dto.dart';

part 'create_room_dto.g.dart';

@JsonSerializable()
class CreateRoomDto {
  final String name;
  final TournamentDto tournament;
  CreateRoomDto(this.name, this.tournament);

  factory CreateRoomDto.fromJson(Map<String, dynamic> json) =>
      _$CreateRoomDtoFromJson(json);
  Map<String, dynamic> toJson() => _$CreateRoomDtoToJson(this);
}
