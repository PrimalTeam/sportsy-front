import 'package:flutter/material.dart';
import 'package:sportsy_front/core/auth/jwt_storage_service.dart';
import 'package:sportsy_front/custom_colors.dart';
import 'package:sportsy_front/dto/get_room_users_dto.dart';
import 'package:sportsy_front/features/room_users/data/room_users_remote_service.dart';
import 'package:sportsy_front/screens/user_profile_page.dart';
import 'package:sportsy_front/screens/room_user_edit_page.dart';

class RoomUsersList extends StatefulWidget {
  const RoomUsersList({
    super.key,
    required this.roomId,
    required this.currentUserRole,
  });
  final int roomId;
  final String currentUserRole;

  @override
  State<RoomUsersList> createState() => RoomUsersListState();
}

class RoomUsersListState extends State<RoomUsersList> {
  late Future<List<GetRoomUsersDto>> roomUsers;
  String? _currentUsername;

  bool get _canManage {
    final role = widget.currentUserRole.toLowerCase();
    return role == 'admin' || role == 'spectrator';
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    refreshUsers();
  }

  Future<void> _loadCurrentUser() async {
    final token = await JwtStorageService.getToken();
    if (token != null) {
      setState(() {
        _currentUsername = JwtStorageService.getDataFromToken(token, 'username');
      });
    }
  }

  Future<void> refreshUsers() async {
    setState(() {
      roomUsers = RoomUsersRemoteService.getRoomUsers(widget.roomId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<GetRoomUsersDto>>(
      future: roomUsers,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final user = snapshot.data![index];
              final isCurrentUser = _currentUsername != null && user.user.username == _currentUsername;
              return ListTile(
                title: Text(
                  user.user.username,
                  style: TextStyle(color: AppColors.secondary),
                ),
                subtitle: Text(
                  'ID: ${user.id}, Email: ${user.user.email}',
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: Wrap(
                  spacing: 8,
                  children: [
                    IconButton(
                      tooltip: 'Profil',
                      icon: const Icon(Icons.person),
                      color: Colors.white,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (_) => UserProfilePage(
                                  username: user.user.username,
                                ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      tooltip: 'Edytuj rolę',
                      icon: const Icon(Icons.edit),
                      color: AppColors.secondary,
                      onPressed: (!_canManage || isCurrentUser)
                          ? null
                          : () async {
                        final changed = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (context) => RoomUserEditPage(
                                  roomId: widget.roomId,
                                  user: user,
                                      currentUserRole: widget.currentUserRole,
                                ),
                          ),
                        );
                        if (changed == true) {
                          refreshUsers();
                        }
                      },
                    ),
                    IconButton(
                      tooltip: 'Usuń z pokoju',
                      icon: const Icon(Icons.delete),
                      color: AppColors.warning,
                      onPressed: !_canManage
                          ? null
                          : () async {
                            await RoomUsersRemoteService.deleteUser(
                              widget.roomId,
                              user.id,
                            );
                            setState(() {
                              roomUsers = RoomUsersRemoteService.getRoomUsers(
                                widget.roomId,
                              );
                            });
                          },
                    ),
                  ],
                ),
              );
            },
          );
        } else {
          return const Text(
            'No users found.',
            style: TextStyle(color: Colors.white),
          );
        }
      },
    );
  }
}
