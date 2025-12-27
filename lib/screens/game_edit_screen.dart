import 'package:flutter/material.dart';
import 'package:sportsy_front/custom_colors.dart';
import 'package:sportsy_front/dto/game_get_dto.dart';
import 'package:sportsy_front/features/games/data/games_remote_service.dart';
import 'package:sportsy_front/features/team_status/data/team_status_remote_service.dart';
import 'package:sportsy_front/widgets/app_bar.dart';

class GameEditScreen extends StatefulWidget {
  final int roomId;
  final int gameId;

  const GameEditScreen({super.key, required this.roomId, required this.gameId});

  @override
  State<GameEditScreen> createState() => _GameEditScreenState();
}

class _GameEditScreenState extends State<GameEditScreen> {
  GameGetDto? _game;
  List<String> _statuses = [];
  bool _loading = true;
  bool _loadingStatuses = true;
  bool _error = false;
  bool _hasChanges = false;
  final Set<int> _pendingScoreUpdates = <int>{};
  String? _statusSubmitting;

  @override
  void initState() {
    super.initState();
    _loadGame();
    _loadStatuses();
  }

  Future<void> _loadGame() async {
    setState(() {
      _loading = true;
      _error = false;
    });

    try {
      final game = await GamesRemoteService.getGameById(
        roomId: widget.roomId,
        gameId: widget.gameId,
      );
      if (!mounted) return;
      setState(() {
        _game = game;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Failed to load game: $e');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = true;
      });
    }
  }

  Future<void> _loadStatuses() async {
    try {
      final statuses = await GamesRemoteService.getGameStatuses();
      if (!mounted) return;
      setState(() {
        _statuses = statuses;
        _loadingStatuses = false;
      });
    } catch (e) {
      debugPrint('Failed to load statuses: $e');
      if (!mounted) return;
      setState(() {
        _loadingStatuses = false;
      });
    }
  }

  Future<void> _incrementScore(GameTeamStatusSummary status) async {
    final game = _game;
    if (game == null) return;

    final teamId = status.teamId;
    if (teamId == null || _pendingScoreUpdates.contains(teamId)) {
      return;
    }

    final newScore = status.score + 1;
    setState(() {
      _pendingScoreUpdates.add(teamId);
    });

    try {
      await TeamStatusRemoteService.updateTeamScore(
        roomId: widget.roomId,
        gameId: game.id,
        teamId: teamId,
        score: newScore,
      );

      final updatedStatuses =
          game.teamStatuses.map((entry) {
            if (entry.teamId == teamId) {
              return entry.copyWith(score: newScore);
            }
            return entry;
          }).toList();

      if (!mounted) return;
      setState(() {
        _game = game.copyWith(teamStatuses: updatedStatuses);
        _pendingScoreUpdates.remove(teamId);
        _hasChanges = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _pendingScoreUpdates.remove(teamId);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update score: $e')));
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    final game = _game;
    if (game == null || _statusSubmitting == newStatus) return;

    setState(() {
      _statusSubmitting = newStatus;
    });

    try {
      await GamesRemoteService.updateGame(
        roomId: widget.roomId,
        gameId: game.id,
        status: newStatus,
      );

      if (!mounted) return;
      setState(() {
        _game = game.copyWith(status: newStatus);
        _statusSubmitting = null;
        _hasChanges = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statusSubmitting = null;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update status: $e')));
    }
  }

  String _getMatchTitle() {
    final game = _game;
    if (game == null) return 'Edit Match';

    final names = <String>[];
    for (final team in game.teams) {
      names.add(team.name);
    }
    if (names.isEmpty) {
      for (final status in game.teamStatuses) {
        if (status.teamName != null && status.teamName!.isNotEmpty) {
          names.add(status.teamName!);
        }
      }
    }

    if (names.length >= 2) {
      return '${names[0]} vs ${names[1]}';
    }
    if (names.length == 1) {
      return names.first;
    }
    return 'Edit Match';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && _hasChanges) {
          // Parent will reload when we return true
        }
      },
      child: Scaffold(
        appBar: MyAppBar(title: _getMatchTitle()),
        backgroundColor: AppColors.background,
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error || _game == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Failed to load game',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadGame, child: const Text('Retry')),
          ],
        ),
      );
    }

    final game = _game!;

    return RefreshIndicator(
      onRefresh: _loadGame,
      color: Colors.white,
      backgroundColor: Colors.black,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildScoreSection(game),
            const SizedBox(height: 24),
            _buildStatusSection(game),
            const SizedBox(height: 24),
            _buildInfoSection(game),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreSection(GameGetDto game) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Score',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 16),
          if (game.teamStatuses.isEmpty && game.teams.isEmpty)
            const Text(
              'No teams assigned to this match yet.',
              style: TextStyle(color: Colors.white54),
            )
          else
            ..._buildTeamScoreRows(game),
        ],
      ),
    );
  }

  List<Widget> _buildTeamScoreRows(GameGetDto game) {
    final rows = <Widget>[];

    // Build name lookup from teams
    final teamNameById = <int, String>{};
    for (final team in game.teams) {
      teamNameById[team.id] = team.name;
    }

    // Build score lookup from statuses
    final statusByTeamId = <int, GameTeamStatusSummary>{};
    for (final status in game.teamStatuses) {
      if (status.teamId != null) {
        statusByTeamId[status.teamId!] = status;
        if (status.teamName != null && status.teamName!.isNotEmpty) {
          teamNameById[status.teamId!] = status.teamName!;
        }
      }
    }

    // Use teams as primary source if available
    if (game.teams.isNotEmpty) {
      for (final team in game.teams) {
        final status = statusByTeamId[team.id];
        rows.add(
          _buildTeamRow(
            teamId: team.id,
            name: team.name,
            score: status?.score ?? 0,
            status: status,
          ),
        );
      }
    } else {
      // Fallback to teamStatuses
      for (final status in game.teamStatuses) {
        final name =
            status.teamName ??
            teamNameById[status.teamId] ??
            (status.teamId != null ? 'Team ${status.teamId}' : 'Unknown');
        rows.add(
          _buildTeamRow(
            teamId: status.teamId,
            name: name,
            score: status.score,
            status: status,
          ),
        );
      }
    }

    return rows;
  }

  Widget _buildTeamRow({
    required int? teamId,
    required String name,
    required int score,
    GameTeamStatusSummary? status,
  }) {
    final isLoading = teamId != null && _pendingScoreUpdates.contains(teamId);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.accent.withOpacity(0.2),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Score: $score',
                  style: const TextStyle(color: Colors.white60),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed:
                teamId != null && status != null && !isLoading
                    ? () => _incrementScore(status)
                    : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(14),
            ),
            child:
                isLoading
                    ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection(GameGetDto game) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Match Status',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 12),
          if (_loadingStatuses)
            const Center(child: CircularProgressIndicator())
          else if (_statuses.isEmpty)
            const Text(
              'No status options available.',
              style: TextStyle(color: Colors.white54),
            )
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children:
                  _statuses.map((status) {
                    final isSelected = status == game.status;
                    final isSubmitting = _statusSubmitting == status;
                    return ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(status),
                          if (isSubmitting) ...[
                            const SizedBox(width: 8),
                            const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          _updateStatus(status);
                        }
                      },
                      selectedColor: AppColors.accent,
                      backgroundColor: Colors.black54,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                      ),
                    );
                  }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(GameGetDto game) {
    String formatDate(DateTime? date) {
      if (date == null) return '-';
      final local = date.toLocal();
      final parts = local.toString().split('.');
      return parts.isNotEmpty ? parts.first : local.toIso8601String();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Match Info',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Start', formatDate(game.dateStart)),
          if (game.durationLabel != '-')
            _buildInfoRow('Duration', game.durationLabel),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54)),
          Text(value, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
