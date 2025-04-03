import 'package:flutter/material.dart';
import '../modules/services/jwt_logic.dart';

class ProfileJwtTestScreen extends StatelessWidget {
  const ProfileJwtTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/profile_placeholder.png'),
            ),
            const SizedBox(height: 20),
            const Text(
              'User Name',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            FutureBuilder<String?>(
              future: 
              JwtStorageService.getToken(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return const Text(
                    'Error loading token',
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  );
                } else {
                  final token = snapshot.data ?? 'No Token';
                  return Text(
                    JwtStorageService.getDataFromToken(token, "email") ?? 'No data available',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  );
                }
              },
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Add logout functionality here
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}