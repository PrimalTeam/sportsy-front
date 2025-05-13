import 'package:flutter/material.dart';
import '../modules/services/jwt_logic.dart';
import 'login_screen.dart';
import 'games_list_page.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  Future<void> _checkAuthentication(BuildContext context) async {
    final token = await JwtStorageService.getToken();
    final refreshToken = await JwtStorageService.getRefreshToken();

    if (token != null && refreshToken != null && !JwtDecoder.isExpired(token)) {
      // Tokeny są ważne, przekieruj na ekran główny
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyHomePage(title: "Welcome")),
      );
    } else {
      // Tokeny są nieważne lub nie istnieją, przekieruj na ekran logowania
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _checkAuthentication(context); // Sprawdź tokeny podczas budowania ekranu

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Animacja ładowania
      ),
    );
  }
}