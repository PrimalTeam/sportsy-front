import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sportsy_front/dto/create_room_dto.dart';
import 'package:sportsy_front/modules/services/auth.dart';
import 'package:sportsy_front/modules/tournament_services/creation_team_list.dart';
import 'package:sportsy_front/modules/tournament_services/sport_type_enum.dart';
import 'package:sportsy_front/widgets/custom_main_bottom_modal_window.dart';
import 'package:sportsy_front/widgets/tournament_create_widgets/creation_team_added.dart';

class TournamentForm extends StatefulWidget {
  const TournamentForm({super.key});

  @override
  State<TournamentForm> createState() => _TournamentFormState();
}






class _TournamentFormState extends State<TournamentForm> {
final tournamentTitleController = TextEditingController();
void createTournamentClickAction() async {


  if(tournamentTitleController.text!=""){
  final roomDto = CreateRoomDto(tournamentTitleController.text);
try{
  await AuthService.createRoom(roomDto);
    print("Tournament Created!");
    Navigator.pop(context);
  }
  catch (e) {
    print("An error occurred while creating the tournament: $e");
  }

  }
  else{
    
   _showMyDialog();
  }

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

  List<Team> teams = [];
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

  void teamAdded(String name, File? logo) {
    setState(() {
      teams.add(Team(name: name, logo: logo));
    });
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

        TextField(
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
