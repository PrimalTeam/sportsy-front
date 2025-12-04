import 'dart:convert';
import 'dart:typed_data';

import 'package:json_annotation/json_annotation.dart';

part 'team_add_dto.g.dart';

@JsonSerializable()
class TeamAddDto {
  final String name;

  @JsonKey(fromJson: _uint8ListFromJson, toJson: _uint8ListToJson)
  final Uint8List icon;

  TeamAddDto(this.name, this.icon);

  factory TeamAddDto.fromJson(Map<String, dynamic> json) =>
      _$TeamAddDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TeamAddDtoToJson(this);

  // Konwersja z Base64 na Uint8List
  static Uint8List _uint8ListFromJson(String base64String) =>
      base64Decode(base64String);

  // Konwersja z Uint8List na Base64
  static String _uint8ListToJson(Uint8List uint8list) =>
      base64Encode(uint8list);
}
