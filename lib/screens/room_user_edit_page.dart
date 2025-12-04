import 'package:flutter/material.dart';
import 'package:sportsy_front/custom_colors.dart';
import 'package:sportsy_front/dto/get_room_users_dto.dart';
import 'package:sportsy_front/dto/room_user_role_enum.dart';
import 'package:sportsy_front/features/room_users/data/room_users_remote_service.dart';

class RoomUserEditPage extends StatefulWidget {
  const RoomUserEditPage({super.key, required this.roomId, required this.user});
  final int roomId;
  final GetRoomUsersDto user;

  @override
  State<RoomUserEditPage> createState() => _RoomUserEditPageState();
}

class _RoomUserEditPageState extends State<RoomUserEditPage> {
  // Only rola ma być edytowalna.
  late RoomUserRoleEnum _roleEnum;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Map incoming string role to enum; default to spectrator if unknown.
    _roleEnum = RoomUserRoleEnum.values.firstWhere(
      (e) => e.name == widget.user.role,
      orElse: () => RoomUserRoleEnum.spectrator,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      // Przekazujemy niezmienione identyfikatory (backend może ich wymagać) – używamy username z dto.
      await RoomUsersRemoteService.updateRoomUser(
        roomId: widget.roomId,
        identifier: widget.user.user.username,
        identifierType: 'username',
        role: _roleEnum.name,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update user: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Edit room user'),
      ),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Użytkownik', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Text(
              widget.user.user.username,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 24),
            Text('Rola', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            DropdownButtonFormField<RoomUserRoleEnum>(
              value: _roleEnum,
              items:
                  RoomUserRoleEnum.values
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e.displayName),
                        ),
                      )
                      .toList(),
              onChanged: (v) => setState(() => _roleEnum = v ?? _roleEnum),
              dropdownColor: Colors.black,
              style: const TextStyle(color: Colors.white),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child:
                    _saving
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text('Zapisz rolę'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
