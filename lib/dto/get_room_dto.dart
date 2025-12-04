import 'package:json_annotation/json_annotation.dart';

part 'get_room_dto.g.dart';

@JsonSerializable()
class GetRoomDto {
  final int id;
  final String name;
  final String? icon;
  final String role;

  GetRoomDto(
    this.icon, {
    required this.id,
    required this.name,
    required this.role,
  });

  factory GetRoomDto.fromJson(Map<String, dynamic> json) =>
      _$GetRoomDtoFromJson(json);
  Map<String, dynamic> toJson() => _$GetRoomDtoToJson(this);
}
