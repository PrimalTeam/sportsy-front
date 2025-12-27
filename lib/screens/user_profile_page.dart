import 'package:flutter/material.dart';
import 'package:sportsy_front/custom_colors.dart';
import 'package:sportsy_front/dto/user_profile_dto.dart';
import 'package:sportsy_front/features/user_profile/data/user_profile_remote_service.dart';
import 'package:sportsy_front/widgets/app_bar.dart';
import 'package:sportsy_front/core/auth/jwt_storage_service.dart';

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
      appBar: MyAppBar(title: 'Profile: $username'),
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
                'Failed to load profile: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(
              child: Text(
                'Profile data unavailable',
                style: TextStyle(color: Colors.white),
              ),
            );
          }
          final profile = snapshot.data!;
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProfileHeader(profile: profile),
                  const SizedBox(height: 20),
                  _ProfileDetails(profile: profile, formatDate: _formatDate),
                  const SizedBox(height: 24), ElevatedButton(
                          onPressed: () async {
                            await JwtStorageService.clearTokens();
                            if (context.mounted) {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                '/login',
                                (route) => false,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.warning,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Log out'),
                        ),
                      
                    ],
                
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile});

  final UserProfileDto profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.75),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.accent.withOpacity(0.35)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: AppColors.accent.withOpacity(0.25),
            child: Text(
              profile.username.isNotEmpty
                  ? profile.username[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                fontSize: 28,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.username,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  profile.email,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 12),
                Text(
                  'User ID: ${profile.id}',
                  style: const TextStyle(color: Colors.white30, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileDetails extends StatelessWidget {
  const _ProfileDetails({required this.profile, required this.formatDate});

  final UserProfileDto profile;
  final String Function(DateTime) formatDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            _SectionLabel(label: 'Roles'),
            profile.roles.isEmpty
              ? const Text('No roles', style: TextStyle(color: Colors.white70))
              : Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    profile.roles
                        .map(
                          (role) => Chip(
                            label: Text(role),
                            labelStyle: const TextStyle(color: Colors.white),
                            backgroundColor: AppColors.accent.withOpacity(0.35),
                            side: BorderSide(
                              color: AppColors.accent.withOpacity(0.6),
                            ),
                          ),
                        )
                        .toList(),
              ),
          const SizedBox(height: 20),
          _SectionLabel(label: 'Created at'),
          Text(
            formatDate(profile.createdAt),
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 13,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
