import 'package:flutter/material.dart';
import 'package:sportsy_front/custom_colors.dart';
import 'package:sportsy_front/dto/get_tournament_dto.dart';

class TournamentOverviewTab extends StatelessWidget {
  const TournamentOverviewTab({super.key, required this.tournament});

  final GetTournamentDto tournament;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Title',
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              tournament.info.title,
              style: TextStyle(fontSize: 18.0, color: AppColors.accent),
            ),
            const SizedBox(height: 24.0),
            Text(
              'Description',
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              tournament.info.description,
              style: TextStyle(fontSize: 18.0, color: AppColors.accent),
            ),
            const SizedBox(height: 24.0),
            Text(
              'Date Start',
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              tournament.info.dateStart.toString(),
              style: TextStyle(fontSize: 18.0, color: AppColors.accent),
            ),
            const SizedBox(height: 24.0),
            Text(
              'Date End',
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              tournament.info.dateEnd.toString(),
              style: TextStyle(fontSize: 18.0, color: AppColors.accent),
            ),
          ],
        ),
      ),
    );
  }
}
