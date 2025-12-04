import 'package:flutter/material.dart';
import 'package:sportsy_front/custom_colors.dart';
import 'package:sportsy_front/dto/add_user_to_room_dto.dart';
import 'package:sportsy_front/dto/room_user_role_enum.dart';
import 'package:sportsy_front/features/room_users/data/room_users_remote_service.dart';

Future<void> addUserToRoomWidget({
  required BuildContext context,
  required int roomId,
  required VoidCallback onUserAdded,
}) {
  final TextEditingController emailTextController = TextEditingController();
  String selectedRole = "";
  void addUserToRoom() async {
    await RoomUsersRemoteService.addUserToRoom(
      roomId,
      AddUserToRoomDto(
        role: selectedRole,
        identifier: emailTextController.text,
        identifierType: 'email',
      ),
    ).then((_) {
      onUserAdded();
    });
    Navigator.pop(context);
  }

  return showModalBottomSheet(
    context: context,

    backgroundColor: AppColors.primary,
    builder:
        (context) => StatefulBuilder(
          builder:
              (context, setState) => Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: AppColors.accent,
                      width: 4,
                      style: BorderStyle.solid,
                    ),
                    left: BorderSide(
                      color: AppColors.accent,
                      width: 4,
                      style: BorderStyle.solid,
                    ),
                    right: BorderSide(
                      color: AppColors.accent,
                      width: 4,
                      style: BorderStyle.solid,
                    ),
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),

                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,

                    children: [
                      SizedBox(height: 20),
                      Center(child: Text("Type user Email")),
                      SizedBox(height: 10),

                      TextField(controller: emailTextController),
                      SizedBox(height: 10),
                      RadioListTile(
                        title: const Text(
                          "Role Spectator",
                          style: TextStyle(color: Colors.white),
                        ),
                        value:
                            RoomUserRoleEnum
                                .spectrator
                                .name, // Wartość dla tego przycisku
                        groupValue: selectedRole, // Aktualnie wybrana wartość
                        onChanged: (value) {
                          setState(() {
                            selectedRole =
                                value!; // Aktualizacja wybranej wartości
                          });
                        },
                      ),
                      RadioListTile(
                        title: const Text(
                          "Role Game Observer",
                          style: TextStyle(color: Colors.white),
                        ),
                        value:
                            RoomUserRoleEnum
                                .gameObserver
                                .name, // Wartość dla tego przycisku
                        groupValue: selectedRole, // Aktualnie wybrana wartość
                        onChanged: (value) {
                          setState(() {
                            selectedRole =
                                value!; // Aktualizacja wybranej wartości
                          });
                        },
                      ),
                      SizedBox(height: 10),

                      ElevatedButton(
                        onPressed: addUserToRoom,
                        child: Text("Add User to the Room"),
                      ),

                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
        ),
  );
}
