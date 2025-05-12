import 'dart:convert';
import 'dart:typed_data';

class GetTeamsDto {
  final String name;
  final String tournamentId;
  final Uint8List icon;

  GetTeamsDto({
    required this.name,
    required this.tournamentId,
    required this.icon,
  });

  factory GetTeamsDto.fromJson(Map<String, dynamic> json) {
    return GetTeamsDto(
      name: json['name'] as String,
      tournamentId: json['tournamentId'].toString(),
      icon: json['icon'] != null ? base64Decode(json['icon']) : Uint8List(0),
    );
  }
}