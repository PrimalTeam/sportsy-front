import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sportsy_front/widgets/tournament_create_widgets/team_add_form.dart';

Future<void> customMainBottomModalWindow({
  required BuildContext context,
  required Widget container,
  bool isScrollControlled = true,
  required Function(String name, File? logo) teamAdded,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: Color.fromARGB(255, 34, 34, 34),

    builder:
        (context) => Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Color.fromARGB(255, 212, 175, 55),
                width: 4,
                style: BorderStyle.solid,
              ),
              left: BorderSide(
                color: Color.fromARGB(255, 212, 175, 55),
                width: 4,
                style: BorderStyle.solid,
              ),
              right: BorderSide(
                color: Color.fromARGB(255, 212, 175, 55),
                width: 4,
                style: BorderStyle.solid,
              ),
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,

            children: [
              SizedBox(height: 20),
              TeamAddForm(onTeamAdded: teamAdded),
              SizedBox(height: 20),
            ],
          ),
        ),
  );
}
