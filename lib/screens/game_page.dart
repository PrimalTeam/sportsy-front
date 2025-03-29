import 'package:flutter/material.dart';

class GamePage extends StatelessWidget {
  final dynamic gameDetails; // Accept game details as an argument

  const GamePage({super.key, required this.gameDetails});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(), // Use game name as title
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