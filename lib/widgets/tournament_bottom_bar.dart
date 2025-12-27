import 'package:flutter/material.dart';
import 'package:sportsy_front/custom_colors.dart';

/// Czysty widget UI — nie zawiera logiki nawigacji.
/// Wysyła tylko sygnał przez callback `onTabSelected`.
Widget buildTournamentBottomBar({
  required BuildContext context,
  required TabController tabController,
  required List<Tab> tabs,
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
          tabs: tabs,
          onTap: onTabSelected, // tylko callback
        ),
      ),
    ),
  );
}
