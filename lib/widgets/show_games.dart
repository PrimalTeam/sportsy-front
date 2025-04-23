import 'package:flutter/material.dart';
import 'package:sportsy_front/custom_colors.dart';
import 'package:sportsy_front/modules/tournament_services/creation_team_list.dart';
import 'package:sportsy_front/modules/tournament_services/teams_temporary.dart';

class ShowGames extends StatefulWidget {
  ShowGames({super.key});
  final List<Team> teamsList = teamsTemporary();

  @override
  State<ShowGames> createState() => _ShowGamesState();
}

class _ShowGamesState extends State<ShowGames> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.teamsList.length,
        itemBuilder: (context, index) {
          final team = widget.teamsList[index];
          return _buildGameCard(team);
        },
      ),
    );
  }

  Widget _buildGameCard(Team team) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildTeamLogo(),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${team.name} vs ${team.name}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                shadows: [
                  Shadow(
                    offset: Offset(1.5, 1.5),
                    blurRadius: 3.0,
                    color: Colors.black38,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          _buildTeamLogo(),
        ],
      ),
    );
  }

  Widget _buildTeamLogo() {
    return SizedBox(
      width: 40,
      height: 40,
      child: Image.asset('lib/assets/logo.png'),
    );
  }
}
