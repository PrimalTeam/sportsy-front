import 'package:flutter/material.dart';

import 'package:sportsy_front/widgets/app_bar.dart';



class GamePage extends StatelessWidget {
  final dynamic gameDetails; // Accept game details as an argument

  const GamePage({super.key, required this.gameDetails});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: MyAppBar(title: gameDetails.gameName), // Use game name as title
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Game Name: ${gameDetails.gameName}'),
            Text('Sport Type: ${gameDetails.sportType}'),
            Text('Is Host: ${gameDetails.isHost}'),
          ],
        ),
      ),
    );
  }
}