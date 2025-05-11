import 'package:json_annotation/json_annotation.dart';

part 'get_room_users_dto.g.dart';

@JsonSerializable()
class GetRoomUsersDto {
  final int id;
  final String username;
  final String email;
  final List? roles;
  final String createdAt;

  GetRoomUsersDto(this.roles,{required this.id, required this.username, required this.email, required this.createdAt} );

  factory GetRoomUsersDto.fromJson(Map<String, dynamic> json) => _$GetRoomUsersDtoFromJson(json['user']);
  Map<String, dynamic> toJson() => _$GetRoomUsersDtoToJson(this);
}