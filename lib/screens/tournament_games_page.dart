import 'package:flutter/material.dart';
import 'package:sportsy_front/widgets/app_bar.dart';
import 'package:sportsy_front/widgets/show_games.dart';

class TournamentGamesPage extends StatelessWidget{
  const TournamentGamesPage({super.key});
  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: MyAppBar(title: 'Tournament Games'),
    body: ShowGames(),
  );
  }
}