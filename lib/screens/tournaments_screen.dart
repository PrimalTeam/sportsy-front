import 'package:flutter/material.dart';
import 'package:sportsy_front/dto/get_room_dto.dart';
import 'package:sportsy_front/modules/services/auth.dart';
import 'package:sportsy_front/screens/create_tournament_screen.dart';
import '../widgets/app_bar.dart';
import '../widgets/game_home_widget.dart';
import '../widgets/bottom_bar_home.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 1;

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
 Future<void> fetchRooms() async { // zmieniono: Future<void>
    try {
      final rooms = await AuthService.getRooms();
      if (!mounted) return;
      setState(() {
        // nowa instancja listy, żeby na pewno zainicjować rebuild
        roomsList = List<GetRoomDto>.from(rooms);
      });
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
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
      bottomNavigationBar: BottomBarHome(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(onPressed: (){
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => CreateTournamentScreen(fetchRooms: fetchRooms),));
      },child: Icon(Icons.add), 
      ),

    );
  }
}
