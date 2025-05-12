import 'package:flutter/material.dart';
import 'package:sportsy_front/custom_colors.dart';
import 'package:sportsy_front/screens/room_users_page.dart';

Widget buildBottomTabBar(
  BuildContext context,
  TabController tabController,
  int roomId,
  String role,
) {
  return SafeArea(
    child: Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primary,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              spreadRadius: 2,
            ),
          ],
        ),
        child: TabBar(
          controller: tabController,
          indicator: BoxDecoration(),
          labelColor: AppColors.accent,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.info), text: 'INFO'),
            Tab(icon: Icon(Icons.sports_esports), text: 'GAMES'),
            Tab(icon: Icon(Icons.leaderboard), text: 'LEADER'),
            Tab(icon: Icon(Icons.people), text: 'USERS'),
          ],
          onTap: (index) {
            if (index == 3) {
              // Zakładka "USERS"
              // Nawigacja do ekranu RoomUsersPage
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => RoomUsersPage(
                        roomId: roomId, // Przekazanie ID pokoju
                        role: role, // Przekazanie roli użytkownika
                      ),
                ),
              );
            } else {
              // Jeśli kliknięto inną zakładkę, po prostu przełączaj TabBar
              tabController.animateTo(index);
            }
          },
        ),
      ),
    ),
  );
}
