import 'package:flutter/material.dart';
import '../widgets/app_bar.dart';
import '../widgets/game_home_widget.dart';
import '../modules/game_list_data.dart';


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredGames = gameData.where((game) {
      return game.gameName.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: MyAppBar(
        title: 'Games list',
        onSearchChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
      ),
      body: ListView.builder(
        itemCount: filteredGames.length,
        itemBuilder: (context, index) {
          return GameHomeWidget(gameDetails: filteredGames[index]);
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue,
        items: const [
        
        BottomNavigationBarItem(
          icon: Icon(Icons.home_filled),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.sports_soccer),
          label: 'Games',
        ),
      ]),
      );
  }
}