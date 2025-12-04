import 'package:flutter/material.dart';
import 'package:sportsy_front/dto/game_get_dto.dart';
import 'package:sportsy_front/features/games/data/games_remote_service.dart';

class GamesTab extends StatefulWidget {
  final int roomId;
  final int? tournamentId;
  const GamesTab({super.key, required this.roomId, required this.tournamentId});

  @override
  GamesTabState createState() => GamesTabState();
}

class GamesTabState extends State<GamesTab> {
  List<GameGetDto> _games = [];
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  Future<void> reloadGames() => _loadGames();

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
      final games = await GamesRemoteService.getGamesByTournament(
        widget.roomId,
      );
      if (!mounted) return;
      setState(() {
        _games = games;
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

  String _scoreLabel(GameGetDto game) {
    if (game.teamStatuses.isEmpty) return 'Score: -';
    final scores = game.teamStatuses.map((s) => s.score.toString()).join(' : ');
    return 'Score: $scores';
  }

  String _titleFor(GameGetDto game) {
    final names = game.teamNames;
    if (names.length >= 2) {
      return '${names[0]} vs ${names[1]}';
    }
    if (names.length == 1) {
      return names.first;
    }
    if (game.teamIds.isNotEmpty) {
      return 'Game ${game.teamIds.join(" / ")}';
    }
    return 'Game ${game.id}';
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
              : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: _games.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final game = _games[index];
                  final title = _titleFor(game);
                  final subtitleStyle = const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  );
                  return Container(
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
                          Text(_scoreLabel(game), style: subtitleStyle),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
