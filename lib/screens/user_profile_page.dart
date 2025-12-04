import 'package:flutter/material.dart';
import 'package:sportsy_front/custom_colors.dart';
import 'package:sportsy_front/dto/user_profile_dto.dart';
import 'package:sportsy_front/features/user_profile/data/user_profile_remote_service.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key, required this.username});
  final String username;

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    return '${local.year.toString().padLeft(4, '0')}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')} ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil: $username'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: AppColors.background,
      body: FutureBuilder<UserProfileDto>(
        future: UserProfileRemoteService.getUserProfile(username),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Błąd pobierania profilu: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(
              child: Text(
                'Brak danych profilu',
                style: TextStyle(color: Colors.white),
              ),
            );
          }
          final profile = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ID: ${profile.id}',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  'Nazwa użytkownika',
                  style: const TextStyle(color: Colors.white54),
                ),
                Text(
                  profile.username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text('Email', style: const TextStyle(color: Colors.white54)),
                Text(
                  profile.email,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text('Role', style: const TextStyle(color: Colors.white54)),
                Text(
                  profile.roles.isEmpty ? 'Brak ról' : profile.roles.join(', '),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  'Utworzono',
                  style: const TextStyle(color: Colors.white54),
                ),
                Text(
                  _formatDate(profile.createdAt),
                  style: const TextStyle(color: Colors.white),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.secondary,
                    ),
                    child: const Text('Zamknij'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
