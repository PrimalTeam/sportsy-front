import 'package:flutter/material.dart';
import 'package:sportsy_front/dto/team_add_dto.dart';

class CreationTeamAdded extends StatefulWidget {
  final List<TeamAddDto> teams;
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
          leading: Image.memory(
            team.icon,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
          ),
          title: Text(team.name, style: TextStyle(color: Colors.white)),
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
