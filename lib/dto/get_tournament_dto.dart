import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'get_tournament_dto.g.dart';

@JsonSerializable()
class GetTournamentDto {
  final int id;
  final String sportType;
  final String leaderType;
  final int roomId;
  final TournamentInfo info;
  @JsonKey(defaultValue: [])
  final List games;
  @JsonKey(defaultValue: [])
  final List teams;
  final TournamentInternalConfigDto? internalConfig;
  @JsonKey(
    fromJson: TournamentLeaderTree.fromJson,
    toJson: TournamentLeaderTree.toJson,
  )
  final TournamentLeaderTree? leader;

  GetTournamentDto({
    required this.id,
    required this.sportType,
    required this.leaderType,
    required this.roomId,
    required this.info,
    required this.games,
    required this.teams,
    this.internalConfig,
    this.leader,
  });

  factory GetTournamentDto.fromJson(Map<String, dynamic> json) =>
      _$GetTournamentDtoFromJson(json);

  Map<String, dynamic> toJson() => _$GetTournamentDtoToJson(this);
}

@JsonSerializable()
class TournamentInfo {
  final String description;
  final String title;
  final DateTime dateStart;
  final DateTime dateEnd;

  TournamentInfo({
    required this.description,
    required this.title,
    required this.dateStart,
    required this.dateEnd,
  });

  factory TournamentInfo.fromJson(Map<String, dynamic> json) =>
      _$TournamentInfoFromJson(json);

  Map<String, dynamic> toJson() => _$TournamentInfoToJson(this);
}

@JsonSerializable()
class TournamentInternalConfigDto {
  const TournamentInternalConfigDto({this.autogenerateGamesFromLadder = false});

  @JsonKey(defaultValue: false)
  final bool autogenerateGamesFromLadder;

  factory TournamentInternalConfigDto.fromJson(Map<String, dynamic> json) =>
      _$TournamentInternalConfigDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TournamentInternalConfigDtoToJson(this);
}

/// Standings entry for round robin tournaments
class RoundRobinStanding {
  const RoundRobinStanding({
    required this.teamId,
    required this.teamName,
    this.wins = 0,
    this.losses = 0,
    this.draws = 0,
    this.points = 0,
    this.gamesPlayed = 0,
  });

  final int teamId;
  final String teamName;
  final int wins;
  final int losses;
  final int draws;
  final int points;
  final int gamesPlayed;

  factory RoundRobinStanding.fromJson(Map<String, dynamic> json) {
    return RoundRobinStanding(
      teamId: json['teamId'] as int? ?? 0,
      teamName: json['teamName'] as String? ?? '',
      wins: json['wins'] as int? ?? 0,
      losses: json['losses'] as int? ?? 0,
      draws: json['draws'] as int? ?? 0,
      points: json['points'] as int? ?? 0,
      gamesPlayed: json['gamesPlayed'] as int? ?? 0,
    );
  }
}

class TournamentLeaderTree {
  const TournamentLeaderTree({
    this.root,
    this.type,
    this.preGames = const <TournamentLeaderNode>[],
    // Double elimination
    this.winnersBracket,
    this.losersBracket,
    this.grandFinal,
    // Round robin
    this.games = const <TournamentLeaderNode>[],
    this.standings = const <RoundRobinStanding>[],
    this.rounds = 0,
  });

  final TournamentLeaderNode? root;
  final String? type;
  final List<TournamentLeaderNode> preGames;

  // Double elimination fields
  final TournamentLeaderNode? winnersBracket;
  final TournamentLeaderNode? losersBracket;
  final TournamentLeaderNode? grandFinal;

  // Round robin fields
  final List<TournamentLeaderNode> games;
  final List<RoundRobinStanding> standings;
  final int rounds;

  bool get isSingleElimination => type == 'single-elimination' || (root != null && winnersBracket == null);
  bool get isDoubleElimination => type == 'double-elimination' || winnersBracket != null;
  bool get isRoundRobin => type == 'round-robin' || (games.isNotEmpty && root == null && winnersBracket == null);

  static TournamentLeaderTree? fromJson(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty || trimmed == '{}' || trimmed == '[]') {
        return null;
      }
      try {
        value = jsonDecode(trimmed);
      } catch (_) {
        return null;
      }
    }
    if (value is Map<String, dynamic>) {
      final typeCandidate = value['typeOfLeader'] ?? value['type'];

      // Check for double elimination structure
      if (value.containsKey('winnersBracket') || value.containsKey('losersBracket')) {
        return _parseDoubleElimination(value, typeCandidate as String?);
      }

      // Check for round robin structure
      if (value.containsKey('standings') || (value.containsKey('games') && value['games'] is List)) {
        return _parseRoundRobin(value, typeCandidate as String?);
      }

      // Single elimination (default)
      return _parseSingleElimination(value, typeCandidate as String?);
    }
    if (value is List) {
      return TournamentLeaderTree(preGames: _parseNodeList(value));
    }
    return null;
  }

  static TournamentLeaderTree _parseSingleElimination(Map<String, dynamic> value, String? type) {
    final mainCandidate =
        value['leader'] ??
        value['mainLadder'] ??
        value['main'] ??
        value['root'];
    TournamentLeaderNode? root;
    if (mainCandidate is Map<String, dynamic>) {
      root = TournamentLeaderNode.fromJson(mainCandidate);
    } else if (mainCandidate is List) {
      final firstNode = mainCandidate.firstWhere(
        (entry) => entry is Map<String, dynamic>,
        orElse: () => null,
      );
      if (firstNode is Map<String, dynamic>) {
        root = TournamentLeaderNode.fromJson(firstNode);
      }
    } else if (_looksLikeNode(value)) {
      root = TournamentLeaderNode.fromJson(value);
    }

    final preGames = _parseNodeList(value['preGames']);

    return TournamentLeaderTree(
      root: root,
      type: type ?? 'single-elimination',
      preGames: preGames,
    );
  }

  static TournamentLeaderTree _parseDoubleElimination(Map<String, dynamic> value, String? type) {
    TournamentLeaderNode? winnersBracket;
    TournamentLeaderNode? losersBracket;
    TournamentLeaderNode? grandFinal;

    if (value['winnersBracket'] is Map<String, dynamic>) {
      winnersBracket = TournamentLeaderNode.fromJson(value['winnersBracket']);
    }
    if (value['losersBracket'] is Map<String, dynamic>) {
      losersBracket = TournamentLeaderNode.fromJson(value['losersBracket']);
    }
    if (value['grandFinal'] is Map<String, dynamic>) {
      grandFinal = TournamentLeaderNode.fromJson(value['grandFinal']);
    }

    return TournamentLeaderTree(
      type: type ?? 'double-elimination',
      winnersBracket: winnersBracket,
      losersBracket: losersBracket,
      grandFinal: grandFinal,
    );
  }

  static TournamentLeaderTree _parseRoundRobin(Map<String, dynamic> value, String? type) {
    final gamesList = <TournamentLeaderNode>[];
    final standingsList = <RoundRobinStanding>[];

    if (value['games'] is List) {
      for (final game in value['games']) {
        if (game is Map<String, dynamic>) {
          gamesList.add(TournamentLeaderNode.fromJson(game));
        }
      }
    }

    if (value['standings'] is Map<String, dynamic>) {
      final standingsMap = value['standings'] as Map<String, dynamic>;
      for (final entry in standingsMap.values) {
        if (entry is Map<String, dynamic>) {
          standingsList.add(RoundRobinStanding.fromJson(entry));
        }
      }
      // Sort by points descending
      standingsList.sort((a, b) => b.points.compareTo(a.points));
    }

    return TournamentLeaderTree(
      type: type ?? 'round-robin',
      games: gamesList,
      standings: standingsList,
      rounds: value['rounds'] as int? ?? 0,
    );
  }

  static Map<String, dynamic>? toJson(TournamentLeaderTree? tree) {
    if (tree == null) return null;
    final map = <String, dynamic>{};
    if (tree.type != null) {
      map['typeOfLeader'] = tree.type;
    }
    if (tree.root != null) {
      map['mainLadder'] = tree.root!.toJson();
    }
    if (tree.preGames.isNotEmpty) {
      map['preGames'] = tree.preGames.map((node) => node.toJson()).toList();
    }
    if (tree.winnersBracket != null) {
      map['winnersBracket'] = tree.winnersBracket!.toJson();
    }
    if (tree.losersBracket != null) {
      map['losersBracket'] = tree.losersBracket!.toJson();
    }
    if (tree.grandFinal != null) {
      map['grandFinal'] = tree.grandFinal!.toJson();
    }
    if (tree.games.isNotEmpty) {
      map['games'] = tree.games.map((node) => node.toJson()).toList();
    }
    return map.isEmpty ? null : map;
  }

  static List<TournamentLeaderNode> _parseNodeList(dynamic raw) {
    if (raw is String) {
      final trimmed = raw.trim();
      if (trimmed.isEmpty || trimmed == '[]') {
        return const <TournamentLeaderNode>[];
      }
      try {
        final parsed = jsonDecode(trimmed);
        raw = parsed;
      } catch (_) {
        return const <TournamentLeaderNode>[];
      }
    }
    if (raw is List) {
      final nodes = <TournamentLeaderNode>[];
      for (final entry in raw) {
        if (entry is Map<String, dynamic>) {
          nodes.add(TournamentLeaderNode.fromJson(entry));
        }
      }
      return nodes;
    }
    return const <TournamentLeaderNode>[];
  }

  static bool _looksLikeNode(Map<String, dynamic> value) {
    return value.containsKey('childrens') ||
        value.containsKey('children') ||
        value.containsKey('teams') ||
        value.containsKey('roundNumber');
  }
}

class TournamentLeaderNode {
  const TournamentLeaderNode({
    this.name,
    this.description,
    this.roundNumber,
    this.status,
    this.gameId,
    required this.teamEntries,
    required this.children,
  });

  final String? name;
  final String? description;
  final int? roundNumber;
  final String? status;
  final int? gameId;
  final List<TournamentLeaderTeam> teamEntries;
  final List<TournamentLeaderNode> children;

  List<String> get teamNames =>
      teamEntries
          .map((team) => team.name?.trim())
          .whereType<String>()
          .where((name) => name.isNotEmpty)
          .toList();

  bool get hasScores =>
      teamEntries.any((team) => team.score != null && team.score!.isFinite);

  factory TournamentLeaderNode.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const TournamentLeaderNode(teamEntries: [], children: []);
    }

    var childrenSource = json['children'] ?? json['childrens'];
    if (childrenSource is String) {
      final trimmed = childrenSource.trim();
      if (trimmed.isNotEmpty && trimmed != '[]') {
        try {
          childrenSource = jsonDecode(trimmed);
        } catch (_) {
          childrenSource = const <dynamic>[];
        }
      } else {
        childrenSource = const <dynamic>[];
      }
    }
    childrenSource ??= const <dynamic>[];
    final children = <TournamentLeaderNode>[];
    if (childrenSource is List) {
      for (final child in childrenSource) {
        if (child is Map<String, dynamic>) {
          children.add(TournamentLeaderNode.fromJson(child));
        }
      }
    }

    return TournamentLeaderNode(
      name: json['name'] as String?,
      description: json['description'] as String?,
      roundNumber: _asInt(json['roundNumber'] ?? json['round']),
      status: json['status'] as String?,
      gameId: _asInt(json['gameId']),
      teamEntries: _parseTeams(json['teams']),
      children: children,
    );
  }

  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (description != null) 'description': description,
    if (roundNumber != null) 'roundNumber': roundNumber,
    if (status != null) 'status': status,
    if (gameId != null) 'gameId': gameId,
    'teams': teamEntries.map((team) => team.toJson()).toList(),
    'childrens': children.map((child) => child.toJson()).toList(),
  };

  static List<TournamentLeaderTeam> _parseTeams(dynamic raw) {
    if (raw is String) {
      final trimmed = raw.trim();
      if (trimmed.isEmpty || trimmed == '[]') {
        return const [];
      }
      try {
        raw = jsonDecode(trimmed);
      } catch (_) {
        return const [];
      }
    }
    if (raw is List) {
      final teams = <TournamentLeaderTeam>[];
      for (final entry in raw) {
        final team = TournamentLeaderTeam.fromDynamic(entry);
        if (team != null) {
          teams.add(team);
        }
      }
      return teams;
    }
    if (raw is Map<String, dynamic>) {
      final team = TournamentLeaderTeam.fromDynamic(raw);
      return team == null ? const [] : [team];
    }
    if (raw is String) {
      final team = TournamentLeaderTeam.fromDynamic(raw);
      return team == null ? const [] : [team];
    }
    return const [];
  }
}

class TournamentLeaderTeam {
  const TournamentLeaderTeam({this.id, this.name, this.score});

  final int? id;
  final String? name;
  final num? score;

  static TournamentLeaderTeam? fromDynamic(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return null;
      return TournamentLeaderTeam(name: trimmed);
    }
    if (value is Map<String, dynamic>) {
      final nested = value['team'];
      final rawName = value['name'] ?? value['teamName'];
      final resolvedName = _resolveName(rawName, nested);
      final resolvedId =
          _asInt(value['id']) ??
          _asInt(value['teamId']) ??
          _asInt(value['team_id']) ??
          _asInt(value['teamID']) ??
          _asInt(nested is Map<String, dynamic> ? nested['id'] : null);
      final score = _asNum(
        value['score'] ??
            value['points'] ??
            (value['teamStatus'] is Map<String, dynamic>
                ? (value['teamStatus'] as Map<String, dynamic>)['score']
                : null),
      );

      if (resolvedName == null && resolvedId == null && score == null) {
        return null;
      }

      return TournamentLeaderTeam(
        id: resolvedId,
        name: resolvedName,
        score: score,
      );
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    if (name != null) 'name': name,
    if (score != null) 'score': score,
  };

  static String? _resolveName(dynamic direct, dynamic nested) {
    if (direct is String && direct.trim().isNotEmpty) {
      return direct.trim();
    }
    if (nested is Map<String, dynamic>) {
      final nestedName = nested['name'];
      if (nestedName is String && nestedName.trim().isNotEmpty) {
        return nestedName.trim();
      }
    }
    return null;
  }
}

int? _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    final parsed = int.tryParse(value);
    return parsed;
  }
  return null;
}

num? _asNum(dynamic value) {
  if (value is num) return value;
  if (value is String) {
    final parsed = num.tryParse(value);
    return parsed;
  }
  return null;
}
