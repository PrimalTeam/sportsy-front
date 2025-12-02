import 'package:flutter/material.dart';
import 'package:sportsy_front/widgets/room_users/add_user_to_room_widget.dart';
import 'package:sportsy_front/widgets/room_users/room_users_list.dart';

class RoomUsersScreen extends StatelessWidget {
  final GlobalKey<RoomUsersListState> roomUsersListKey = GlobalKey<RoomUsersListState>();
  RoomUsersScreen({super.key, required this.roomId, required this.role});
  final String role;
  final int roomId;

  void _triggerUserRefresh() {
    roomUsersListKey.currentState?.refreshUsers(); // wywołanie metody dziecka
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              "Users in room",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          RoomUsersList(roomId: roomId, key: roomUsersListKey),
          if (role == "admin")
            Center(
              child: ElevatedButton(
                onPressed: () {
                  addUserToRoomWidget(context: context, roomId: roomId, onUserAdded: _triggerUserRefresh);
                },
                child: Text("Add new Users"),
              ),
            ),
        ],
      ),
    );
  }
}
