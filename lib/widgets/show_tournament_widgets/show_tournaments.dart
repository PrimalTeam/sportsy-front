import 'package:flutter/material.dart';
import 'package:sportsy_front/screens/room_users_screen.dart';
import 'package:sportsy_front/screens/tournament_info.dart';

import 'package:sportsy_front/widgets/app_bar.dart';

class ShowTournaments extends StatelessWidget {
  final dynamic gameDetails;

  const ShowTournaments({super.key, required this.gameDetails});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: gameDetails.name),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                TournamentInfoPage(roomId: gameDetails.id),
                      ),
                    );
                  },
                  child: Text("Tournament Informations"),
                ),

                Text('Game Name: ${gameDetails.name}'),
                Text('Sport Type: ${gameDetails.name}'),
                Text('Is Host: ${gameDetails.role}'),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => RoomUsersScreen(
                              roomId: gameDetails.id,
                              role: gameDetails.role,
                            ),
                      ),
                    );
                  },
                  child: Text("USERS"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
