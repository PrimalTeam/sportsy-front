import 'package:flutter/material.dart';
import 'package:sportsy_front/modules/tournament_services/creation_team_list.dart';
class CreationTeamAdded extends StatefulWidget {
  final List<Team> teams;
  const CreationTeamAdded({super.key, required this.teams});
@override
State<CreationTeamAdded> createState() => _CreationTeamAddedState();
}
class _CreationTeamAddedState extends State<CreationTeamAdded> {


@override
 Widget build(BuildContext context) {
 return ListView.builder(
      shrinkWrap: true,
      itemCount: widget.teams.length,
      itemBuilder: (context, index) {
        final team = widget.teams[index];
        return ListTile(
          leading: team.logo != null
              ? Image.file(team.logo!, width: 40, height: 40, fit: BoxFit.cover)
              : Icon(Icons.group),
          title: Text(team.name),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              setState(() {
                widget.teams.removeAt(index);
              });
              (context as Element).markNeedsBuild();
            },
          ),
        );
      },
    );
  }
}