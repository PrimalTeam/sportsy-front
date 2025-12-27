import 'package:flutter/material.dart';
import 'package:sportsy_front/custom_colors.dart';
import 'package:sportsy_front/features/rooms/data/rooms_remote_service.dart';
import 'package:sportsy_front/features/tournaments/data/ladder_remote_service.dart';
import 'package:sportsy_front/features/tournaments/data/tournaments_remote_service.dart';
import 'package:sportsy_front/screens/room_users_screen.dart';
import 'package:sportsy_front/screens/teams_show_page.dart';
import 'package:sportsy_front/widgets/app_bar.dart';
import 'package:sportsy_front/dto/room_info_dto.dart';

class TournamentInfoEdit extends StatefulWidget {
  const TournamentInfoEdit({
    super.key,
    required this.roomId,
    this.initialRoomInfo,
    this.userRole = 'gameObserver',
  });
  final int roomId;
  final RoomInfoDto? initialRoomInfo;
  final String userRole;

  @override
  State<TournamentInfoEdit> createState() => _TournamentInfoEditPageState();
}

class _TournamentInfoEditPageState extends State<TournamentInfoEdit>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  RoomInfoDto? _roomInfo;
  bool _isLoading = true;
  late String role;
  bool get _canManage => role == 'admin' || role == 'spectrator';
  final tournamentTitleController = TextEditingController();
  final tournamentDescriptionController = TextEditingController();
  final tournamentStartDateController = TextEditingController();
  String tournamentEndDateController = "";
  DateTime? _selectedDateTimeStart;
  DateTime? _selectedDateTimeEnd;

  bool _autoConfigLoading = true;
  bool _autoGenerate = false;
  bool _updatingAuto = false;
  String? _autoConfigError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    role = widget.userRole.toLowerCase();
    // If the parent passed initial room info, use it to prefill fields and skip fetching.
    if (widget.initialRoomInfo != null) {
      _roomInfo = widget.initialRoomInfo;
      _isLoading = false;

      final tournament = _roomInfo?.tournament;
      if (tournament != null) {
        tournamentTitleController.text = tournament.info.title;
        tournamentDescriptionController.text = tournament.info.description;
        _selectedDateTimeStart = tournament.info.dateStart;
        _selectedDateTimeEnd = tournament.info.dateEnd;
        tournamentEndDateController = tournament.info.dateEnd.toString();
        _loadTournamentConfig(tournament.id);
      }
    } else {
      _initializeData();
    }
  }

  Future<void> _initializeData() async {
    try {
      final roomInfo = await RoomsRemoteService.getRoomInfo(widget.roomId);
      print(roomInfo);
      setState(() {
        _roomInfo = roomInfo;
        _isLoading = false;
      });
      if (roomInfo.tournament != null) {
        _loadTournamentConfig(roomInfo.tournament!.id);
      }
    } catch (e) {
      print("Error fetching room info: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<DateTime?> _pickDateTime(DateTime? initialDateTime) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      helpText: 'Select tournament date',
      initialDate: initialDateTime ?? DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        return DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      }
    }
    return null;
  }

  @override
  void dispose() {
    _tabController.dispose();
    tournamentTitleController.dispose();
    tournamentDescriptionController.dispose();
    tournamentStartDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MyAppBar(title: 'Tournament Info'),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : GestureDetector(
                onHorizontalDragEnd: (DragEndDetails details) {
                  if (details.primaryVelocity! > 0) {
                    if (_tabController.index > 0) {
                      _tabController.animateTo(_tabController.index - 1);
                    }
                  } else if (details.primaryVelocity! < 0) {
                    if (_tabController.index < 2) {
                      _tabController.animateTo(_tabController.index + 1);
                    }
                  }
                },
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildInfoTab(),
                    Center(
                      child: Text(
                        'Widok gier',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    TeamsShowPage(roomId: widget.roomId, canManage: _canManage),
                    RoomUsersScreen(roomId: widget.roomId, role: role),
                  ],
                ),
              ),
    );
  }

  Widget _buildInfoTab() {
    if (_roomInfo == null) {
      return Center(
        child: Text('No data available', style: TextStyle(color: Colors.white)),
      );
    }

    // using _roomInfo to prefill controllers; no local tournament variable needed here

    return Container(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 15),
            TextField(
              controller: tournamentTitleController,
              decoration: const InputDecoration(
                hintText: 'Title',
                prefixIcon: Icon(Icons.title),
              ),
            ),

            SizedBox(height: 15),

            TextField(
              controller: tournamentDescriptionController,
              maxLines: null,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.description),
                hintText: 'Description',
              ),
            ),
            SizedBox(height: 15),

            TextField(
              readOnly: true,
              onTap: () async {
                final dateTime = await _pickDateTime(_selectedDateTimeStart);
                if (dateTime != null) {
                  setState(() {
                    _selectedDateTimeStart = dateTime;
                  });
                }
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.calendar_today),
                hintText:
                    _selectedDateTimeStart == null
                        ? 'Start date and time'
                        : _formatDate(_selectedDateTimeStart!),
              ),
            ),
            SizedBox(height: 15),

            TextField(
              readOnly: true,
              onTap: () async {
                final dateTime = await _pickDateTime(_selectedDateTimeEnd);
                if (dateTime != null) {
                  setState(() {
                    _selectedDateTimeEnd = dateTime;
                    tournamentEndDateController = dateTime.toString();
                  });
                }
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.calendar_month),
                hintText:
                    _selectedDateTimeEnd == null
                        ? 'End date and time'
                        : _formatDate(_selectedDateTimeEnd!),
              ),
            ),
            SizedBox(height: 15),
            _buildAutoGenerateToggle(),
            SizedBox(height: 15),
            ElevatedButton(onPressed: () {}, child: Text("Save Changes")),
          ],
        ),
      ),
    );
  }

  Future<void> _loadTournamentConfig(int tournamentId) async {
    try {
      final tournament = await TournamentsRemoteService.getTournament(
        roomId: widget.roomId,
        tournamentId: tournamentId,
        includes: const [],
      );
      if (!mounted) return;
      setState(() {
        _autoGenerate =
            tournament.internalConfig?.autogenerateGamesFromLadder ?? false;
        _autoConfigLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _autoConfigError = e.toString();
        _autoConfigLoading = false;
      });
    }
  }

  Future<void> _updateAutoGenerate(bool value) async {
    final tournamentId = _roomInfo?.tournament?.id;
    if (tournamentId == null) return;

    setState(() {
      _updatingAuto = true;
      _autoGenerate = value;
      _autoConfigError = null;
    });

    try {
      await TournamentsRemoteService.updateAutogenerateConfig(
        roomId: widget.roomId,
        tournamentId: tournamentId,
        autogenerate: value,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value
                ? 'Automatic bracket progression enabled'
                : 'Automatic bracket progression disabled',
          ),
        ),
      );

      if (value) {
        try {
          await LadderRemoteService.updateLadder(roomId: widget.roomId);
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to sync bracket: $e')),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _autoGenerate = !value;
        _autoConfigError = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update setting: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _updatingAuto = false;
        });
      }
    }
  }

  Widget _buildAutoGenerateToggle() {
    if (_roomInfo?.tournament == null) {
      return const SizedBox.shrink();
    }

    if (_autoConfigLoading) {
      return Row(
        children: const [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Loading bracket settings…',
              style: TextStyle(color: Colors.white54),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.accent.withOpacity(0.25)),
          ),
          child: SwitchListTile.adaptive(
            value: _autoGenerate,
            onChanged:
                _updatingAuto
                    ? null
                    : (value) {
                      _updateAutoGenerate(value);
                    },
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            activeColor: AppColors.accent,
            title: const Text(
              'Automatic bracket pairings',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              'Let the backend assign teams for upcoming matches based on '
              'ladder progression.',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ),
        if (_updatingAuto)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: LinearProgressIndicator(minHeight: 2),
          ),
        if (_autoConfigError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _autoConfigError!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
            ),
          ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${date.year}.${twoDigits(date.month)}.${twoDigits(date.day)} ${twoDigits(date.hour)}:${twoDigits(date.minute)}';
  }
}
