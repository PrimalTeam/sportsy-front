import 'package:sportsy_front/dto/get_teams_dto.dart';

class TeamDetailsDto {
  TeamDetailsDto({
    required this.name,
    this.icon,
    this.sportType,
    this.tournament,
    this.teamUsers = const [],
    this.games = const [],
    this.teamStatuses = const [],
  });

  final String name;
  final IconDto? icon;
  final String? sportType;
  final TeamTournamentInfo? tournament;
  final List<String> teamUsers;
  final List<TeamGameInfo> games;
  final List<TeamScoreInfo> teamStatuses;

  factory TeamDetailsDto.fromJson(Map<String, dynamic> json) {
    final tournamentMap = json['tournament'] as Map<String, dynamic>?;
    return TeamDetailsDto(
      name: _readString(json['name']) ?? 'Unknown team',
      icon: _parseIcon(json['icon']),
      sportType:
          _readString(json['sportType']) ??
          _readString(tournamentMap?['sportType']),
      tournament: TeamTournamentInfo.fromJson(tournamentMap),
      teamUsers: _parseTeamUsers(json['teamUsers']),
      games: _parseGames(json['games']),
      teamStatuses: _parseScores(json['teamStatuses']),
    );
  }

  static IconDto? _parseIcon(Object? raw) {
    if (raw is Map<String, dynamic>) {
      try {
        return IconDto.fromJson(raw);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static List<String> _parseTeamUsers(Object? raw) {
    if (raw is! List) return const [];
    final result = <String>[];
    for (final entry in raw) {
      final name = _extractTeamUserName(entry);
      if (name != null && name.isNotEmpty) {
        result.add(name);
      }
    }
    return result;
  }

  static List<TeamGameInfo> _parseGames(Object? raw) {
    if (raw is! List) return const [];
    final result = <TeamGameInfo>[];
    for (final entry in raw) {
      if (entry is Map<String, dynamic>) {
        result.add(TeamGameInfo.fromJson(entry));
      }
    }
    return result;
  }

  static List<TeamScoreInfo> _parseScores(Object? raw) {
    if (raw is! List) return const [];
    final result = <TeamScoreInfo>[];
    for (final entry in raw) {
      if (entry is Map<String, dynamic>) {
        result.add(TeamScoreInfo.fromJson(entry));
      }
    }
    return result;
  }

  static DateTime? _parseDate(Object? raw) {
    if (raw is String && raw.isNotEmpty) {
      return DateTime.tryParse(raw);
    }
    return null;
  }

  static int? _asInt(Object? raw) {
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw);
    return null;
  }

  static String? _readString(Object? raw) {
    if (raw is String && raw.isNotEmpty) return raw;
    return null;
  }

  static String? _extractTeamUserName(Object? raw) {
    if (raw is Map<String, dynamic>) {
      final name = _readString(raw['name']);
      final surname = _readString(raw['surname']);
      final username = _readString(raw['username']);

      final buffer = StringBuffer();
      if (name != null) buffer.write(name);
      if (surname != null) {
        if (buffer.isNotEmpty) buffer.write(' ');
        buffer.write(surname);
      }
      if (buffer.isEmpty && username != null) {
        buffer.write(username);
      }
      return buffer.isEmpty ? null : buffer.toString();
    }
    if (raw is String && raw.isNotEmpty) {
      return raw;
    }
    return null;
  }

  static List<String> _parseTeamNames(Object? raw) {
    if (raw is! List) return const [];
    final result = <String>[];
    for (final entry in raw) {
      if (entry is String && entry.isNotEmpty) {
        result.add(entry);
      } else if (entry is Map<String, dynamic>) {
        final name = _readString(entry['name']) ?? _readString(entry['team']);
        if (name != null) result.add(name);
      }
    }
    return result;
  }
}

class TeamTournamentInfo {
  const TeamTournamentInfo({
    this.id,
    this.title,
    this.description,
    this.start,
    this.end,
    this.leaderType,
  });

  final int? id;
  final String? title;
  final String? description;
  final DateTime? start;
  final DateTime? end;
  final String? leaderType;

  static TeamTournamentInfo? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final info = json['info'] as Map<String, dynamic>?;
    final result = TeamTournamentInfo(
      id: TeamDetailsDto._asInt(json['id']),
      title:
          TeamDetailsDto._readString(info?['title']) ??
          TeamDetailsDto._readString(json['title']),
      description: TeamDetailsDto._readString(info?['description']),
      start: TeamDetailsDto._parseDate(info?['dateStart']),
      end: TeamDetailsDto._parseDate(info?['dateEnd']),
      leaderType: TeamDetailsDto._readString(json['leaderType']),
    );
    final hasContent =
        result.title != null ||
        result.description != null ||
        result.start != null ||
        result.end != null ||
        result.leaderType != null;
    return hasContent ? result : null;
  }
}

class TeamGameInfo {
  const TeamGameInfo({
    this.id,
    this.status,
    this.dateStart,
    this.duration,
    this.teamNames = const [],
    this.teamStatuses = const [],
  });

  final int? id;
  final String? status;
  final DateTime? dateStart;
  final String? duration;
  final List<String> teamNames;
  final List<TeamScoreInfo> teamStatuses;

  factory TeamGameInfo.fromJson(Map<String, dynamic> json) {
    return TeamGameInfo(
      id: TeamDetailsDto._asInt(json['id']),
      status: TeamDetailsDto._readString(json['status']),
      dateStart: TeamDetailsDto._parseDate(json['dateStart']),
      duration: TeamDetailsDto._readString(json['durationTime']),
      teamNames: TeamDetailsDto._parseTeamNames(json['teams']),
      teamStatuses: TeamDetailsDto._parseScores(json['teamStatuses']),
    );
  }
}

class TeamScoreInfo {
  const TeamScoreInfo({this.teamId, this.teamName, this.score});

  final int? teamId;
  final String? teamName;
  final int? score;

  factory TeamScoreInfo.fromJson(Map<String, dynamic> json) {
    final teamField = json['team'];
    String? resolvedName;
    if (teamField is String) {
      resolvedName = teamField;
    } else if (teamField is Map<String, dynamic>) {
      resolvedName = TeamDetailsDto._readString(teamField['name']);
    }

    return TeamScoreInfo(
      teamId: TeamDetailsDto._asInt(json['teamId']),
      teamName: resolvedName,
      score: TeamDetailsDto._asInt(json['score']),
    );
  }
}
