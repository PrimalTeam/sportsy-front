import 'package:flutter/material.dart';
import 'package:sportsy_front/core/auth/jwt_storage_service.dart';
import 'package:sportsy_front/screens/login_screen.dart';
import 'package:sportsy_front/screens/tournaments_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late Future<bool> _isAuthenticated;

  @override
  void initState() {
    super.initState();
    _isAuthenticated = _checkExistingSession();
  }

  Future<bool> _checkExistingSession() async {
    final missingOrExpired = await JwtStorageService.isTokenMissingOrExpired();
    return !missingOrExpired;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isAuthenticated,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const LoginScreen();
        }

        final bool hasSession = snapshot.data ?? false;
        if (hasSession) {
          return const MyHomePage(title: 'Sportsy');
        }

        return const LoginScreen();
      },
    );
  }
}
