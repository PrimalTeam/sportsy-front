import 'package:dartz/dartz_unsafe.dart';
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
    return 
    
    Column(
      children: [
        for(var team in widget.teamsList)
        Container(
          height: 100,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            
            children: [
              Expanded(child: Image(image: AssetImage('lib/assets/logo.png'),)),
              Text('${team.name} vs ${team.name}',),
        
              Expanded(child: Image(image: AssetImage('lib/assets/logo.png'),)),
            
            ],
          ),
        ),
      ],
    );
  }
}