import 'package:flutter/material.dart';
import 'package:sportsy_front/widgets/app_bar.dart';
import 'package:sportsy_front/widgets/show_games.dart';
import '../widgets/bottom_bar.dart';

class TournamentGamesPage extends StatefulWidget {
  const TournamentGamesPage({super.key});

  @override
  State<TournamentGamesPage> createState() => _TournamentGamesPageState();
}

class _TournamentGamesPageState extends State<TournamentGamesPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: 'Tournament Games'),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: ShowGames()),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/gamepage');
            },
            child: const Text('Game'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/teampage');
            },
            child: const Text('Team'),
          ),
          const SizedBox(height: 20),
        ],
      ),
      bottomNavigationBar: BottomBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
