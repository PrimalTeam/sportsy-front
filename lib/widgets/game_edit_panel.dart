import 'package:flutter/material.dart';
import 'package:sportsy_front/custom_colors.dart';
import 'package:sportsy_front/dto/game_get_dto.dart';
import 'package:sportsy_front/features/games/data/games_remote_service.dart';
import 'package:sportsy_front/features/team_status/data/team_status_remote_service.dart';

class GameEditPanel extends StatefulWidget {
  final int roomId;
  final GameGetDto game;
  final ValueChanged<GameGetDto> onGameChanged;

  const GameEditPanel({
    super.key,
    required this.roomId,
    required this.game,
    required this.onGameChanged,
  });

  @override
  State<GameEditPanel> createState() => _GameEditPanelState();
}

class _GameEditPanelState extends State<GameEditPanel> {
  late GameGetDto _game;
  List<String> _statuses = [];
  bool _loadingStatuses = true;
  bool _statusesError = false;
  final Set<int> _pendingScoreUpdates = <int>{};
  String? _statusSubmitting;

  @override
  void initState() {
    super.initState();
    _game = widget.game;
    _loadStatuses();
  }

  @override
  void didUpdateWidget(covariant GameEditPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.game.id != widget.game.id) {
      _game = widget.game;
      _pendingScoreUpdates.clear();
      _statusSubmitting = null;
      _loadingStatuses = true;
      _statusesError = false;
      _loadStatuses();
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
        _statusesError = true;
      });
    }
  }

  Future<void> _incrementScore(GameTeamStatusSummary status) async {
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
        gameId: _game.id,
        teamId: teamId,
        score: newScore,
      );

      final updatedStatuses =
          _game.teamStatuses.map((entry) {
            if (entry.teamId == teamId) {
              return entry.copyWith(score: newScore);
            }
            return entry;
          }).toList();

      if (!mounted) return;
      setState(() {
        _game = _game.copyWith(teamStatuses: updatedStatuses);
        _pendingScoreUpdates.remove(teamId);
      });
      widget.onGameChanged(_game);
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
    if (_statusSubmitting == newStatus) return;

    setState(() {
      _statusSubmitting = newStatus;
    });

    try {
      await GamesRemoteService.updateGame(
        roomId: widget.roomId,
        gameId: _game.id,
        status: newStatus,
      );

      if (!mounted) return;
      setState(() {
        _game = _game.copyWith(status: newStatus);
        _statusSubmitting = null;
      });
      widget.onGameChanged(_game);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.zero,
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Container(
              color: AppColors.background,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Edit Match',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    if (_game.teamStatuses.isEmpty)
                      const Text(
                        'No teams assigned to this match yet.',
                        style: TextStyle(color: Colors.white70),
                      )
                    else
                      Column(
                        children:
                            _game.teamStatuses.map((status) {
                              final isLoading =
                                  status.teamId != null &&
                                  _pendingScoreUpdates.contains(status.teamId);
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: AppColors.accent
                                          .withOpacity(0.2),
                                      child: Text(
                                        (status.teamName?.isNotEmpty ?? false)
                                            ? status.teamName![0].toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            status.teamName ??
                                                'Team ${status.teamId ?? '-'}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Score: ${status.score}',
                                            style: const TextStyle(
                                              color: Colors.white60,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    ElevatedButton(
                                      onPressed:
                                          status.teamId != null && !isLoading
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
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(Colors.white),
                                                ),
                                              )
                                              : const Icon(
                                                Icons.add,
                                                color: Colors.white,
                                              ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                      ),
                    const SizedBox(height: 8),
                    const Divider(color: Colors.white12),
                    const SizedBox(height: 16),
                    const Text(
                      'Match status',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_loadingStatuses)
                      const Center(child: CircularProgressIndicator())
                    else if (_statusesError)
                      OutlinedButton.icon(
                        onPressed: _loadStatuses,
                        icon: const Icon(Icons.refresh, color: Colors.white70),
                        label: const Text(
                          'Failed to load statuses. Tap to retry.',
                          style: TextStyle(color: Colors.white70),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white24),
                        ),
                      )
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
                              final isSelected = status == _game.status;
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
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected &&
                                      !_loadingStatuses &&
                                      !_statusesError) {
                                    _updateStatus(status);
                                  }
                                },
                                selectedColor: AppColors.accent,
                                backgroundColor: Colors.black54,
                                labelStyle: TextStyle(
                                  color:
                                      isSelected
                                          ? Colors.white
                                          : Colors.white70,
                                ),
                              );
                            }).toList(),
                      ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
