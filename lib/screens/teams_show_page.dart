import 'package:flutter/material.dart';
import 'package:sportsy_front/dto/get_teams_dto.dart';
import 'package:sportsy_front/modules/services/auth.dart';
import 'package:sportsy_front/widgets/app_bar.dart';


class TeamsShowPage extends StatefulWidget {
  const TeamsShowPage({super.key, required this.roomId});
  final int roomId;

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
      final List<GetTeamsDto> teams = await AuthService.getTeamsOfTournament(widget.roomId);
      if (!mounted) return;
      setState(() {
        _teams = teams;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching teams: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _teams.isEmpty
                ? const Center(child: Text('No teams available'))
                : ListView.builder(
                    itemCount: _teams.length,
                    itemBuilder: (context, index) {
                      final team = _teams[index];
                      final bytes = team.icon?.data;
                      final hasImage = bytes != null && bytes.isNotEmpty;

                      Widget leading;
                      if (hasImage) {
                        leading = ClipOval(
                          child: Image.memory(
                            bytes!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const CircleAvatar(child: Icon(Icons.broken_image)),
                          ),
                        );
                      } else {
                        leading = const CircleAvatar(child: Icon(Icons.group));
                      }

                      return ListTile(
                        leading: leading,
                        title: Text(team.name),
                        subtitle: Text('Tournament ID: ${team.tournamentId}'),
                      );
                    },
                  ),
      ),
    );
  }
}
// ...existing code...