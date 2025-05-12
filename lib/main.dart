import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sportsy_front/custom_colors.dart';
import 'package:sportsy_front/modules/tournament_services/tournament_info_struct.dart';
import 'package:sportsy_front/screens/home_page.dart';
import 'package:sportsy_front/screens/tournament_games_page.dart';
import 'package:sportsy_front/screens/tournament_info.dart';
import 'screens/games_list_page.dart';
import 'screens/login_screen.dart';
import 'screens/create_tournament_page.dart';

import 'screens/team_page.dart';
import 'screens/team_user.dart';
import 'screens/team_status.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          iconTheme: IconThemeData(color: AppColors.accent),
        ),

        iconTheme: IconThemeData(color: AppColors.accent),
        scaffoldBackgroundColor: const Color.fromARGB(255, 0, 0, 0),

        textTheme: GoogleFonts.poppinsTextTheme().apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          prefixIconColor: AppColors.accent,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(100)),
          filled: true,
          fillColor: AppColors.primary,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 15,
          ),
          hintStyle: GoogleFonts.poppins(color: Colors.white54),
          labelStyle: GoogleFonts.poppins(color: Colors.white),
        ),

        dropdownMenuTheme: DropdownMenuThemeData(
          textStyle: TextStyle(backgroundColor: Colors.amber),
          inputDecorationTheme: InputDecorationTheme(
            constraints: const BoxConstraints(minHeight: 48, maxHeight: 48),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 5,
              horizontal: 10,
            ),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(100)),
            ),

            filled: true,
            fillColor: AppColors.primary,
            hintStyle: GoogleFonts.poppins(color: Colors.white54),
            labelStyle: GoogleFonts.poppins(color: Colors.white),
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
              side: const BorderSide(color: AppColors.accent, width: 2),
            ),
          ),
        ),
      ),
      routes: {
        '/tournamentgames': (context) => const TournamentGamesPage(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const MyHomePage(title: "Title"),
        '/ctournament': (context) => const CreateTournamentPage(),
        '/homepage': (context) => const HomePage(),
        '/teampage': (context) => const TeamPage(),
        '/teamuser': (context) => const TeamUser(),
        '/teamstatus': (context) => const TeamStatus(),
      },
    );
  }
}
