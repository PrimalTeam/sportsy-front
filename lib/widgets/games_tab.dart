import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:sportsy_front/custom_colors.dart';
import 'package:sportsy_front/dto/game_get_dto.dart';
import 'package:sportsy_front/dto/get_teams_dto.dart';
import 'package:sportsy_front/features/games/data/games_remote_service.dart';
import 'package:sportsy_front/features/games/data/game_websocket_service.dart';
import 'package:sportsy_front/features/games/data/game_websocket_events.dart';
import 'package:sportsy_front/features/tournaments/data/ladder_remote_service.dart';
import 'package:sportsy_front/screens/game_edit_screen.dart';

class TeamDisplayInfo {
  final String name;
  final String score;
  final Uint8List? icon;
  TeamDisplayInfo(this.name, this.score, this.icon);
}

class GamesTab extends StatefulWidget {
  final int roomId;
  final int? tournamentId;
  final bool bracketExists;
  const GamesTab({
    super.key,
    required this.roomId,
    required this.tournamentId,
    this.bracketExists = false,
  });

  @override
  GamesTabState createState() => GamesTabState();
}

class GamesTabState extends State<GamesTab> {
  List<GameGetDto> _games = [];
  bool _loading = true;
  bool _error = false;

  // WebSocket
  final GameWebSocketService _webSocket = GameWebSocketService();
  final List<StreamSubscription> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    _loadGames();
    _initWebSocket();
  }

  @override
  void dispose() {
    _disposeWebSocket();
    super.dispose();
  }

  Future<void> _initWebSocket() async {
    if (widget.tournamentId == null) return;

    _subscriptions.add(
      _webSocket.onGameCreated.listen(_handleGameCreated),
    );
    _subscriptions.add(
      _webSocket.onGameUpdated.listen(_handleGameUpdated),
    );
    _subscriptions.add(
      _webSocket.onGameDeleted.listen(_handleGameDeleted),
    );
    _subscriptions.add(
      _webSocket.onConnectionStateChanged.listen((connected) {
        if (mounted) {
          setState(() {});
        }
      }),
    );

    try {
      await _webSocket.connect();
      final response = await _webSocket.joinTournament(
        roomId: widget.roomId,
        tournamentId: widget.tournamentId!,
      );
      debugPrint('WebSocket joined tournament: ${response.status}');
    } catch (e) {
      debugPrint('WebSocket connection error: $e');
    }
  }

  void _disposeWebSocket() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
    // Leave tournament but don't disconnect singleton
    if (_webSocket.isSubscribedToTournament) {
      _webSocket.leaveTournament();
    }
  }

  void _handleGameCreated(GameCreatedEvent event) {
    if (!mounted) return;
    // Reload to get full game details
    _loadGames();
  }

  void _handleGameUpdated(GameUpdatedEvent event) {
    if (!mounted) return;
    final gameId = event.gameId;
    if (gameId == null) {
      _loadGames();
      return;
    }

    // Update the specific game in the list
    _updateGameById(gameId);
  }

  void _handleGameDeleted(GameDeletedEvent event) {
    if (!mounted) return;
    setState(() {
      _games.removeWhere((g) => g.id == event.gameId);
    });
  }

  Future<void> _updateGameById(int gameId) async {
    try {
      final updatedGame = await GamesRemoteService.getGameById(
        roomId: widget.roomId,
        gameId: gameId,
      );
      if (!mounted) return;
      setState(() {
        final index = _games.indexWhere((g) => g.id == gameId);
        if (index != -1) {
          _games[index] = updatedGame;
        } else {
          _games.add(updatedGame);
        }
      });
    } catch (e) {
      debugPrint('Failed to update game $gameId: $e');
    }
  }

  Future<void> reloadGames() => _loadGames();

  Future<void> _openGameEditScreen(GameGetDto game) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => GameEditScreen(roomId: widget.roomId, gameId: game.id),
      ),
    );

    // Reload games after returning from edit screen
    if (mounted) {
      await _loadGames();
    }
  }

  Future<void> _deleteGame(int gameId) async {
    try {
      await GamesRemoteService.deleteGame(widget.roomId, gameId);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete game: $e')),
      );
    }
  }

  Future<void> _autoGenerateBracket() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Auto-generate Bracket'),
        content: const Text('This will delete all existing games and automatically generate the tournament bracket. Continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Generate')),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      // First delete all existing games
      final gamesToDelete = List<GameGetDto>.from(_games);
      for (final game in gamesToDelete) {
        try {
          await GamesRemoteService.deleteGame(widget.roomId, game.id);
        } catch (e) {
          debugPrint('Failed to delete game ${game.id}: $e');
        }
      }

      // Then generate the bracket
      await LadderRemoteService.generateLadder(roomId: widget.roomId);
      
      // Reload games list
      await _loadGames();
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bracket generated successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate bracket: $e')),
      );
    }
  }

  Future<void> _deleteAllGames() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Games'),
        content: const Text('Are you sure you want to delete ALL games? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete All', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    final gamesToDelete = List<GameGetDto>.from(_games);
    for (final game in gamesToDelete) {
      try {
        await GamesRemoteService.deleteGame(widget.roomId, game.id);
      } catch (e) {
        debugPrint('Failed to delete game ${game.id}: $e');
      }
    }
    _loadGames();
  }

  Future<void> _loadGames() async {
    if (widget.tournamentId == null) {
      setState(() {
        _games = [];
        _loading = false;
        _error = false;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = false;
    });

    try {
      final basicGames = await GamesRemoteService.getGamesByTournament(
        widget.roomId,
      );

      // Fetch detailed game data with teams for each game
      final detailedGames = await Future.wait(
        basicGames.map(
          (game) => GamesRemoteService.getGameById(
            roomId: widget.roomId,
            gameId: game.id,
          ),
        ),
      );

      if (!mounted) return;
      setState(() {
        _games = detailedGames;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = true;
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    final local = date.toLocal();
    final parts = local.toString().split('.');
    return parts.isNotEmpty ? parts.first : local.toIso8601String();
  }

  String _titleFor(GameGetDto game) {
    final entries = _teamScoreEntries(game);
    if (entries.length >= 2) {
      return '${entries[0].name} vs ${entries[1].name}';
    }
    if (entries.length == 1) {
      return entries.first.name;
    }
    if (game.teamIds.isNotEmpty) {
      return 'Game';
    }
    return 'Game';
  }

  List<TeamDisplayInfo> _teamScoreEntries(GameGetDto game) {
    final entries = <TeamDisplayInfo>[];

    // Build a map of teamId -> score from teamStatuses
    final scoreByTeamId = <int, int>{};
    for (final status in game.teamStatuses) {
      if (status.teamId != null) {
        scoreByTeamId[status.teamId!] = status.score;
      }
    }

    // Priority 1: Use teams list as primary source (has actual team data)
    if (game.teams.isNotEmpty) {
      for (final team in game.teams) {
        final score = scoreByTeamId[team.id];
        entries.add(TeamDisplayInfo(team.name, score?.toString() ?? '-', team.icon?.data));
      }
      return entries;
    }

    // Priority 2: Use teamStatuses if teams is empty
    if (game.teamStatuses.isNotEmpty) {
      for (final status in game.teamStatuses) {
        final name =
            status.teamName ??
            (status.teamId != null ? 'Team ${status.teamId}' : 'Unknown');
        entries.add(TeamDisplayInfo(name, status.score.toString(), null));
      }
      return entries;
    }

    // Priority 3: Fallback to teamIds
    if (game.teamIds.isNotEmpty) {
      for (final id in game.teamIds) {
        entries.add(TeamDisplayInfo('Team $id', '-', null));
      }
    }

    return entries;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error) {
      return const Center(
        child: Text(
          'Failed to load games',
          style: TextStyle(color: Colors.white),
        ),
      );
    }
    if (widget.tournamentId == null) {
      return const Center(
        child: Text('No tournament', style: TextStyle(color: Colors.white)),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadGames,
      color: Colors.white,
      backgroundColor: Colors.black,
      child:
          _games.isEmpty
              ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      'No games created yet',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              )
              : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                children: [
                  if (_games.isNotEmpty && !widget.bracketExists)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ElevatedButton.icon(
                        onPressed: _autoGenerateBracket,
                        icon: const Icon(Icons.auto_fix_high),
                        label: const Text('Auto-generate Bracket'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  if (_games.isNotEmpty && !widget.bracketExists)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ElevatedButton.icon(
                        onPressed: _deleteAllGames,
                        icon: const Icon(Icons.delete_forever),
                        label: const Text('Delete All Games'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ..._games.map((game) {
                    final title = _titleFor(game);
                    final subtitleStyle = const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    );
                    final teamEntries = _teamScoreEntries(game);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        onTap: () => _openGameEditScreen(game),
                        title: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Status: ${game.status}', style: subtitleStyle),
                            Text(
                              'Start: ${_formatDate(game.dateStart)}',
                              style: subtitleStyle,
                            ),
                            if (game.durationLabel != '-')
                              Text(
                                'Duration: ${game.durationLabel}',
                                style: subtitleStyle,
                              ),
                            if (teamEntries.isNotEmpty) const SizedBox(height: 6),
                            ...teamEntries.map(
                              (entry) => Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(
                                  children: [
                                    if (entry.icon != null)
                                      Padding(
                                        padding: const EdgeInsets.only(right: 8.0),
                                        child: ClipOval(
                                          child: Image.memory(
                                            entry.icon!,
                                            width: 24,
                                            height: 24,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    Expanded(
                                      child: Text(
                                        entry.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      entry.score,
                                      style: const TextStyle(
                                        color: AppColors.accent,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.white70),
                              tooltip: 'Edit match',
                              onPressed: () => _openGameEditScreen(game),
                            ),
                            if (!widget.bracketExists)
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent),
                                tooltip: 'Delete match',
                                onPressed: () => _deleteGame(game.id),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
    );
  }
}
