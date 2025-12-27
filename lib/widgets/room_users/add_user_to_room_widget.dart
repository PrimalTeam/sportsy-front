import 'package:flutter/material.dart';
import 'package:sportsy_front/custom_colors.dart';
import 'package:sportsy_front/dto/add_user_to_room_dto.dart';
import 'package:sportsy_front/dto/room_user_role_enum.dart';
import 'package:sportsy_front/features/room_users/data/room_users_remote_service.dart';

Future<void> addUserToRoomWidget({
  required BuildContext context,
  required int roomId,
  required String currentUserRole,
  required VoidCallback onUserAdded,
}) {
  final TextEditingController emailTextController = TextEditingController();
  final availableRoles = _availableRolesFor(currentUserRole);
  if (availableRoles.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You do not have permission to add users.')),
    );
    return Future.value();
  }
  String selectedRole = availableRoles.first.name;
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
                      ...availableRoles.map(
                        (role) => RadioListTile(
                          title: Text(
                            'Role ${role.displayName}',
                            style: const TextStyle(color: Colors.white),
                          ),
                          value: role.name,
                          groupValue: selectedRole,
                          onChanged: (value) {
                            setState(() {
                              selectedRole = value!;
                            });
                          },
                        ),
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

List<RoomUserRoleEnum> _availableRolesFor(String currentRole) {
  final normalized = currentRole.toLowerCase();
  if (normalized == 'admin') {
    return const [
      RoomUserRoleEnum.spectrator,
      RoomUserRoleEnum.gameObserver,
      RoomUserRoleEnum.admin,
    ];
  }
  if (normalized == 'spectrator') {
    return const [RoomUserRoleEnum.gameObserver];
  }
  return const [];
}
