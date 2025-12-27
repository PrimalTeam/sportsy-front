import 'get_teams_dto.dart';

class GameTeamStatusSummary {
  final int? teamId;
  final int score;
  final String? teamName;

  const GameTeamStatusSummary({
    this.teamId,
    required this.score,
    this.teamName,
  });

  GameTeamStatusSummary copyWith({int? teamId, int? score, String? teamName}) {
    return GameTeamStatusSummary(
      teamId: teamId ?? this.teamId,
      score: score ?? this.score,
      teamName: teamName ?? this.teamName,
    );
  }
}

class GameGetDto {
  final int id;
  final String status;
  final DateTime? dateStart;
  final String? durationTime;
  final int? tournamentId;
  final List<int> teamIds;
  final List<GameTeamStatusSummary> teamStatuses;
  final List<GetTeamsDto> teams;

  GameGetDto({
    required this.id,
    required this.status,
    required this.dateStart,
    required this.durationTime,
    required this.tournamentId,
    required this.teamIds,
    required this.teamStatuses,
    required this.teams,
  });

  GameGetDto copyWith({
    String? status,
    DateTime? dateStart,
    String? durationTime,
    int? tournamentId,
    List<int>? teamIds,
    List<GameTeamStatusSummary>? teamStatuses,
    List<GetTeamsDto>? teams,
  }) {
    return GameGetDto(
      id: id,
      status: status ?? this.status,
      dateStart: dateStart ?? this.dateStart,
      durationTime: durationTime ?? this.durationTime,
      tournamentId: tournamentId ?? this.tournamentId,
      teamIds: teamIds ?? this.teamIds,
      teamStatuses: teamStatuses ?? this.teamStatuses,
      teams: teams ?? this.teams,
    );
  }

  factory GameGetDto.fromJson(Map<String, dynamic> json) {
    final rawTeams = json['teams'];
    final parsedTeams = <GetTeamsDto>[];
    if (rawTeams is List) {
      for (final entry in rawTeams) {
        final dto = _parseTeam(entry, json['tournamentId']);
        if (dto != null) {
          parsedTeams.add(dto);
        }
      }
    }

    final rawTeamIds = json['teamIds'];
    final teamIds = <int>[];
    if (rawTeamIds is List) {
      for (final item in rawTeamIds) {
        final value = _asInt(item);
        if (value != null) teamIds.add(value);
      }
    }

    final rawStatuses = json['teamStatuses'];
    final statuses = <GameTeamStatusSummary>[];
    if (rawStatuses is List) {
      for (final item in rawStatuses) {
        if (item is Map<String, dynamic>) {
          final teamId = _asInt(item['teamId']);
          final score = _asInt(item['score']) ?? 0;
          String? teamName;
          if (item['team'] is Map<String, dynamic>) {
            final nested = item['team'] as Map<String, dynamic>;
            final name = nested['name'];
            if (name is String && name.isNotEmpty) {
              teamName = name;
            }
          }
          statuses.add(
            GameTeamStatusSummary(
              teamId: teamId,
              score: score,
              teamName: teamName,
            ),
          );
        }
      }
    }

    final status = json['status']?.toString() ?? 'Pending';
    final duration = json['durationTime']?.toString();
    final tournamentId = _asInt(json['tournamentId']);
    final dateStartRaw = json['dateStart'];
    DateTime? dateStart;
    if (dateStartRaw is String) {
      dateStart = DateTime.tryParse(dateStartRaw);
    } else if (dateStartRaw is int) {
      dateStart = DateTime.fromMillisecondsSinceEpoch(dateStartRaw);
    }

    return GameGetDto(
      id: _asInt(json['id']) ?? 0,
      status: status,
      dateStart: dateStart,
      durationTime: duration,
      tournamentId: tournamentId,
      teamIds: teamIds,
      teamStatuses: statuses,
      teams: parsedTeams,
    );
  }

  static GetTeamsDto? _parseTeam(dynamic entry, dynamic fallbackTournamentId) {
    if (entry is Map<String, dynamic>) {
      // Backend may return team data directly or wrapped in 'team' key
      final Map<String, dynamic> source =
          entry['team'] is Map<String, dynamic>
              ? Map<String, dynamic>.from(entry['team'] as Map<String, dynamic>)
              : Map<String, dynamic>.from(entry);

      // Try multiple common id/name field patterns
      final id = _asInt(source['id']) ?? _asInt(source['teamId']);
      final name = source['name'] as String? ?? source['teamName'] as String?;

      if (id == null || name == null || name.isEmpty) {
        return null;
      }

      int? tournamentId = _asInt(source['tournamentId']);
      tournamentId ??= _asInt(entry['tournamentId']);
      tournamentId ??= _asInt(fallbackTournamentId);

      IconDto? icon;
      final iconRaw = source['icon'];
      if (iconRaw is Map<String, dynamic>) {
        try {
          icon = IconDto.fromJson(iconRaw);
        } catch (_) {
          icon = null;
        }
      }

      return GetTeamsDto(
        name: name,
        id: id,
        tournamentId: tournamentId ?? 0,
        icon: icon,
      );
    }
    return null;
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return null;
  }

  List<String> get teamNames {
    if (teams.isNotEmpty) {
      return teams.map((t) => t.name).where((name) => name.isNotEmpty).toList();
    }
    if (teamStatuses.isNotEmpty) {
      return teamStatuses
          .map((status) => status.teamName)
          .whereType<String>()
          .where((name) => name.isNotEmpty)
          .toList();
    }
    return const [];
  }

  String get durationLabel => durationTime ?? '-';
}
