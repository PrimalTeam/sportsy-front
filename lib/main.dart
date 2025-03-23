import 'package:flutter/material.dart';
import 'app_bar.dart';
import 'game_home_widget.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.transparent,
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            letterSpacing: 1.83,
          ),
        ),
      ),
      home: const MyHomePage(title: 'Games list'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppBar(title: 'Games list'),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: 10),
            GameHomeWidget(isHost: true, gameName: 'Game 1', sportType: 'basketball'),
            GameHomeWidget(isHost: false, gameName: 'Game 2', sportType: 'volleyball'),
            GameHomeWidget(isHost: true, gameName: 'Game 3', sportType: 'football'),
            GameHomeWidget(isHost: true, gameName: 'Game 4', sportType: 'test'),
            GameHomeWidget(isHost: true, gameName: 'Game 5', sportType: 'basketball'),
            GameHomeWidget(isHost: false, gameName: 'Game 6', sportType: 'volleyball'),
            GameHomeWidget(isHost: true, gameName: 'Game 7', sportType: 'football'),
            GameHomeWidget(isHost: true, gameName: 'Game 8', sportType: 'test'),
          ],
        ),
      ),
    );
  }
}
