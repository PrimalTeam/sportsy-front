// ...existing code...
import 'dart:convert';
import 'dart:typed_data';
import 'package:json_annotation/json_annotation.dart';

part 'get_teams_dto.g.dart';

@JsonSerializable()
class GetTeamsDto {
  final int id;
  final IconDto? icon;
  final String name;
  final int tournamentId;

  GetTeamsDto({
    required this.name,
    required this.id,
    required this.tournamentId,
    this.icon,
  });

  factory GetTeamsDto.fromJson(Map<String, dynamic> json) => _$GetTeamsDtoFromJson(json);
  Map<String, dynamic> toJson() => _$GetTeamsDtoToJson(this);
}

@JsonSerializable()
class IconDto {
  final String type;

  @Base64Converter()
  final Uint8List? data;

  IconDto({required this.type, this.data});

  factory IconDto.fromJson(Map<String, dynamic> json) => _$IconDtoFromJson(json);
  Map<String, dynamic> toJson() => _$IconDtoToJson(this);
}

class Base64Converter implements JsonConverter<Uint8List?, Object?> {
  const Base64Converter();

  @override
  Uint8List? fromJson(Object? json) {
    if (json == null) return null;

    // base64 string
    if (json is String) {
      try {
        return base64Decode(json);
      } catch (_) {
        return null;
      }
    }

    // list of ints (bytes)
    if (json is List) {
      try {
        return Uint8List.fromList(json.cast<int>());
      } catch (_) {
        return null;
      }
    }

    // maybe structure like { "data": [...] } or nested
    if (json is Map && json.containsKey('data')) {
      return fromJson(json['data']);
    }

    return null;
  }

  @override
  Object? toJson(Uint8List? object) => object == null ? null : base64Encode(object);
}
// ...existing code...