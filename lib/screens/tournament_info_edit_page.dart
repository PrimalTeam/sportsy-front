import 'package:flutter/material.dart';
import 'package:sportsy_front/custom_colors.dart';
import 'package:sportsy_front/features/rooms/data/rooms_remote_service.dart';
import 'package:sportsy_front/screens/room_users_screen.dart';
import 'package:sportsy_front/screens/teams_show_page.dart';
import 'package:sportsy_front/widgets/app_bar.dart';
import 'package:sportsy_front/widgets/tournament_bottom_bar.dart';
import 'package:sportsy_front/dto/room_info_dto.dart';

class TournamentInfoEdit extends StatefulWidget {
  const TournamentInfoEdit({
    super.key,
    required this.roomId,
    this.initialRoomInfo,
  });
  final int roomId;
  final RoomInfoDto? initialRoomInfo;

  @override
  State<TournamentInfoEdit> createState() => _TournamentInfoEditPageState();
}

class _TournamentInfoEditPageState extends State<TournamentInfoEdit>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  RoomInfoDto? _roomInfo;
  bool _isLoading = true;
  String role = "admin";
  final tournamentTitleController = TextEditingController();
  final tournamentDescriptionController = TextEditingController();
  final tournamentStartDateController = TextEditingController();
  String tournamentEndDateController = "";
  DateTime? _selectedDateTimeStart;
  DateTime? _selectedDateTimeEnd;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
                    Center(child: TeamsShowPage(roomId: widget.roomId)),
                    Center(
                      child: RoomUsersScreen(roomId: widget.roomId, role: role),
                    ),
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
                        : '${_selectedDateTimeStart!.toLocal()}'.split('.')[0],
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
                        : '${_selectedDateTimeEnd!.toLocal()}'.split('.')[0],
              ),
            ),
            SizedBox(height: 15),
            ElevatedButton(onPressed: () {}, child: Text("Save Changes")),
          ],
        ),
      ),
    );
  }
}
