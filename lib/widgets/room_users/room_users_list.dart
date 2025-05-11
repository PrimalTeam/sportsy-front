import 'package:flutter/material.dart';
import 'package:sportsy_front/dto/get_room_users_dto.dart';
import 'package:sportsy_front/modules/services/auth.dart';

class RoomUsersList extends StatefulWidget {
  const RoomUsersList({super.key, required this.roomId});
    final int roomId;

  @override
  State<RoomUsersList> createState() => _RoomUsersListState();
}

class _RoomUsersListState extends State<RoomUsersList> {
  late Future<List<GetRoomUsersDto>> roomUsers;
  @override
  void initState() {
    super.initState();
    roomUsers = AuthService.getRoomUsers(widget.roomId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<GetRoomUsersDto>>(
      future: roomUsers,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final user = snapshot.data![index];
              return ListTile(
                title: Text(user.username),
                subtitle: Text('ID: ${user.id}, Email: ${user.email}'),
              );
            },
          );
        } else {
          return const Text('No users found.');
        }
      },
    );
  }
}
