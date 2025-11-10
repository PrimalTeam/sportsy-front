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
        // Handle data URI prefixes like "data:image/png;base64,...."
        String s = json;
        if (s.contains(',') && s.contains('base64')) {
          s = s.substring(s.lastIndexOf(',') + 1);
        }
        // remove whitespace/newlines
        s = s.replaceAll(RegExp(r"\s+"), "");
        // support URL-safe base64
        s = s.replaceAll('-', '+').replaceAll('_', '/');
        return base64Decode(base64.normalize(s));
      } catch (_) {
        try {
          // Last resort: normalize padding/spaces
          final s = json.replaceAll(RegExp(r"\s+"), "");
          return base64Decode(base64.normalize(s));
        } catch (_) {
          return null;
        }
      }
    }

    // list of ints (bytes) OR ascii codes of a base64 string
    if (json is List) {
      try {
        final ints = json.map((e) => e is int ? e : (e is num ? e.toInt() : 0)).toList(growable: false);

        // Heuristic: if values look like ASCII text, try to decode as base64 string first
        final bool looksAscii = ints.isNotEmpty && ints.every((v) => v >= 32 && v <= 126);
        if (looksAscii) {
          String asString = String.fromCharCodes(ints);
          asString = asString.replaceAll(RegExp(r"\s+"), "");
          try {
            String s = asString;
            if (s.contains(',') && s.contains('base64')) {
              s = s.substring(s.lastIndexOf(',') + 1);
            }
            s = s.replaceAll('-', '+').replaceAll('_', '/');
            return base64Decode(base64.normalize(s));
          } catch (_) {
            // fall back to raw bytes below
          }
        }

        final raw = Uint8List.fromList(ints);
        // Validate common image signatures (PNG, JPEG, WebP) to catch wrong path early
        if (_isLikelyImage(raw)) return raw;
        return raw; // even if not recognized, return bytes
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

  bool _isLikelyImage(Uint8List bytes) {
    if (bytes.lengthInBytes < 8) return false;
    // PNG: 89 50 4E 47 0D 0A 1A 0A
    const png = [137, 80, 78, 71, 13, 10, 26, 10];
    bool isPng = true;
    for (int i = 0; i < png.length; i++) {
      if (bytes[i] != png[i]) { isPng = false; break; }
    }
    if (isPng) return true;

    // JPEG: FF D8 ... FF D9
    if (bytes[0] == 0xFF && bytes[1] == 0xD8) return true;

    // WebP: 'RIFF'....'WEBP'
    if (bytes.length >= 12) {
      final riff = bytes.sublist(0, 4);
      final webp = bytes.sublist(8, 12);
      if (String.fromCharCodes(riff) == 'RIFF' && String.fromCharCodes(webp) == 'WEBP') return true;
    }
    return false;
  }
}
// ...existing code...