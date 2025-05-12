import 'package:flutter/material.dart';
import 'package:sportsy_front/modules/tournament_services/tournament_info_struct.dart';
import 'package:sportsy_front/screens/room_users_page.dart';
import 'package:sportsy_front/screens/tournament_info.dart';

import 'package:sportsy_front/widgets/app_bar.dart';

class GamePage extends StatelessWidget {
  final dynamic gameDetails;

  const GamePage({super.key, required this.gameDetails});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: gameDetails.name),
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
                            (context) => RoomUsersPage(
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
