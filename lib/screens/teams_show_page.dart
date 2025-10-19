import 'package:flutter/material.dart';
import 'package:sportsy_front/dto/get_teams_dto.dart';
import 'package:sportsy_front/modules/services/auth.dart';
import 'package:sportsy_front/widgets/app_bar.dart';

class TeamsShowPage extends StatefulWidget {
  const TeamsShowPage({super.key});

  @override
  TeamsShowPageState createState() => TeamsShowPageState();
}

class TeamsShowPageState extends State<TeamsShowPage> {
  List<GetTeamsDto> _teams = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTeams();
  }
Future<void> _fetchTeams() async {
  try {
    final List<GetTeamsDto> teams = await AuthService.getTeamsOfTournament(30);
    setState(() {
      _teams = teams;
      _isLoading = false;
    });
  } catch (e) {
    print('Error fetching teams: $e');
    setState(() {
      _isLoading = false;
    });
  }
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const MyAppBar(title: "Teams"),
    ),
    body: SizedBox.expand(
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _teams.isEmpty
              ? const Center(child: Text('No teams available'))
              : ListView.builder(
                  itemCount: _teams.length,
                  itemBuilder: (context, index) {
                    final team = _teams[index];
                    return ListTile(
                      leading: team.icon.isNotEmpty
                          ? Image.memory(
                              team.icon,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.group),
                      title: Text(team.name),
                      subtitle: Text('Tournament ID: ${team.tournamentId}'),
                    );
                  },
                ),
    ),
  );
}
}