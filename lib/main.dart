import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      title: 'Flutter Demo',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      initialRoute: '/ctournament',
      theme: ThemeData(
        

        iconTheme: IconThemeData(
          color: Color.fromARGB(255, 212, 175, 55),
        ),
        scaffoldBackgroundColor: const Color.fromARGB(255, 0,0,0,),

        textTheme: GoogleFonts.poppinsTextTheme().apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          prefixIconColor: Color.fromARGB(255, 212, 175, 55),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(100)),
          filled: true,
          fillColor: Color.fromARGB(255, 34, 34, 34),
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
            fillColor: Color.fromARGB(255, 34, 34, 34),
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
            backgroundColor: Color.fromARGB(255, 34, 34, 34),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
              side: const BorderSide(
                color: Color.fromARGB(255, 212, 175, 55),
                width: 2,
              ),
            ),
          ),
        ),
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const MyHomePage(title: "Title"),
        '/ctournament': (context) => const CreateTournamentPage(),
      },
    );
  }
}
