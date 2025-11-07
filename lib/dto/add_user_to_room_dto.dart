import 'package:json_annotation/json_annotation.dart';

part 'add_user_to_room_dto.g.dart';

@JsonSerializable()
class AddUserToRoomDto {
  final String role;
  final String identifier;
  final String identifierType;


AddUserToRoomDto({
  required this.role,
  required this.identifier,
  required this.identifierType,
  });

  factory AddUserToRoomDto.fromJson(Map<String, dynamic> json) => _$AddUserToRoomDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AddUserToRoomDtoToJson(this);
}