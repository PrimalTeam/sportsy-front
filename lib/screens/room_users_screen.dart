import 'package:flutter/material.dart';
import 'package:sportsy_front/custom_colors.dart';
import 'package:sportsy_front/widgets/room_users/add_user_to_room_widget.dart';
import 'package:sportsy_front/widgets/room_users/room_users_list.dart';

class RoomUsersScreen extends StatelessWidget {
  final GlobalKey<RoomUsersListState> roomUsersListKey =
      GlobalKey<RoomUsersListState>();
  RoomUsersScreen({super.key, required this.roomId, required this.role});
  final String role;
  final int roomId;

  bool get _isAdmin => role.toLowerCase() == 'admin';
  bool get _isSpectator => role.toLowerCase() == 'spectrator';
  bool get _canManage => _isAdmin || _isSpectator;

  void _triggerUserRefresh() {
    roomUsersListKey.currentState?.refreshUsers(); // wywołanie metody dziecka
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              "Users in room",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: RoomUsersList(
              roomId: roomId,
              key: roomUsersListKey,
              currentUserRole: role,
            ),
          ),
          if (_canManage)
            Center(
              child: ElevatedButton(
                onPressed: () {
                  addUserToRoomWidget(
                    context: context,
                    roomId: roomId,
                    currentUserRole: role,
                    onUserAdded: _triggerUserRefresh,
                  );
                },
                child: Text("Add new Users"),
              ),
            ),
        ],
      ),
    );
  }
}
