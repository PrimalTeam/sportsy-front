import 'package:flutter/material.dart';
import 'package:sportsy_front/core/theme/app_colors.dart';
import 'package:sportsy_front/dto/team_details_dto.dart';
import 'package:sportsy_front/features/teams/data/teams_remote_service.dart';
import 'package:sportsy_front/widgets/app_bar.dart';

class TeamDetailsPage extends StatefulWidget {
  const TeamDetailsPage({
    super.key,
    required this.roomId,
    required this.teamId,
    required this.teamName,
  });

  final int roomId;
  final int teamId;
  final String teamName;

  @override
  State<TeamDetailsPage> createState() => _TeamDetailsPageState();
}

class _TeamDetailsPageState extends State<TeamDetailsPage> {
  late Future<TeamDetailsDto> _detailsFuture;

  @override
  void initState() {
    super.initState();
    _detailsFuture = _loadDetails();
  }

  Future<TeamDetailsDto> _loadDetails() {
    return TeamsRemoteService.getTeamDetails(
      roomId: widget.roomId,
      teamId: widget.teamId,
    );
  }

  void _retry() {
    setState(() {
      _detailsFuture = _loadDetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MyAppBar(title: widget.teamName),
      body: FutureBuilder<TeamDetailsDto>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            );
          }
          if (snapshot.hasError) {
            return _TeamErrorView(onRetry: _retry);
          }
          final details = snapshot.data;
          if (details == null) {
            return const _TeamErrorView();
          }
          return _TeamDetailsContent(details: details);
        },
      ),
    );
  }
}

class _TeamErrorView extends StatelessWidget {
  const _TeamErrorView({this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Unable to load team details',
            style: TextStyle(color: Colors.white70),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.accent,
              ),
              child: const Text('Try again'),
            ),
          ],
        ],
      ),
    );
  }
}

class _TeamDetailsContent extends StatelessWidget {
  const _TeamDetailsContent({required this.details});

  final TeamDetailsDto details;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TeamHeader(details: details),
          const SizedBox(height: 16),
          if (details.sportType != null)
            _TeamDetailsSection(
              title: 'Sport type',
              child: Text(
                details.sportType!,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          if (details.tournament != null)
            _TournamentSection(info: details.tournament!),
          if (details.teamUsers.isNotEmpty)
            _TeamDetailsSection(
              title: 'Players',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    details.teamUsers
                        .map(
                          (player) => Chip(
                            label: Text(player),
                            backgroundColor: Colors.black54,
                            labelStyle: const TextStyle(color: Colors.white),
                          ),
                        )
                        .toList(),
              ),
            ),
          if (details.games.isNotEmpty) _GameSection(games: details.games),
          if (details.teamStatuses.isNotEmpty)
            _ScoreSection(statuses: details.teamStatuses),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _TeamHeader extends StatelessWidget {
  const _TeamHeader({required this.details});

  final TeamDetailsDto details;

  @override
  Widget build(BuildContext context) {
    final bytes = details.icon?.data;
    return Card(
      color: Colors.black.withOpacity(0.7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (bytes == null || bytes.isEmpty)
              const CircleAvatar(
                radius: 32,
                backgroundColor: Colors.black,
                child: Icon(Icons.group, color: AppColors.accent),
              )
            else
              ClipOval(
                child: Image.memory(
                  bytes,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => const CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.black,
                        child: Icon(
                          Icons.broken_image,
                          color: AppColors.accent,
                        ),
                      ),
                ),
              ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    details.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                    ),
                  ),
                  if (details.tournament?.title != null)
                    Text(
                      details.tournament!.title!,
                      style: const TextStyle(color: Colors.white70),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TournamentSection extends StatelessWidget {
  const _TournamentSection({required this.info});

  final TeamTournamentInfo info;

  @override
  Widget build(BuildContext context) {
    final rows = <_InfoRow>[];
    if (info.title != null && info.title!.isNotEmpty) {
      rows.add(_InfoRow(label: 'Title', value: info.title!));
    }
    if (info.description != null && info.description!.isNotEmpty) {
      rows.add(_InfoRow(label: 'Description', value: info.description!));
    }
    if (info.start != null || info.end != null) {
      final start = _formatDate(info.start);
      final end = _formatDate(info.end);
      rows.add(
        _InfoRow(label: 'Dates', value: start == end ? start : '$start - $end'),
      );
    }
    if (info.leaderType != null && info.leaderType!.isNotEmpty) {
      rows.add(_InfoRow(label: 'Leader', value: info.leaderType!));
    }

    if (rows.isEmpty) return const SizedBox.shrink();

    return _TeamDetailsSection(
      title: 'Tournament',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rows,
      ),
    );
  }

  String _formatDate(DateTime? value) {
    if (value == null) return 'Unknown';
    return '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
  }
}

class _GameSection extends StatelessWidget {
  const _GameSection({required this.games});

  final List<TeamGameInfo> games;

  @override
  Widget build(BuildContext context) {
    return _TeamDetailsSection(
      title: 'Games',
      child: Column(
        children: games
            .map((game) => _GameCard(game: game))
            .toList(growable: false),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({required this.game});

  final TeamGameInfo game;

  @override
  Widget build(BuildContext context) {
    final opponents =
        game.teamNames.isNotEmpty
            ? game.teamNames.join(', ')
            : 'Teams not specified';
    final date = _formatDateTime(game.dateStart);

    return Card(
      color: Colors.black54,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    game.status ?? 'Unknown status',
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (game.duration != null)
                  Text(
                    game.duration!,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            _InfoRow(label: 'Date', value: date),
            _InfoRow(label: 'Teams', value: opponents),
            if (game.teamStatuses.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: game.teamStatuses
                      .map(
                        (status) => Chip(
                          label: Text(_formatScore(status)),
                          backgroundColor: Colors.black38,
                          labelStyle: const TextStyle(color: Colors.white),
                        ),
                      )
                      .toList(growable: false),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatScore(TeamScoreInfo status) {
    final name = status.teamName ?? 'Team ${status.teamId ?? '?'}';
    final score = status.score?.toString() ?? '-';
    return '$name: $score';
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) return 'Unknown';
    final date =
        '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
    final time =
        '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
    return '$date $time';
  }
}

class _ScoreSection extends StatelessWidget {
  const _ScoreSection({required this.statuses});

  final List<TeamScoreInfo> statuses;

  @override
  Widget build(BuildContext context) {
    return _TeamDetailsSection(
      title: 'Team scores',
      child: Column(
        children: statuses
            .map(
              (status) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(
                  status.teamName ?? 'Team ${status.teamId ?? '?'}',
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: Text(
                  status.score?.toString() ?? '-',
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _TeamDetailsSection extends StatelessWidget {
  const _TeamDetailsSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.accent,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            color: Colors.black54,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(padding: const EdgeInsets.all(12), child: child),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
