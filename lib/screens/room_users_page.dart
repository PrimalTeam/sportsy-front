import 'package:flutter/material.dart';
import 'package:sportsy_front/widgets/add_user_to_room_widget.dart';
import 'package:sportsy_front/widgets/app_bar.dart';
import 'package:sportsy_front/widgets/room_users/room_users_list.dart';

class RoomUsersPage extends StatelessWidget {
  const RoomUsersPage({super.key, required this.roomId, required this.role});
  final String role;
  final int roomId;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: "Add users"),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              "Users in room",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          RoomUsersList(roomId: roomId,),
          if(role == "admin")
          Center(
            child: ElevatedButton(
              onPressed: () {addUserToRoomWidget(context: context, roomId:  roomId, );},
              child: Text("Add new Users"),
            ),
          ),
        ],
      ),
    );
  }
}
