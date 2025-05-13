import 'package:flutter/material.dart';
import 'package:sportsy_front/widgets/app_bar.dart';
import '../modules/services/jwt_logic.dart';
import '../modules/services/auth.dart';

class ProfileJwtTestScreen extends StatelessWidget {
  const ProfileJwtTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: 'Profile',
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
              onPressed: () async {
                try {
                  final response = await AuthService.test(); 
                  final profileData = response.data;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Profile: ${profileData.toString()}')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error fetching profile: $e')),
                  );
                }
              },
              child: const Text('Fetch Profile'),
            ),
          ],
        ),
      ),
    );
  }
}