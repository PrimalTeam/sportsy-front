import 'package:flutter/material.dart';
import 'package:sportsy_front/dto/get_room_dto.dart';
import 'package:sportsy_front/modules/services/auth.dart';
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


  @override
  Widget build(BuildContext context) {
    final filteredGames = roomsList.where((game) {
      return game.name.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: MyAppBar(
        title: 'Games list',
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