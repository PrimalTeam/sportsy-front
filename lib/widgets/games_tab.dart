import 'package:flutter/material.dart';
import 'package:sportsy_front/modules/services/auth.dart';
import 'package:sportsy_front/dto/get_teams_dto.dart';
import 'package:sportsy_front/custom_colors.dart';
import 'package:sportsy_front/dto/game_create_dto.dart';

class GamesTab extends StatefulWidget {
  final int roomId;
  final int? tournamentId;
  final List<int>? allowedTeamIds;
  final List<GetTeamsDto>? initialTeams;
  const GamesTab({
    super.key,
    required this.roomId,
    required this.tournamentId,
    this.allowedTeamIds,
    this.initialTeams,
  });

  @override
  State<GamesTab> createState() => _GamesTabState();
}

class _GamesTabState extends State<GamesTab> {
  List<GetTeamsDto> _teams = [];
  bool _loading = true;
  bool _error = false;
  Set<int> _allowedTeamIds = {};

  int? _selectedLeft;
  int? _selectedRight;

  DateTime _dateStart = DateTime.now();
  Duration _duration = const Duration(hours: 1, minutes: 30);

  @override
  void initState() {
    super.initState();
    if (widget.allowedTeamIds != null && widget.allowedTeamIds!.isNotEmpty) {
      _allowedTeamIds = widget.allowedTeamIds!.toSet();
    }
    if (widget.initialTeams != null && widget.initialTeams!.isNotEmpty) {
      _teams = List<GetTeamsDto>.from(widget.initialTeams!);
      _allowedTeamIds = _teams.map((t) => t.id).toSet();
      _loading = false;
    }
    _loadTeams();
  }

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
          debugPrint('GamesTab: no overlap between allowed IDs $_allowedTeamIds and API result (${rawTeams.length}). Keeping current list.');
          teams = List<GetTeamsDto>.from(_teams);
        }
      } else {
        final filtered = rawTeams
            .where((team) => team.tournamentId == widget.tournamentId)
            .toList(growable: false);
        teams = filtered.isNotEmpty ? filtered : rawTeams;
        _allowedTeamIds = teams.map((t) => t.id).toSet();
        if (filtered.isEmpty) {
          debugPrint('GamesTab: API did not provide tournament-specific teams; using full list (${teams.length}).');
        }
      }
      if (!mounted) return;
      setState(() {
        _teams = teams;
        _loading = false;
      });
      debugPrint('GamesTab: loaded ${teams.length} teams, allowed IDs: $_allowedTeamIds');
    } catch (e) {
      if (!mounted) return;
      setState(() { _loading = false; _error = true; });
    }
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

  String _teamNameById(int? id) {
    if (id == null) return '';
    try {
      return _teams.firstWhere((t) => t.id == id).name;
    } catch (_) {
      return '';
    }
  }

  bool _teamsBelongToTournament(List<int> ids) {
    if (_allowedTeamIds.isEmpty) return false;
    return ids.every(_allowedTeamIds.contains);
  }

  void _openTeamPicker(bool leftSide) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        final TextEditingController searchController = TextEditingController();
        List<GetTeamsDto> filtered = List.from(_teams);
        return StatefulBuilder(
          builder: (context, setSheetState) {
            void applyFilter() {
              final q = searchController.text.trim().toLowerCase();
              setSheetState(() {
                filtered = _teams.where((t) => t.name.toLowerCase().contains(q)).toList();
              });
            }
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          leftSide ? 'Select Team A' : 'Select Team B',
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close, color: Colors.white54),
                      ),
                    ],
                  ),
                  TextField(
                    controller: searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Search team',
                      hintStyle: TextStyle(color: Colors.white54),
                      prefixIcon: Icon(Icons.search, color: Colors.white54),
                    ),
                    onChanged: (_) => applyFilter(),
                  ),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 400),
                    child: filtered.isEmpty
                        ? const Center(
                            child: Text('No teams match', style: TextStyle(color: Colors.white70)),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: filtered.length,
                            itemBuilder: (c, i) {
                              final team = filtered[i];
                              final bytes = team.icon?.data;
                              final hasImage = bytes != null && bytes.isNotEmpty;
                              final isSelected = leftSide ? _selectedLeft == team.id : _selectedRight == team.id;
                              return ListTile(
                                selected: isSelected,
                                selectedTileColor: Colors.white10,
                                leading: hasImage
                                    ? ClipOval(
                                        child: Image.memory(
                                          bytes,
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                          errorBuilder: (c, e, st) => CircleAvatar(
                                            backgroundColor: Colors.grey.shade900,
                                            child: const Icon(Icons.broken_image, color: Colors.white70),
                                          ),
                                        ),
                                      )
                                    : CircleAvatar(
                                        backgroundColor: Colors.grey.shade900,
                                        child: const Icon(Icons.group, color: Colors.white70),
                                      ),
                                title: Text(
                                  team.name,
                                  style: const TextStyle(color: Colors.white),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: isSelected ? const Icon(Icons.check, color: Colors.white70) : null,
                                onTap: () {
                                  setState(() {
                                    if (leftSide) {
                                      _selectedLeft = team.id;
                                    } else {
                                      _selectedRight = team.id;
                                    }
                                  });
                                  Navigator.pop(ctx);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _createGame() async {
    if (!_canCreate || widget.tournamentId == null) return;
    try {
      final selectedTeamIds = [_selectedLeft!, _selectedRight!];
      if (!_teamsBelongToTournament(selectedTeamIds)) {
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
      await AuthService.createGame(roomId: widget.roomId, tournamentId: widget.tournamentId!, game: game);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Game created')));
      setState(() { _selectedLeft = null; _selectedRight = null; });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create game: $e')));
    }
  }

  // Removed old list tile builder (replaced by searchable picker UI)

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
    if (_teams.isEmpty) {
      return const Center(child: Text('Brak dostępnych drużyn w tym turnieju', style: TextStyle(color: Colors.white70)));
    }

    return Column(
      children: [
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _teams.isEmpty ? null : () => _openTeamPicker(true),
                  style: OutlinedButton.styleFrom(side: BorderSide(color: _selectedLeft != null ? AppColors.accent : Colors.white24)),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                          _selectedLeft == null
                            ? 'Select Team A'
                            : _teamNameById(_selectedLeft),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: _selectedLeft != null ? AppColors.accent : Colors.white70),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: _teams.isEmpty ? null : () => _openTeamPicker(false),
                  style: OutlinedButton.styleFrom(side: BorderSide(color: _selectedRight != null ? AppColors.accent : Colors.white24)),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                          _selectedRight == null
                            ? 'Select Team B'
                            : _teamNameById(_selectedRight),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: _selectedRight != null ? AppColors.accent : Colors.white70),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
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
