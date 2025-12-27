import 'package:flutter/material.dart';
import 'package:sportsy_front/widgets/app_bar.dart';
import 'package:sportsy_front/widgets/tournament_create_widgets/tournament_form.dart';

class CreateTournamentScreen extends StatefulWidget {
  final VoidCallback fetchRooms;
  const CreateTournamentScreen({super.key, required this.fetchRooms});

  @override
  State<CreateTournamentScreen> createState() => _CreateTournamentScreenState();
}

class _CreateTournamentScreenState extends State<CreateTournamentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: "Create Tournament"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: TournamentForm(fetchRooms: widget.fetchRooms),
      ),
    );
  }
}
