import 'package:flutter/material.dart';
import 'package:sportsy_front/custom_colors.dart';
import 'package:sportsy_front/dto/game_create_dto.dart';
import 'package:sportsy_front/dto/get_teams_dto.dart';
import 'package:sportsy_front/features/games/data/games_remote_service.dart';
import 'package:sportsy_front/features/teams/data/teams_remote_service.dart';
import 'package:sportsy_front/widgets/app_bar.dart';

class GamesPage extends StatefulWidget {
  final int roomId;
  final int? tournamentId;
  final List<int>? allowedTeamIds;

  const GamesPage({
    super.key,
    required this.roomId,
    required this.tournamentId,
    this.allowedTeamIds,
  });

  @override
  State<GamesPage> createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> {
  List<GetTeamsDto> _teams = [];
  bool _loading = true;
  bool _error = false;
  Set<int> _allowedTeamIds = {};

  int? _selectedLeft;
  int? _selectedRight;

  DateTime _dateStart = DateTime.now();
  Duration _duration = const Duration(hours: 1, minutes: 30);

  bool get _canCreate =>
      _selectedLeft != null &&
      _selectedRight != null &&
      _selectedLeft != _selectedRight;

  @override
  void initState() {
    super.initState();
    if (widget.allowedTeamIds?.isNotEmpty ?? false) {
      _allowedTeamIds = widget.allowedTeamIds!.toSet();
    }
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    if (widget.tournamentId == null) {
      _handleError();
      return;
    }
    try {
      final rawTeams = await TeamsRemoteService.getTeamsOfTournament(
        widget.roomId,
      );
      final processedTeams = _processTeams(rawTeams);

      if (!mounted) return;
      setState(() {
        _teams = processedTeams;
        // Update allowed IDs to match what we are actually showing
        _allowedTeamIds = processedTeams.map((t) => t.id).toSet();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      _handleError();
    }
  }

  void _handleError() {
    setState(() {
      _loading = false;
      _error = true;
    });
  }

  List<GetTeamsDto> _processTeams(List<GetTeamsDto> rawTeams) {
    // If we have a pre-defined set of allowed IDs, try to filter by them
    if (_allowedTeamIds.isNotEmpty) {
      final filtered =
          rawTeams.where((team) => _allowedTeamIds.contains(team.id)).toList();
      if (filtered.isNotEmpty) {
        return filtered;
      }
      debugPrint(
        'GamesPage: no overlap between allowed IDs $_allowedTeamIds and API result. Using raw list.',
      );
      return rawTeams;
    }

    // Otherwise, try to filter by tournamentId if available on the team object
    final filtered =
        rawTeams
            .where((team) => team.tournamentId == widget.tournamentId)
            .toList();

    if (filtered.isNotEmpty) {
      return filtered;
    }

    debugPrint(
      'GamesPage: API did not provide tournament-specific teams; using full list.',
    );
    return rawTeams;
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateStart,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null) return;

    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dateStart),
    );

    if (time != null && mounted) {
      setState(() {
        _dateStart = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
      });
    }
  }

  Future<void> _pickDuration() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: _duration.inHours,
        minute: _duration.inMinutes % 60,
      ),
    );
    if (time != null && mounted) {
      setState(() {
        _duration = Duration(hours: time.hour, minutes: time.minute);
      });
    }
  }

  Future<void> _createGame() async {
    if (!_canCreate || widget.tournamentId == null) return;

    final selectedTeamIds = [_selectedLeft!, _selectedRight!];
    if (!_validateTeams(selectedTeamIds)) return;

    try {
      final game = _buildGameDto(selectedTeamIds);
      await GamesRemoteService.createGame(
        roomId: widget.roomId,
        tournamentId: widget.tournamentId!,
        game: game,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Game created')));

      _resetSelection();
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to create game: $e')));
    }
  }

  bool _validateTeams(List<int> ids) {
    if (_allowedTeamIds.isEmpty) return false;
    final isValid = ids.every(_allowedTeamIds.contains);
    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selected teams are not in this tournament'),
        ),
      );
    }
    return isValid;
  }

  GameCreateDto _buildGameDto(List<int> teamIds) {
    return GameCreateDto(
      status: 'Pending',
      dateStart: _dateStart,
      durationTime: _duration,
      teamIds: teamIds,
      teamStatuses: List.generate(
        teamIds.length,
        (index) => TeamStatusDto(teamId: teamIds[index], score: 0),
      ),
    );
  }

  void _resetSelection() {
    setState(() {
      _selectedLeft = null;
      _selectedRight = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MyAppBar(title: 'Create Game'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error) {
      return const Center(
        child: Text(
          'Failed to load teams',
          style: TextStyle(color: Colors.white),
        ),
      );
    }
    if (widget.tournamentId == null) {
      return const Center(
        child: Text('No tournament', style: TextStyle(color: Colors.white)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: TeamSelectionColumn(
                  label: 'Team A',
                  teams: _teams,
                  selectedId: _selectedLeft,
                  onSelect: (id) => setState(() => _selectedLeft = id),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TeamSelectionColumn(
                  label: 'Team B',
                  teams: _teams,
                  selectedId: _selectedRight,
                  onSelect: (id) => setState(() => _selectedRight = id),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildTimeControls(),
        const SizedBox(height: 16),
        _buildCreateButton(),
      ],
    );
  }

  Widget _buildTimeControls() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _pickDateTime,
            child: Text(
              'Start: ${_dateStart.toLocal().toString().split('.').first}',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: _pickDuration,
            child: Text(
              'Duration: ${_duration.inHours.toString().padLeft(2, '0')}:${(_duration.inMinutes % 60).toString().padLeft(2, '0')}:00',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _canCreate ? _createGame : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          disabledBackgroundColor: Colors.grey.shade800,
        ),
        child: const Text('Create Game'),
      ),
    );
  }
}

class TeamSelectionColumn extends StatelessWidget {
  final String label;
  final List<GetTeamsDto> teams;
  final int? selectedId;
  final ValueChanged<int> onSelect;

  const TeamSelectionColumn({
    super.key,
    required this.label,
    required this.teams,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 8),
        Expanded(
          child:
              teams.isEmpty
                  ? const Center(
                    child: Text(
                      'No teams available',
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                  : ListView.separated(
                    itemCount: teams.length,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    separatorBuilder: (_, __) => const SizedBox(height: 4),
                    itemBuilder:
                        (context, index) => TeamSelectionTile(
                          team: teams[index],
                          isSelected: teams[index].id == selectedId,
                          onTap: () => onSelect(teams[index].id),
                        ),
                  ),
        ),
      ],
    );
  }
}

class TeamSelectionTile extends StatelessWidget {
  final GetTeamsDto team;
  final bool isSelected;
  final VoidCallback onTap;

  const TeamSelectionTile({
    super.key,
    required this.team,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bytes = team.icon?.data;
    final hasImage = bytes != null && bytes.isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color:
            isSelected
                ? AppColors.accent.withOpacity(0.18)
                : Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? AppColors.accent : Colors.white24,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        leading:
            hasImage
                ? ClipOval(
                  child: Image.memory(
                    bytes!,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                )
                : CircleAvatar(
                  backgroundColor: Colors.grey.shade900,
                  child: const Icon(Icons.group, color: Colors.white70),
                ),
        title: Text(
          team.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Icon(
          isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
          color: isSelected ? AppColors.accent : Colors.white54,
        ),
      ),
    );
  }
}
