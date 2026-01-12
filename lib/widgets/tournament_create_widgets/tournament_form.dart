import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sportsy_front/dto/create_room_dto.dart';
import 'package:sportsy_front/dto/team_add_dto.dart';
import 'package:sportsy_front/dto/tournament_dto.dart' show TournamentDto, InfoDto, GamesDto, InternalConfigDto;
import 'package:sportsy_front/features/rooms/data/rooms_remote_service.dart';
import 'package:sportsy_front/modules/tournament_services/sport_type_enum.dart';
import 'package:sportsy_front/widgets/custom_main_bottom_modal_window.dart';
import 'package:sportsy_front/widgets/tournament_create_widgets/creation_team_added.dart';

/// Available ladder/bracket types
enum LadderType {
  singleElimination('single-elimination', 'Single Elimination'),
  doubleElimination('double-elimination', 'Double Elimination'),
  roundRobin('round-robin', 'Round Robin');

  const LadderType(this.value, this.displayName);
  final String value;
  final String displayName;
}

class TournamentForm extends StatefulWidget {
  final VoidCallback fetchRooms;
  const TournamentForm({super.key, required this.fetchRooms});

  @override
  State<TournamentForm> createState() => _TournamentFormState();
}

class _TournamentFormState extends State<TournamentForm> {
  final tournamentTitleController = TextEditingController();
  final tournamentSportTypeController = TextEditingController();
  final tournamentDescriptionController = TextEditingController();
  String tournamentEndDateController = "";
  List<GamesDto> games = [GamesDto("PENDING")];
  LadderType _selectedLadderType = LadderType.singleElimination;

  void createTournamentClickAction() async {
    if (tournamentTitleController.text != "") {
      final roomDto = CreateRoomDto(
        tournamentTitleController.text,
        TournamentDto(
          InfoDto(
            DateTime.parse(tournamentEndDateController),
            tournamentDescriptionController.text,
            tournamentTitleController.text,
          ),
          _selectedLadderType.value,
          tournamentSportTypeController.text,
          [],
          teams,
          internalConfig: InternalConfigDto(autogenerateGamesFromLadder: true),
        ),
      );

      try {
        print("Generated JSON: ${jsonEncode(roomDto.toJson())}");
        print("Generated JSON: ${roomDto.toJson()}");
        await RoomsRemoteService.createRoom(roomDto);
        print("Tournament Created!");
        Navigator.pop(context, true);
      } catch (e) {
        print("An error occurred while creating the tournament: $e");
      }
    } else {
      _showMyDialog();
    }
    widget.fetchRooms();
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Please set tournament title!'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('This is a demo alert dialog.'),
                Text('Would you like to approve of this message?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Approve'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  DateTime? _selectedDateTimeStart;
  DateTime? _selectedDateTimeEnd;

  List<TeamAddDto> teams = [];
  final picker = ImagePicker();

  Future<DateTime?> _pickDateTime(DateTime? initialDateTime) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      helpText: 'Select tournament date',
      initialDate: initialDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
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

  void teamAdded(String name, File? logo) async {
    if (logo != null) {
      final Uint8List imageBytes = await logo.readAsBytes();
      setState(() {
        teams.add(TeamAddDto(name, imageBytes));
      });
    }
  }

  String _formatDate(DateTime date) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${date.year}.${twoDigits(date.month)}.${twoDigits(date.day)} ${twoDigits(date.hour)}:${twoDigits(date.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
        DropdownMenu<SportType>(
          controller: tournamentSportTypeController,
          expandedInsets: EdgeInsets.zero,
          leadingIcon: const Icon(Icons.sports),
          label: Text("Sport type", style: TextStyle(color: Colors.grey)),
          dropdownMenuEntries:
              SportType.values
                  .map(
                    (sport) => DropdownMenuEntry<SportType>(
                      value: sport,
                      label: sport.name,
                    ),
                  )
                  .toList(),
          onSelected: (SportType? selectedSport) {
            print("Selected sport type: $selectedSport");
          },
        ),

        SizedBox(height: 15),

        // Ladder/Bracket type dropdown
        DropdownMenu<LadderType>(
          expandedInsets: EdgeInsets.zero,
          leadingIcon: const Icon(Icons.account_tree),
          initialSelection: _selectedLadderType,
          label: Text("Bracket format", style: TextStyle(color: Colors.grey)),
          dropdownMenuEntries:
              LadderType.values
                  .map(
                    (ladder) => DropdownMenuEntry<LadderType>(
                      value: ladder,
                      label: ladder.displayName,
                    ),
                  )
                  .toList(),
          onSelected: (LadderType? selectedLadder) {
            if (selectedLadder != null) {
              setState(() {
                _selectedLadderType = selectedLadder;
              });
            }
          },
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

        ElevatedButton(
          onPressed: () {
            customMainBottomModalWindow(
              teamAdded: teamAdded,
              context: context,
              container: Container(),
            );
          },
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [Icon(Icons.add), Text("Add team")],
          ),
        ),
        CreationTeamAdded(teams: teams),
        ElevatedButton(
          onPressed: createTournamentClickAction,
          child: const Text("Create Tournament"),
        ),
      ],
    );
  }
}
