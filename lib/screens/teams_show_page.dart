import 'package:flutter/material.dart';
import 'package:sportsy_front/core/theme/app_colors.dart';
import 'package:sportsy_front/dto/get_teams_dto.dart';
import 'package:sportsy_front/features/rooms/data/rooms_remote_service.dart';
import 'package:sportsy_front/features/teams/data/teams_remote_service.dart';
import 'package:sportsy_front/screens/team_edit_page.dart';
import 'package:sportsy_front/screens/team_details_page.dart';

enum _TeamsViewStatus { loading, error, empty, data }

class TeamsShowPage extends StatefulWidget {
  const TeamsShowPage({
    super.key,
    required this.roomId,
    this.canManage = true,
    this.bracketExists = false,
  });

  final int roomId;
  final bool canManage;
  final bool bracketExists;

  @override
  TeamsShowPageState createState() => TeamsShowPageState();
}

class TeamsShowPageState extends State<TeamsShowPage> {
  _TeamsViewStatus _status = _TeamsViewStatus.loading;
  List<GetTeamsDto> _teams = const [];

  @override
  void initState() {
    super.initState();
    _loadRoomAndTeams();
  }

  Future<void> reloadTeams() async {
    await _loadRoomAndTeams(showLoader: false);
  }

  Future<void> _loadRoomAndTeams({bool showLoader = true}) async {
    if (showLoader) {
      setState(() => _status = _TeamsViewStatus.loading);
    }
    try {
      final room = await RoomsRemoteService.getRoomInfo(widget.roomId);
      final teams = await TeamsRemoteService.getTeamsOfTournament(room.id);
      if (!mounted) return;

      setState(() {
        _teams = teams;
        _status =
            teams.isEmpty ? _TeamsViewStatus.empty : _TeamsViewStatus.data;
      });
    } catch (e, stackTrace) {
      debugPrint('TeamsShowPage: failed to load room/teams -> $e');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      setState(() => _status = _TeamsViewStatus.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    switch (_status) {
      case _TeamsViewStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case _TeamsViewStatus.error:
        return _TeamsMessageView(
          message: 'Failed to load teams',
          actionLabel: 'Retry',
          onActionPressed: _loadRoomAndTeams,
        );
      case _TeamsViewStatus.empty:
        return const _TeamsMessageView(message: 'No teams available');
      case _TeamsViewStatus.data:
        return RefreshIndicator(
          onRefresh: _loadRoomAndTeams,
          color: AppColors.accent,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: _teams.length,
            physics: const AlwaysScrollableScrollPhysics(),
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final team = _teams[index];
              return TeamCard(
                team: team,
                canManage: widget.canManage,
                onEdit: widget.canManage ? () => _openTeamEditor(team) : null,
                onInfo: () => _openTeamInfo(team),
              );
            },
          ),
        );
    }
  }

  Future<void> _openTeamEditor(GetTeamsDto team) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => TeamEditPage(
          roomId: widget.roomId,
          team: team,
          bracketExists: widget.bracketExists,
        ),
      ),
    );
    if (changed == true && mounted) {
      await _loadRoomAndTeams(showLoader: false);
    }
  }

  Future<void> _openTeamInfo(GetTeamsDto team) async {
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => TeamDetailsPage(
              roomId: widget.roomId,
              teamId: team.id,
              teamName: team.name,
            ),
      ),
    );
  }
}

class _TeamsMessageView extends StatelessWidget {
  const _TeamsMessageView({
    required this.message,
    this.actionLabel,
    this.onActionPressed,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            style: textTheme.titleMedium?.copyWith(color: AppColors.accent),
            textAlign: TextAlign.center,
          ),
          if (actionLabel != null && onActionPressed != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onActionPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.accent,
              ),
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

class TeamCard extends StatelessWidget {
  const TeamCard({
    required this.team,
    required this.canManage,
    this.onEdit,
    this.onInfo,
    super.key,
  });

  final GetTeamsDto team;
  final bool canManage;
  final VoidCallback? onEdit;
  final VoidCallback? onInfo;

  @override
  Widget build(BuildContext context) {
    final tapHandler = canManage ? onEdit : onInfo;
    return InkWell(
      onTap: tapHandler,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.85),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.accent, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withOpacity(0.2),
              blurRadius: 6,
              spreadRadius: 1,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            _TeamAvatar(team: team),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                team.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (canManage)
                  IconButton(
                    icon: const Icon(Icons.edit, color: AppColors.accent),
                    tooltip: 'Edit team',
                    onPressed: onEdit,
                  ),
                IconButton(
                  icon: const Icon(Icons.info_outline, color: AppColors.accent),
                  tooltip: 'View team info',
                  onPressed: onInfo,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamAvatar extends StatelessWidget {
  const _TeamAvatar({required this.team});

  final GetTeamsDto team;

  @override
  Widget build(BuildContext context) {
    final bytes = team.icon?.data;
    if (bytes == null || bytes.isEmpty) {
      return const CircleAvatar(
        radius: 26,
        backgroundColor: Colors.black,
        child: Icon(Icons.group, color: AppColors.accent),
      );
    }

    return ClipOval(
      child: Image.memory(
        bytes,
        width: 52,
        height: 52,
        fit: BoxFit.cover,
        errorBuilder:
            (_, __, ___) => const CircleAvatar(
              radius: 26,
              backgroundColor: Colors.black,
              child: Icon(Icons.broken_image, color: AppColors.accent),
            ),
      ),
    );
  }
}
