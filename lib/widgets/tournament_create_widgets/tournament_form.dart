import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sportsy_front/modules/tournament_services/creation_team_list.dart';
import 'package:sportsy_front/modules/tournament_services/sport_type_enum.dart';
import 'package:sportsy_front/widgets/tournament_create_widgets/team_add_form.dart';
import 'package:sportsy_front/widgets/tournament_create_widgets/creation_team_added.dart';

class TournamentForm extends StatefulWidget {
  const TournamentForm({super.key});

  @override
  State<TournamentForm> createState() => _TournamentFormState();
}

class _TournamentFormState extends State<TournamentForm> {
  DateTime? _selectedDateTime;
  List<Team> teams = [];
  bool showTeamAdd = false;
  final picker = ImagePicker();

  void _pickDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      helpText: 'Select tournament date',
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void addNewTeam() {
    setState(() {
      showTeamAdd = true;
    });
  }

  void teamAdded(String name, File? logo) {
    setState(() {
      showTeamAdd = false;
      teams.add(Team(name: name, logo: logo));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("Title"),
        TextField(
          decoration: const InputDecoration(hintText: 'Enter tournament title'),
        ),
        const Text("Sport type"),
        DropdownMenu<SportType>(
          expandedInsets: EdgeInsets.zero,
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
        const Text("Description"),
        TextField(
          decoration: const InputDecoration(
            hintText: 'Enter tournament description',
          ),
        ),
        const Text("Start date and time"),
        TextField(
          readOnly: true,
          onTap: _pickDateTime,
          decoration: InputDecoration(
            hintText:
                _selectedDateTime == null
                    ? 'Enter tournament start date and time'
                    : '${_selectedDateTime!.toLocal()}'.split('.')[0],
          ),
        ),
        const Text("End date and time"),
        TextField(
          readOnly: true,
          onTap: _pickDateTime,
          decoration: InputDecoration(
            hintText:
                _selectedDateTime == null
                    ? 'Enter tournament end date and time'
                    : '${_selectedDateTime!.toLocal()}'.split('.')[0],
          ),
        ),
        const Text("Dodaj drużyny"),
        IconButton(onPressed: addNewTeam, icon: const Icon(Icons.add)),
        if (showTeamAdd) TeamAddForm(onTeamAdded: teamAdded),
        CreationTeamAdded(teams: teams),
        ElevatedButton(
          onPressed: () {
            print("Tournament created with teams: $teams");
          },
          child: const Text("Create Tournament"),
        ),
      ],
    );
  }
}
