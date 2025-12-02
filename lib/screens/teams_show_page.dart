import 'package:flutter/material.dart';
import 'package:sportsy_front/dto/get_teams_dto.dart';
import 'package:sportsy_front/dto/room_info_dto.dart';
import 'package:sportsy_front/modules/services/auth.dart';
import 'package:sportsy_front/screens/team_edit_page.dart';
// import 'package:sportsy_front/widgets/app_bar.dart'; // not used here currently

class TeamsShowPage extends StatefulWidget {
  const TeamsShowPage({super.key, required this.roomId});
  final int roomId;

  @override
  TeamsShowPageState createState() => TeamsShowPageState();
}

class TeamsShowPageState extends State<TeamsShowPage> {
  List<GetTeamsDto> _teams = [];
  RoomInfoDto? _roomInfo; // reserved for potential future UI meta usage
  bool _isLoading = true;
  bool _error = false;

  final Color amber = const Color(0xFFFFC107);
  final Color black = Colors.black;


  @override
  void initState() {
    super.initState();
    _loadRoomAndTeams();
  }

  Future<void> _loadRoomAndTeams() async {
    try {
      final room = await AuthService.getRoomInfo(widget.roomId);
      final tournamentId = room.tournament?.id;
      List<GetTeamsDto> teams = [];
      if (tournamentId != null) {
        teams = await AuthService.getTeamsOfTournament(tournamentId);
      }
      if (!mounted) return;
      setState(() {
        _roomInfo = room;
        _teams = teams;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading room/teams: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = true;
      });
    }
  }

  // Public method to allow external refresh (e.g. after adding a team)
  Future<void> reloadTeams() async {
    await _loadRoomAndTeams();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error
                ? Center(
                    child: Text(
                      'Failed to load teams',
                      style: TextStyle(color: amber, fontWeight: FontWeight.bold),
                    ),
                  )
                : _teams.isEmpty
                ? Center(
                  child: Text(
                    'No teams available',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: amber,
                    ),
                  ),
                )
                : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: _teams.length,
                  itemBuilder: (context, index) {
                    final team = _teams[index];
                    final bytes = team.icon?.data;
                    final hasImage = bytes != null && bytes.isNotEmpty;
                    final Widget leading = hasImage
                        ? ClipOval(
                            child: Image.memory(
                              bytes,
                              width: 52,
                              height: 52,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => CircleAvatar(
                                radius: 26,
                                backgroundColor: black,
                                child: Icon(Icons.broken_image, color: amber),
                              ),
                            ),
                          )
                        : CircleAvatar(
                            radius: 26,
                            backgroundColor: black,
                            child: Icon(Icons.group, color: amber),
                          );

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: black.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: amber, width: 1.4),
                        boxShadow: [
                          BoxShadow(
                            color: amber.withOpacity(0.25),
                            blurRadius: 6,
                            spreadRadius: 1,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: leading,
                        title: Text(
                          team.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: amber,
                          ),
                        ),
                        onTap: () async {
                          final changed = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => TeamEditPage(
                                roomId: widget.roomId,
                                team: team,
                              ),
                            ),
                          );
                          if (changed == true) {
                            _loadRoomAndTeams();
                          }
                        },
        
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
