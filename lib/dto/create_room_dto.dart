import 'package:json_annotation/json_annotation.dart';

part 'create_room_dto.g.dart';

@JsonSerializable()

class CreateRoomDto {
  final String name;
  CreateRoomDto(this.name);

  factory CreateRoomDto.fromJson(Map<String, dynamic> json) => _$CreateRoomDtoFromJson(json);
  Map<String, dynamic> toJson() => _$CreateRoomDtoToJson(this);
}