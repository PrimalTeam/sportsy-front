import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sportsy_front/custom_colors.dart';
import 'package:sportsy_front/dto/game_get_dto.dart';
import 'package:sportsy_front/dto/get_tournament_dto.dart';
import 'package:sportsy_front/features/games/data/games_remote_service.dart';
import 'package:sportsy_front/features/games/data/game_websocket_service.dart';
import 'package:sportsy_front/features/team_status/data/team_status_remote_service.dart';
import 'package:sportsy_front/features/tournaments/data/ladder_remote_service.dart';
import 'package:sportsy_front/features/tournaments/data/tournaments_remote_service.dart';
import 'package:sportsy_front/screens/games_page.dart';
import 'package:sportsy_front/screens/game_edit_screen.dart';

class TournamentBracketPage extends StatefulWidget {
  const TournamentBracketPage({
    super.key,
    required this.roomId,
    this.tournamentId,
    this.userRole = 'gameObserver',
  });

  final int roomId;
  final int? tournamentId;
  final String userRole;

  @override
  TournamentBracketPageState createState() => TournamentBracketPageState();
}

class TournamentBracketPageState extends State<TournamentBracketPage> {
  static const String _actionGenerate = '_generate';
  static const String _actionGenerateWithGames = '_generateWithGames';
  static const String _actionDelete = '_delete';

  GetTournamentDto? _tournament;
  bool _isLoading = true;
  String? _error;
  bool _isUpdating = false;

  // Game updates notifier - maps gameId to its latest data
  final Map<int, ValueNotifier<GameGetDto?>> _gameNotifiers = {};

  // WebSocket
  final GameWebSocketService _webSocket = GameWebSocketService();
  final List<StreamSubscription> _subscriptions = [];

  String get _role => widget.userRole.toLowerCase();
  bool get _isAdmin => _role == 'admin';
  bool get _isSpectator => _role == 'spectrator';
  bool get _canManageBracket => _isAdmin || _isSpectator;
  bool get _canEditMatches => _canManageBracket;

  @override
  void initState() {
    super.initState();
    _loadBracket();
    _initWebSocket();
  }

  @override
  void dispose() {
    _disposeWebSocket();
    _disposeGameNotifiers();
    super.dispose();
  }

  void _disposeGameNotifiers() {
    for (final notifier in _gameNotifiers.values) {
      notifier.dispose();
    }
    _gameNotifiers.clear();
  }

  ValueNotifier<GameGetDto?> _getGameNotifier(int gameId) {
    return _gameNotifiers.putIfAbsent(gameId, () => ValueNotifier<GameGetDto?>(null));
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
      debugPrint('Bracket WebSocket joined tournament: ${response.status}');
    } catch (e) {
      debugPrint('Bracket WebSocket error: $e');
    }
  }

  void _handleGameCreated(event) {
    if (!mounted) return;
    // Reload bracket to get new game in structure (structure changed)
    _loadBracketSilently();
  }

  void _handleGameUpdated(event) {
    if (!mounted) return;
    final gameId = event.gameId as int?;
    if (gameId != null) {
      // Update only the specific game card
      _updateGameNotifier(gameId);
    } else {
      _loadBracketSilently();
    }
  }

  void _handleGameDeleted(event) {
    if (!mounted) return;
    // Reload bracket as structure might have changed
    _loadBracketSilently();
  }

  Future<void> _updateGameNotifier(int gameId) async {
    try {
      final updatedGame = await GamesRemoteService.getGameById(
        roomId: widget.roomId,
        gameId: gameId,
      );
      if (!mounted) return;
      
      final notifier = _getGameNotifier(gameId);
      notifier.value = updatedGame;
    } catch (e) {
      debugPrint('Failed to update game $gameId: $e');
    }
  }

  /// Loads bracket without showing loading indicator (for WebSocket updates)
  Future<void> _loadBracketSilently() async {
    final tournamentId = widget.tournamentId;
    if (tournamentId == null) return;

    try {
      final tournament = await TournamentsRemoteService.getTournament(
        roomId: widget.roomId,
        tournamentId: tournamentId,
        includes: const ['teams', 'games.teamStatuses', 'games.teams'],
      );
      if (mounted) {
        setState(() {
          _tournament = tournament;
        });
      }
    } catch (e) {
      debugPrint('Silent bracket refresh failed: $e');
    }
  }

  void _disposeWebSocket() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
    if (_webSocket.isSubscribedToTournament) {
      _webSocket.leaveTournament();
    }
  }

  @override
  void didUpdateWidget(covariant TournamentBracketPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.roomId != widget.roomId ||
        oldWidget.tournamentId != widget.tournamentId) {
      _disposeWebSocket();
      _initWebSocket();
      _loadBracket();
    }
  }

  Future<void> _loadBracket() async {
    final tournamentId = widget.tournamentId;
    if (tournamentId == null) {
      setState(() {
        _tournament = null;
        _isLoading = false;
        _error = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final tournament = await TournamentsRemoteService.getTournament(
        roomId: widget.roomId,
        tournamentId: tournamentId,
        includes: const ['teams', 'games.teamStatuses', 'games.teams'],
      );
      if (mounted) {
        setState(() {
          _tournament = tournament;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  /// Public method to refresh bracket - can be called via GlobalKey
  Future<void> refreshBracket() async {
    await _loadBracket();
  }

  Future<void> _refreshBracket() async {
    await _loadBracket();
  }

  Future<void> _handleMenuSelection(String action) async {
    if (!_canManageBracket) return;
    switch (action) {
      case _actionGenerate:
        await _generateBracket(resetExistingGames: false);
        break;
      case _actionGenerateWithGames:
        final confirmed = await _confirmGenerateWithGames();
        if (confirmed == true) {
          await _generateBracket(resetExistingGames: true);
        }
        break;
      case _actionDelete:
        final confirmedDelete = await _confirmDelete();
        if (confirmedDelete == true) {
          await _deleteBracket();
        }
        break;
      default:
        break;
    }
  }

  Future<bool?> _confirmGenerateWithGames() {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          title: const Text('Generate bracket?', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Existing games will be removed and the bracket will be generated from scratch. '
            'This action cannot be undone.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Generate'),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _confirmDelete() {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          title: const Text('Delete bracket?', style: TextStyle(color: Colors.white)),
          content: const Text(
            'This will remove the ladder structure and associated games. This action cannot be undone.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openGamesManager(GetTournamentDto tournament) async {
    if (widget.tournamentId == null || !_canManageBracket) return;

    final allowedIds = _extractTeamIds(tournament.teams);
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => GamesPage(
          roomId: widget.roomId,
          tournamentId: widget.tournamentId,
          allowedTeamIds: allowedIds.isEmpty ? null : allowedIds,
        ),
      ),
    );

    if (result == true) {
      try {
        await LadderRemoteService.updateLadder(roomId: widget.roomId);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to sync bracket: $e')),
          );
        }
      }
      await _refreshBracket();
    }
  }

  List<int> _extractTeamIds(List<dynamic> teams) {
    final ids = <int>[];
    for (final entry in teams) {
      if (entry is Map<String, dynamic>) {
        final id = _intFrom(entry['id']);
        if (id != null) ids.add(id);
      } else if (entry is int) {
        ids.add(entry);
      }
    }
    return ids;
  }

  int? _intFrom(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _BracketMessage(
        message: 'Failed to load bracket.',
        onRetry: widget.tournamentId == null ? null : _refreshBracket,
      );
    }

    final tournament = _tournament;
    if (tournament == null) {
      return _BracketMessage(
        message:
            widget.tournamentId == null
                ? 'Tournament is not ready yet.'
                : 'Bracket not available.',
        onRetry: widget.tournamentId == null ? null : _refreshBracket,
      );
    }

    final tree = tournament.leader;
    final hasStructure = _hasLadderStructure(tree);
    if (!hasStructure) {
      final teamsCount = tournament.teams.length;
      final canGenerate = teamsCount >= 2;
      return _BracketSetupMessage(
        primaryMessage: 'Bracket has not been defined yet.',
        secondaryMessage:
            canGenerate
                ? 'Generate the bracket from existing games or create new games from teams.'
                : 'Add games or teams before generating the bracket.',
        canGenerate: canGenerate,
        isProcessing: _isUpdating,
        onGenerateFromGames:
          _canManageBracket
            ? () => _generateBracket(resetExistingGames: false)
            : null,
        onGenerateWithTeams:
          canGenerate && _canManageBracket
            ? () async {
                final confirmed = await _confirmGenerateWithGames();
                if (confirmed == true) {
                  await _generateBracket(resetExistingGames: true);
                }
              }
            : null,
        onRefresh: _refreshBracket,
      );
    }

    // Handle Round Robin differently
    if (tree!.isRoundRobin) {
      return _buildRoundRobinView(tournament, tree);
    }

    // Handle Double Elimination
    if (tree.isDoubleElimination) {
      return _buildDoubleEliminationView(tournament, tree);
    }

    final roundGroups = _buildRoundGroups(tree);
    if (roundGroups.isEmpty) {
      return _BracketMessage(
        message: 'No games have been scheduled yet.',
        onRetry: _refreshBracket,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isUpdating)
          const LinearProgressIndicator(
            minHeight: 2,
            backgroundColor: Colors.transparent,
          ),
        _buildBracketHeader(tournament),
        Expanded(
          child: _BracketLayout(
            rounds: roundGroups,
            onEditRequested: _canEditMatches ? _handleMatchEdit : null,
            getGameNotifier: _getGameNotifier,
          ),
        ),
      ],
    );
  }

  List<List<TournamentLeaderNode>> _collectRounds(TournamentLeaderNode root) {
    final depthBuckets = <List<TournamentLeaderNode>>[];

    void walk(TournamentLeaderNode node, int depth) {
      if (depthBuckets.length <= depth) {
        depthBuckets.add(<TournamentLeaderNode>[]);
      }
      depthBuckets[depth].add(node);
      for (final child in node.children) {
        walk(child, depth + 1);
      }
    }

    walk(root, 0);
    return depthBuckets.reversed
        .map((level) => List<TournamentLeaderNode>.from(level))
        .toList();
  }

  List<_BracketRoundGroup> _buildRoundGroups(TournamentLeaderTree? tree) {
    final groups = <_BracketRoundGroup>[];
    final preGames = tree?.preGames ?? const <TournamentLeaderNode>[];
    if (preGames.isNotEmpty) {
      groups.add(_BracketRoundGroup(title: 'Preliminary', nodes: preGames));
    }

    final root = tree?.root;
    if (root == null) {
      return groups;
    }

    final ladderRounds = _collectRounds(root);
    if (ladderRounds.isEmpty) {
      return groups;
    }

    final total = ladderRounds.length;
    for (var index = 0; index < ladderRounds.length; index++) {
      final title = _resolveRoundTitle(index, total, ladderRounds[index]);
      groups.add(_BracketRoundGroup(title: title, nodes: ladderRounds[index]));
    }

    return groups;
  }

  String _resolveRoundTitle(
    int index,
    int total,
    List<TournamentLeaderNode> nodes,
  ) {
    final remaining = total - index;
    if (remaining <= 0) {
      return 'Round ${index + 1}';
    }

    if (_sameRoundNumber(nodes)) {
      final round = nodes.first.roundNumber;
      if (round != null) {
        final ordinal = round + 1;
        if (ordinal <= 0) {
          return 'Round ${index + 1}';
        }
      }
    }

    switch (remaining) {
      case 1:
        return 'Final';
      case 2:
        return 'Semi-final';
      case 3:
        return 'Quarter-final';
      default:
        return 'Round ${index + 1}';
    }
  }

  bool _sameRoundNumber(List<TournamentLeaderNode> nodes) {
    if (nodes.isEmpty) return false;
    final firstRound = nodes.first.roundNumber;
    for (final node in nodes.skip(1)) {
      if (node.roundNumber != firstRound) {
        return false;
      }
    }
    return true;
  }

  bool _hasLadderStructure(TournamentLeaderTree? tree) {
    if (tree == null) return false;
    // Single elimination
    if (tree.root != null || tree.preGames.isNotEmpty) return true;
    // Double elimination
    if (tree.winnersBracket != null || tree.losersBracket != null) return true;
    // Round robin
    if (tree.games.isNotEmpty) return true;
    return false;
  }

  Widget _buildRoundRobinView(GetTournamentDto tournament, TournamentLeaderTree tree) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isUpdating)
          const LinearProgressIndicator(
            minHeight: 2,
            backgroundColor: Colors.transparent,
          ),
        _buildBracketHeader(tournament),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Standings table
                _buildStandingsTable(tree.standings),
                const SizedBox(height: 24),
                // Games list
                _buildRoundRobinGames(tree.games),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStandingsTable(List<RoundRobinStanding> standings) {
    if (standings.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Standings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          // Header row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white.withOpacity(0.05),
            child: const Row(
              children: [
                SizedBox(width: 32, child: Text('#', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold))),
                Expanded(child: Text('Team', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold))),
                SizedBox(width: 40, child: Text('W', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold))),
                SizedBox(width: 40, child: Text('D', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold))),
                SizedBox(width: 40, child: Text('L', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold))),
                SizedBox(width: 50, child: Text('Pts', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          // Data rows
          ...standings.asMap().entries.map((entry) {
            final index = entry.key;
            final standing = entry.value;
            final isTop = index < 2;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isTop ? AppColors.accent.withOpacity(0.1) : null,
                border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 32,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: isTop ? AppColors.accent : Colors.white70,
                        fontWeight: isTop ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      standing.teamName,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 40, child: Text('${standing.wins}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white))),
                  SizedBox(width: 40, child: Text('${standing.draws}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white))),
                  SizedBox(width: 40, child: Text('${standing.losses}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white))),
                  SizedBox(
                    width: 50,
                    child: Text(
                      '${standing.points}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isTop ? AppColors.accent : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRoundRobinGames(List<TournamentLeaderNode> games) {
    if (games.isEmpty) {
      return const SizedBox.shrink();
    }

    // Group games by round
    final gamesByRound = <int, List<TournamentLeaderNode>>{};
    for (final game in games) {
      final round = game.roundNumber ?? 1;
      gamesByRound.putIfAbsent(round, () => []).add(game);
    }

    final sortedRounds = gamesByRound.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Matches',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...sortedRounds.map((round) {
          final roundGames = gamesByRound[round]!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: Text(
                  'Round $round',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ...roundGames.map((node) => _buildRoundRobinGameCard(node)),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildRoundRobinGameCard(TournamentLeaderNode node) {
    final teams = node.teamEntries;
    final team1 = teams.isNotEmpty ? teams[0] : null;
    final team2 = teams.length > 1 ? teams[1] : null;
    final isCompleted = node.status?.toLowerCase() == 'completed';

    return GestureDetector(
      onTap: _canEditMatches && node.gameId != null
          ? () => _handleMatchEdit(node)
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isCompleted ? AppColors.accent.withOpacity(0.5) : Colors.white12,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                team1?.name ?? 'TBD',
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.right,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.accent.withOpacity(0.2) : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                node.hasScores
                    ? '${team1?.score?.toInt() ?? 0} - ${team2?.score?.toInt() ?? 0}'
                    : 'vs',
                style: TextStyle(
                  color: isCompleted ? AppColors.accent : Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Text(
                team2?.name ?? 'TBD',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            if (_canEditMatches && node.gameId != null)
              const Icon(Icons.chevron_right, color: Colors.white38, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDoubleEliminationView(GetTournamentDto tournament, TournamentLeaderTree tree) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isUpdating)
          const LinearProgressIndicator(
            minHeight: 2,
            backgroundColor: Colors.transparent,
          ),
        _buildBracketHeader(tournament),
        Expanded(
          child: DefaultTabController(
            length: 3,
            child: Column(
              children: [
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const TabBar(
                    indicatorColor: AppColors.accent,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white54,
                    tabs: [
                      Tab(text: 'Winners'),
                      Tab(text: 'Losers'),
                      Tab(text: 'Grand Final'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildBracketTab(tree.winnersBracket, 'Winners Bracket'),
                      _buildBracketTab(tree.losersBracket, 'Losers Bracket'),
                      _buildGrandFinalTab(tree.grandFinal),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBracketHeader(GetTournamentDto tournament) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Format: ${_formatLeaderType(tournament.leaderType)}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (widget.tournamentId != null && _canManageBracket)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: TextButton.icon(
                onPressed: () => _openGamesManager(tournament),
                icon: const Icon(Icons.sports_esports, size: 18),
                label: const Text('Manage games'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.accent,
                ),
              ),
            ),
          if (widget.tournamentId != null && _canManageBracket)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white70),
              tooltip: 'Bracket actions',
              onSelected: _handleMenuSelection,
              itemBuilder: (context) => [
                const PopupMenuItem<String>(
                  value: _actionGenerate,
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.account_tree_outlined, size: 20),
                    title: Text('Generate from games'),
                    subtitle: Text('Use existing games', style: TextStyle(fontSize: 11)),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: _actionGenerateWithGames,
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.auto_fix_high, size: 20),
                    title: Text('Generate with teams'),
                    subtitle: Text('Create new games from teams', style: TextStyle(fontSize: 11)),
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  value: _actionDelete,
                  child: Text('Delete bracket'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  String _formatLeaderType(String type) {
    return type
        .split('-')
        .map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '')
        .join(' ');
  }

  Widget _buildBracketTab(TournamentLeaderNode? bracket, String title) {
    if (bracket == null) {
      return Center(
        child: Text(
          '$title not available',
          style: const TextStyle(color: Colors.white54),
        ),
      );
    }

    final rounds = _collectRounds(bracket);
    final groups = <_BracketRoundGroup>[];
    final total = rounds.length;
    for (var index = 0; index < rounds.length; index++) {
      final titleText = _resolveRoundTitle(index, total, rounds[index]);
      groups.add(_BracketRoundGroup(title: titleText, nodes: rounds[index]));
    }

    if (groups.isEmpty) {
      return Center(
        child: Text(
          '$title has no matches yet',
          style: const TextStyle(color: Colors.white54),
        ),
      );
    }

    return _BracketLayout(
      rounds: groups,
      onEditRequested: _canEditMatches ? _handleMatchEdit : null,
      getGameNotifier: _getGameNotifier,
    );
  }

  Widget _buildGrandFinalTab(TournamentLeaderNode? grandFinal) {
    if (grandFinal == null || grandFinal.gameId == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events, color: Colors.amber, size: 64),
            SizedBox(height: 16),
            Text(
              'Grand Final',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Waiting for bracket winners...',
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ),
      );
    }

    final teams = grandFinal.teamEntries;
    final team1 = teams.isNotEmpty ? teams[0] : null;
    final team2 = teams.length > 1 ? teams[1] : null;
    final isCompleted = grandFinal.status?.toLowerCase() == 'completed';

    return Center(
      child: GestureDetector(
        onTap: _canEditMatches ? () => _handleMatchEdit(grandFinal) : null,
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.amber.withOpacity(0.2),
                Colors.orange.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.amber.withOpacity(0.5), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events, color: Colors.amber, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Grand Final',
                style: TextStyle(color: Colors.amber, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    children: [
                      Text(
                        team1?.name ?? 'Winners Bracket',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      if (isCompleted && team1?.score != null)
                        Text(
                          '${team1!.score!.toInt()}',
                          style: const TextStyle(color: Colors.amber, fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'vs',
                      style: TextStyle(color: Colors.white54, fontSize: 16),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        team2?.name ?? 'Losers Bracket',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      if (isCompleted && team2?.score != null)
                        Text(
                          '${team2!.score!.toInt()}',
                          style: const TextStyle(color: Colors.amber, fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                ],
              ),
              if (isCompleted)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'COMPLETED',
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleMatchEdit(TournamentLeaderNode node) async {
    if (!_canEditMatches) return;
    if (node.gameId == null) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => GameEditScreen(roomId: widget.roomId, gameId: node.gameId!),
      ),
    );

    if (true) {
      setState(() {
        _isUpdating = true;
      });
      try {
        await LadderRemoteService.updateLadder(roomId: widget.roomId);
        await _refreshBracket();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Match updated')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to refresh ladder: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isUpdating = false;
          });
        }
      }
    }
  }

  Future<void> _generateBracket({bool resetExistingGames = false}) async {
    if (_isUpdating || widget.tournamentId == null || !_canManageBracket) {
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      await LadderRemoteService.generateLadder(
        roomId: widget.roomId,
        resetExistingGames: resetExistingGames,
      );
      await _refreshBracket();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bracket generated')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate bracket: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  Future<void> _deleteBracket() async {
    if (_isUpdating || widget.tournamentId == null || !_canManageBracket) {
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      await LadderRemoteService.deleteLadder(roomId: widget.roomId);
      await _refreshBracket();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bracket deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete bracket: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }
}

class _BracketLayout extends StatelessWidget {
  const _BracketLayout({
    required this.rounds,
    this.onEditRequested,
    required this.getGameNotifier,
  });

  final List<_BracketRoundGroup> rounds;
  final ValueChanged<TournamentLeaderNode>? onEditRequested;
  final ValueNotifier<GameGetDto?> Function(int gameId) getGameNotifier;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final orientation = MediaQuery.of(context).orientation;
        final isCompact =
            orientation == Orientation.portrait && constraints.maxWidth < 600;

        if (isCompact) {
          return Scrollbar(
            thumbVisibility: true,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: rounds.length,
              itemBuilder: (context, index) {
                final group = rounds[index];
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == rounds.length - 1 ? 0 : 16,
                  ),
                  child: Card(
                    color: Colors.black.withOpacity(0.7),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: BorderSide(
                        color: AppColors.accent.withOpacity(0.25),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group.title,
                            style:
                                textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ) ??
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                          ),
                          const SizedBox(height: 12),
                          ...group.nodes.map(
                            (node) => _BracketMatchCard(
                              node: node,
                              onEditRequested: onEditRequested,
                              isCompact: true,
                              gameNotifier: node.gameId != null ? getGameNotifier(node.gameId!) : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }

        final double baseColumnWidth = 240;
        final double horizontalGap = 24;
        final double totalWidth =
            rounds.isEmpty
                ? 0
                : rounds.length * baseColumnWidth +
                    (rounds.length - 1) * horizontalGap;
        final width = math.max(constraints.maxWidth, totalWidth + 32);
        final height = constraints.maxHeight;

        return InteractiveViewer(
          panEnabled: true,
          minScale: 0.6,
          maxScale: 1.8,
          constrained: false,
          boundaryMargin: const EdgeInsets.all(200),
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: width, minHeight: height),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(rounds.length, (index) {
                    final group = rounds[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        right: index == rounds.length - 1 ? 0 : horizontalGap,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group.title,
                            style:
                                textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ) ??
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                          ),
                          const SizedBox(height: 12),
                          for (final node in group.nodes)
                            _BracketMatchCard(
                              node: node,
                              onEditRequested: onEditRequested,
                              gameNotifier: node.gameId != null ? getGameNotifier(node.gameId!) : null,
                            ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BracketMatchCard extends StatelessWidget {
  const _BracketMatchCard({
    required this.node,
    this.onEditRequested,
    this.isCompact = false,
    this.gameNotifier,
  });

  final TournamentLeaderNode node;
  final ValueChanged<TournamentLeaderNode>? onEditRequested;
  final bool isCompact;
  final ValueNotifier<GameGetDto?>? gameNotifier;

  @override
  Widget build(BuildContext context) {
    if (gameNotifier != null) {
      return ValueListenableBuilder<GameGetDto?>(
        valueListenable: gameNotifier!,
        builder: (context, updatedGame, child) {
          return _buildCard(context, updatedGame);
        },
      );
    }
    return _buildCard(context, null);
  }

  Widget _buildCard(BuildContext context, GameGetDto? updatedGame) {
    // Use updated game data if available, otherwise fall back to node data
    final String? status = updatedGame?.status ?? node.status;
    final teams = _resolveTeams(updatedGame);
    final canEdit = node.gameId != null && onEditRequested != null;
    
    return GestureDetector(
      onTap: canEdit ? () => onEditRequested?.call(node) : null,
      child: Container(
        key: node.gameId != null ? ValueKey('game_${node.gameId}') : null,
        width: isCompact ? double.infinity : 240,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(isCompact ? 0.6 : 0.82),
          borderRadius: BorderRadius.circular(isCompact ? 12 : 14),
          border: Border.all(color: AppColors.accent.withOpacity(0.35)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    node.description ?? node.name ?? 'Match',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (canEdit)
                  Icon(
                    Icons.edit,
                    color: AppColors.accent.withOpacity(0.7),
                    size: 16,
                  ),
              ],
            ),
            if (status != null) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ),
            ],
            const SizedBox(height: 10),
            for (final team in teams)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        team.name ?? '—',
                        style: const TextStyle(color: Colors.white70),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (team.score != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.22),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          team.score!.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            if (node.gameId != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Game #${node.gameId}',
                  style: const TextStyle(color: Colors.white24, fontSize: 11),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<TournamentLeaderTeam> _resolveTeams(GameGetDto? updatedGame) {
    if (updatedGame != null && updatedGame.teamStatuses.isNotEmpty) {
      // Use updated scores from WebSocket
      return updatedGame.teamStatuses.map((status) {
        return TournamentLeaderTeam(
          id: status.teamId,
          name: status.teamName ?? _findTeamName(updatedGame, status.teamId),
          score: status.score,
        );
      }).toList();
    }
    
    // Fall back to original node data
    if (node.teamEntries.isEmpty) {
      return const [TournamentLeaderTeam(name: 'Awaiting assignment')];
    }
    return node.teamEntries;
  }

  String? _findTeamName(GameGetDto game, int? teamId) {
    if (teamId == null) return null;
    for (final team in game.teams) {
      if (team.id == teamId) return team.name;
    }
    return null;
  }
}

class _BracketRoundGroup {
  const _BracketRoundGroup({required this.title, required this.nodes});

  final String title;
  final List<TournamentLeaderNode> nodes;
}

class _BracketSetupMessage extends StatelessWidget {
  const _BracketSetupMessage({
    required this.primaryMessage,
    required this.secondaryMessage,
    required this.canGenerate,
    required this.isProcessing,
    this.onGenerateFromGames,
    this.onGenerateWithTeams,
    this.onRefresh,
  });

  final String primaryMessage;
  final String secondaryMessage;
  final bool canGenerate;
  final bool isProcessing;
  final Future<void> Function()? onGenerateFromGames;
  final Future<void> Function()? onGenerateWithTeams;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                primaryMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                secondaryMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
            if (isProcessing) ...[
              const SizedBox(height: 20),
              const CircularProgressIndicator(),
            ] else ...[
              if (onGenerateFromGames != null) ...[
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => onGenerateFromGames?.call(),
                  icon: const Icon(Icons.account_tree_outlined),
                  label: const Text('Generate from games'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: AppColors.accent,
                  ),
                ),
              ],
              if (canGenerate && onGenerateWithTeams != null) ...[
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => onGenerateWithTeams?.call(),
                  icon: const Icon(Icons.auto_fix_high),
                  label: const Text('Generate with teams'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    side: BorderSide(color: AppColors.accent.withOpacity(0.6)),
                  ),
                ),
              ],
              if (onRefresh != null) ...[
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () => onRefresh?.call(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    side: BorderSide(color: AppColors.accent.withOpacity(0.6)),
                  ),
                  child: const Text('Refresh'),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _BracketMessage extends StatelessWidget {
  const _BracketMessage({required this.message, this.onRetry});

  final String message;
  final Future<void> Function()? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => onRetry?.call(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.accent,
                side: BorderSide(color: AppColors.accent.withOpacity(0.6)),
              ),
              child: const Text('Refresh'),
            ),
          ],
        ],
      ),
    );
  }
}

class _MatchEditorSheet extends StatefulWidget {
  const _MatchEditorSheet({required this.node, required this.roomId});

  final TournamentLeaderNode node;
  final int roomId;

  @override
  State<_MatchEditorSheet> createState() => _MatchEditorSheetState();
}

class _MatchEditorSheetState extends State<_MatchEditorSheet> {
  late List<_TeamScoreField> _teamFields;
  List<String> _statuses = const [];
  String? _selectedStatus;
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _teamFields =
        widget.node.teamEntries
            .map(
              (team) => _TeamScoreField(
                team: team,
                controller: TextEditingController(
                  text: team.score?.toString() ?? '',
                ),
              ),
            )
            .toList();
    _selectedStatus = widget.node.status;
    if (_teamFields.isEmpty && widget.node.gameId != null) {
      _ensureTeamsLoaded();
    }
    _loadStatuses();
  }

  Future<void> _ensureTeamsLoaded() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final games = await GamesRemoteService.getGamesByTournament(
        widget.roomId,
      );
      GameGetDto? target;
      for (final game in games) {
        if (game.id == widget.node.gameId) {
          target = game;
          break;
        }
      }

      if (!mounted) return;
      if (target == null) {
        setState(() {
          _teamFields = [];
          _error = 'Game not found for editing.';
        });
        return;
      }

      final fields = <_TeamScoreField>[];
      if (target.teamStatuses.isNotEmpty) {
        for (final status in target.teamStatuses) {
          final teamId = status.teamId;
          if (teamId == null) continue;
          final teamName = status.teamName ?? _findTeamName(target, teamId);
          fields.add(
            _TeamScoreField(
              team: TournamentLeaderTeam(
                id: teamId,
                name: teamName,
                score: status.score,
              ),
              controller: TextEditingController(
                text: status.score.toString(),
              ),
            ),
          );
        }
      }

      if (fields.isEmpty && target.teams.isNotEmpty) {
        for (final team in target.teams) {
          fields.add(
            _TeamScoreField(
              team: TournamentLeaderTeam(id: team.id, name: team.name),
              controller: TextEditingController(text: '0'),
            ),
          );
        }
      }

      setState(() {
        for (final field in _teamFields) {
          field.controller.dispose();
        }
        _teamFields = fields;
        if (_selectedStatus == null && target != null) {
          _selectedStatus = target.status;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String? _findTeamName(GameGetDto game, int teamId) {
    for (final team in game.teams) {
      if (team.id == teamId) {
        return team.name;
      }
    }
    return null;
  }

  Future<void> _loadStatuses() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final statuses = await GamesRemoteService.getGameStatuses();
      if (mounted) {
        setState(() {
          _statuses = statuses;
          if (_selectedStatus == null && statuses.isNotEmpty) {
            _selectedStatus = statuses.first;
          } else if (_selectedStatus != null &&
              !statuses.contains(_selectedStatus)) {
            _selectedStatus = statuses.isNotEmpty ? statuses.first : null;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    for (final field in _teamFields) {
      field.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Edit match',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    icon: const Icon(Icons.close, color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else ...[
                DropdownButtonFormField<String>(
                  value:
                      _statuses.contains(_selectedStatus)
                          ? _selectedStatus
                          : null,
                  dropdownColor: Colors.black87,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.accent),
                    ),
                  ),
                  items:
                      _statuses
                          .map(
                            (status) => DropdownMenuItem<String>(
                              value: status,
                              child: Text(status),
                            ),
                          )
                          .toList(),
                  onChanged:
                      _statuses.isEmpty
                          ? null
                          : (value) => setState(() {
                            _selectedStatus = value;
                          }),
                  hint: const Text(
                    'Select status',
                    style: TextStyle(color: Colors.white54),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 18),
                ..._teamFields.map((field) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: TextFormField(
                      controller: field.controller,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: field.team.name ?? 'Team',
                        labelStyle: const TextStyle(color: Colors.white70),
                        suffixText:
                            field.team.id != null ? 'ID ${field.team.id}' : '',
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.accent),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submit,
                    icon:
                        _isSubmitting
                            ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Icon(Icons.save),
                    label: const Text('Save'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    final status = _selectedStatus;
    if (status == null || status.isEmpty) {
      setState(() {
        _error = 'Select status before saving.';
      });
      return;
    }

    final scores = <_TeamScoreUpdate>[];
    for (final field in _teamFields) {
      final text = field.controller.text.trim();
      final parsed = num.tryParse(text.isEmpty ? '0' : text);
      if (parsed == null) {
        setState(() {
          _error = 'Invalid score for ${field.team.name ?? 'team'}';
        });
        return;
      }
      if (field.team.id != null) {
        scores.add(_TeamScoreUpdate(teamId: field.team.id!, score: parsed));
      }
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      for (final score in scores) {
        await TeamStatusRemoteService.updateTeamScore(
          roomId: widget.roomId,
          gameId: widget.node.gameId!,
          teamId: score.teamId,
          score: score.score,
        );
      }

      await GamesRemoteService.updateGame(
        roomId: widget.roomId,
        gameId: widget.node.gameId!,
        status: status,
      );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}

class _TeamScoreField {
  _TeamScoreField({required this.team, required this.controller});

  final TournamentLeaderTeam team;
  final TextEditingController controller;
}

class _TeamScoreUpdate {
  const _TeamScoreUpdate({required this.teamId, required this.score});

  final int teamId;
  final num score;
}
