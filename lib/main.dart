import 'package:flutter/material.dart';
import 'package:sportsy_front/modules/tournament_services/tournament_info_struct.dart';
import 'package:sportsy_front/screens/tournament_info.dart';
import 'screens/games_list_page.dart';
import 'screens/login_screen.dart';
import 'screens/create_tournament_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(100)),
          filled: true,
          fillColor:  Color(0xff283963),
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          hintStyle: TextStyle(color: Colors.grey[300]),
          labelStyle: TextStyle(color: Colors.white),

          
        ),
        dropdownMenuTheme: const DropdownMenuThemeData(
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(100))),
            filled: true,
            fillColor: Color(0xff283963),
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            labelStyle: TextStyle(color: Colors.white),
            constraints: BoxConstraints(minWidth: double.infinity),
          ),
        ),
      ),
      
      title: 'Flutter Demo',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      initialRoute: '/infoPage',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/infoPage': (context) => TournamentInfoPage(tournamentDetails: TournamentInfo(title: "Tytuł", description: "Opis", dateEnd: DateTime.now(),  dateStart: DateTime.now()) ,),
        '/home': (context) => const MyHomePage(title: "Title"),
        '/ctournament': (context) => const CreateTournamentPage(),
      },
    );
  }
}
