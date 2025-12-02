import 'package:flutter/material.dart';
import 'package:sportsy_front/modules/services/auth.dart';
import 'package:sportsy_front/dto/get_teams_dto.dart';
import 'package:sportsy_front/custom_colors.dart';
import 'package:sportsy_front/dto/game_create_dto.dart';

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

  Future<void> _loadTeams() async {
    if (widget.tournamentId == null) {
      setState(() { _loading = false; _error = true; });
      return;
    }
    try {
      final rawTeams = await AuthService.getTeamsOfTournament(widget.tournamentId!);
      List<GetTeamsDto> teams;
      if (_allowedTeamIds.isNotEmpty) {
        final filtered = rawTeams.where((team) => _allowedTeamIds.contains(team.id)).toList(growable: false);
        if (filtered.isNotEmpty) {
          teams = filtered;
          _allowedTeamIds = teams.map((t) => t.id).toSet();
        } else {
          debugPrint('GamesPage: no overlap between allowed IDs $_allowedTeamIds and API result (${rawTeams.length}). Keeping current list.');
          teams = List<GetTeamsDto>.from(_teams);
        }
      } else {
        final filtered = rawTeams
            .where((team) => team.tournamentId == widget.tournamentId)
            .toList(growable: false);
        teams = filtered.isNotEmpty ? filtered : rawTeams;
        _allowedTeamIds = teams.map((t) => t.id).toSet();
        if (filtered.isEmpty) {
          debugPrint('GamesPage: API did not provide tournament-specific teams; using full list (${teams.length}).');
        }
      }
      if (!mounted) return;
      setState(() {
        _teams = teams;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _loading = false; _error = true; });
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.allowedTeamIds != null && widget.allowedTeamIds!.isNotEmpty) {
      _allowedTeamIds = widget.allowedTeamIds!.toSet();
    }
    _loadTeams();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateStart,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_dateStart),
      );
      if (time != null) {
        setState(() {
          _dateStart = DateTime(date.year, date.month, date.day, time.hour, time.minute);
        });
      }
    }
  }

  Future<void> _pickDuration() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _duration.inHours, minute: _duration.inMinutes % 60),
    );
    if (time != null) {
      setState(() { _duration = Duration(hours: time.hour, minutes: time.minute); });
    }
  }

  bool get _canCreate => _selectedLeft != null && _selectedRight != null && _selectedLeft != _selectedRight;

  Future<void> _createGame() async {
    if (!_canCreate || widget.tournamentId == null) return;
    try {
      final selectedTeamIds = [_selectedLeft!, _selectedRight!];
      if (!_belongToTournament(selectedTeamIds)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selected teams are not in this tournament')),
        );
        return;
      }
      final game = GameCreateDto(
        status: 'Pending',
        dateStart: _dateStart,
        durationTime: _duration,
        teamIds: selectedTeamIds,
        teamStatuses: List.generate(
          selectedTeamIds.length,
          (index) => TeamStatusDto(teamId: selectedTeamIds[index], score: 0),
        ),
      );
      await AuthService.createGame(
        roomId: widget.roomId,
        tournamentId: widget.tournamentId!,
        game: game,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Game created')));
      setState(() { _selectedLeft = null; _selectedRight = null; });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create game: $e')));
    }
  }

  bool _belongToTournament(List<int> ids) {
    if (_allowedTeamIds.isEmpty) return false;
    return ids.every(_allowedTeamIds.contains);
  }

  Widget _buildTeamTile(GetTeamsDto team, bool leftSide) {
    final selected = leftSide ? _selectedLeft == team.id : _selectedRight == team.id;
    final bytes = team.icon?.data;
    final hasImage = bytes != null && bytes.isNotEmpty;
    return InkWell(
      onTap: () {
        setState(() {
          if (leftSide) {
            _selectedLeft = team.id;
          } else {
            _selectedRight = team.id;
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.85),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppColors.accent : Colors.grey.shade700, width: selected ? 2 : 1),
        ),
        child: Row(
          children: [
            hasImage
                ? ClipOval(child: Image.memory(bytes!, width: 40, height: 40, fit: BoxFit.cover))
                : CircleAvatar(backgroundColor: Colors.grey.shade900, child: const Icon(Icons.group, color: Colors.white70)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                team.name,
                style: TextStyle(color: selected ? AppColors.accent : Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error) {
      return const Center(child: Text('Failed to load teams', style: TextStyle(color: Colors.white)));
    }
    if (widget.tournamentId == null) {
      return const Center(child: Text('No tournament', style: TextStyle(color: Colors.white)));
    }

    return Column(
      children: [
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Text('Team A', style: TextStyle(color: Colors.white70)),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _teams.length,
                        itemBuilder: (c, i) => _buildTeamTile(_teams[i], true),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  children: [
                    const Text('Team B', style: TextStyle(color: Colors.white70)),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _teams.length,
                        itemBuilder: (c, i) => _buildTeamTile(_teams[i], false),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _pickDateTime,
                  child: Text('Start: ${_dateStart.toLocal().toString().split('.').first}', style: const TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: _pickDuration,
                  child: Text('Duration: ${_duration.inHours.toString().padLeft(2,'0')}:${(_duration.inMinutes % 60).toString().padLeft(2,'0')}:00'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canCreate ? _createGame : null,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, disabledBackgroundColor: Colors.grey.shade800),
              child: const Text('Create Game'),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
