import 'package:flutter/material.dart';
import 'package:sportsy_front/dto/get_room_dto.dart';
import 'package:sportsy_front/modules/services/auth.dart';
import 'package:sportsy_front/screens/create_tournament_page.dart';
import '../widgets/app_bar.dart';
import '../widgets/game_home_widget.dart';
import '../widgets/bottom_bar.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 1; // Domyślnie aktywna zakładka

  @override
  void initState() {
    super.initState();
    fetchRooms();
  }

  String searchQuery = '';

  void onSearchChanged(String value) {
    setState(() {
      searchQuery = value;
    });
  }

  List<GetRoomDto> roomsList = [];
  void fetchRooms() async {
    try {
      final rooms = await AuthService.getRooms();
      setState(() {
        roomsList = rooms;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        Navigator.pushNamed(context, '/homepage');
      } else if (index == 1) {
        Navigator.pushNamed(context, '/tournamentgames');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredGames =
        roomsList.where((game) {
          return game.name.toLowerCase().contains(searchQuery.toLowerCase());
        }).toList();

    return Scaffold(
      appBar: MyAppBar(title: 'Games list'),
      body: ListView.builder(
        itemCount: filteredGames.length,
        itemBuilder: (context, index) {
          return GameHomeWidget(gameDetails: filteredGames[index]);
        },
      ),
      bottomNavigationBar: BottomBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(onPressed: (){
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => CreateTournamentPage(),));
      },child: Icon(Icons.add), 
      ),

    );
  }
}
