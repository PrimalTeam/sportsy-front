import 'package:sportsy_front/modules/tournament_services/sport_type_enum.dart';
import 'package:sportsy_front/modules/tournament_services/tournament_info_struct.dart';
import 'package:sportsy_front/modules/tournament_services/creation_team_list.dart';
class Tournament{
  final SportType sportType;
  final TournamentInfo tournamentInfo;
  final List<Team> teams;
  Tournament({
    required this.sportType,
    required this.tournamentInfo,
    required this.teams,
  });
}