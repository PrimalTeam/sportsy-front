import 'package:flutter/material.dart';
import 'package:sportsy_front/custom_colors.dart';

/// Czysty widget UI — nie zawiera logiki nawigacji.
/// Wysyła tylko sygnał przez callback `onTabSelected`.
Widget buildTournamentBottomBar({
  required BuildContext context,
  required TabController tabController,
  required ValueChanged<int> onTabSelected,
}) {
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
          indicator: const BoxDecoration(),
          labelColor: AppColors.accent,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.info), text: 'INFO'),
            Tab(icon: Icon(Icons.sports_esports), text: 'GAMES'),
            Tab(icon: Icon(Icons.groups), text: 'TEAMS'),
            Tab(icon: Icon(Icons.people), text: 'USERS'),
            Tab(icon: Icon(Icons.leaderboard), text: 'LEADER'),
          ],
          onTap: onTabSelected, // tylko callback
        ),
      ),
    ),
  );
}
