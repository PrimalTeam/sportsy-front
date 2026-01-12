import 'package:flutter/material.dart';
import 'package:sportsy_front/custom_colors.dart';
import 'package:sportsy_front/dto/user_profile_dto.dart';
import 'package:sportsy_front/features/user_profile/data/user_profile_remote_service.dart';
import 'package:sportsy_front/widgets/app_bar.dart';
import 'package:sportsy_front/core/auth/jwt_storage_service.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key, required this.username});
  final String username;

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late Future<UserProfileDto> _profileFuture;
  UserProfileDto? _profile;

  @override
  void initState() {
    super.initState();
    _profileFuture = UserProfileRemoteService.getUserProfile(widget.username);
  }

  void _refreshProfile(String? newUsername) {
    setState(() {
      _profileFuture = UserProfileRemoteService.getUserProfile(
        newUsername ?? _profile?.username ?? widget.username,
      );
    });
  }

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    return '${local.day.toString().padLeft(2, '0')}.${local.month.toString().padLeft(2, '0')}.${local.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: 'Profile'),
      backgroundColor: AppColors.background,
      body: FutureBuilder<UserProfileDto>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                  const SizedBox(height: 12),
                  const Text(
                    'Failed to load profile',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => _refreshProfile(null),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(
              child: Text(
                'Profile data unavailable',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }
          final profile = snapshot.data!;
          _profile = profile;
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.accent,
                          AppColors.accent.withOpacity(0.6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.transparent,
                      child: Text(
                        profile.username.isNotEmpty
                            ? profile.username[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 40,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Profile Card - Editable Fields
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      children: [
                        _EditableProfileField(
                          icon: Icons.person_outline,
                          label: 'Username',
                          value: profile.username,
                          onSave: (newValue) => _updateField('username', newValue),
                        ),
                        Divider(color: Colors.white.withOpacity(0.1), height: 1),
                        _EditableProfileField(
                          icon: Icons.email_outlined,
                          label: 'Email',
                          value: profile.email,
                          keyboardType: TextInputType.emailAddress,
                          onSave: (newValue) => _updateField('email', newValue),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Info Card - Read-only Fields
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      children: [
                        _ProfileInfoRow(
                          icon: Icons.tag,
                          label: 'User ID',
                          value: '#${profile.id}',
                        ),
                        Divider(color: Colors.white.withOpacity(0.1), height: 1),
                        _ProfileInfoRow(
                          icon: Icons.calendar_today_outlined,
                          label: 'Member since',
                          value: _formatDate(profile.createdAt),
                        ),
                        if (profile.roles.isNotEmpty) ...[
                          Divider(color: Colors.white.withOpacity(0.1), height: 1),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                const Icon(Icons.shield_outlined, color: Colors.white54, size: 22),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Roles',
                                        style: TextStyle(color: Colors.white54, fontSize: 12),
                                      ),
                                      const SizedBox(height: 6),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children: profile.roles.map((role) => Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppColors.accent.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: AppColors.accent.withOpacity(0.4)),
                                          ),
                                          child: Text(
                                            role,
                                            style: const TextStyle(color: Colors.white, fontSize: 12),
                                          ),
                                        )).toList(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await JwtStorageService.clearTokens();
                        if (context.mounted) {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            '/login',
                            (route) => false,
                          );
                        }
                      },
                      icon: const Icon(Icons.logout, size: 20),
                      label: const Text('Log out'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.warning,
                        side: BorderSide(color: AppColors.warning.withOpacity(0.5)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _updateField(String field, String newValue) async {
    try {
      await UserProfileRemoteService.updateProfile(
        username: field == 'username' ? newValue : null,
        email: field == 'email' ? newValue : null,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${field == 'username' ? 'Username' : 'Email'} updated!'),
            backgroundColor: Colors.green,
          ),
        );
        _refreshProfile(field == 'username' ? newValue : null);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }
}

class _EditableProfileField extends StatefulWidget {
  const _EditableProfileField({
    required this.icon,
    required this.label,
    required this.value,
    required this.onSave,
    this.keyboardType = TextInputType.text,
  });

  final IconData icon;
  final String label;
  final String value;
  final Future<void> Function(String) onSave;
  final TextInputType keyboardType;

  @override
  State<_EditableProfileField> createState() => _EditableProfileFieldState();
}

class _EditableProfileFieldState extends State<_EditableProfileField> {
  bool _isEditing = false;
  bool _isSaving = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant _EditableProfileField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && !_isEditing) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final newValue = _controller.text.trim();
    if (newValue.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Field cannot be empty'), backgroundColor: Colors.redAccent),
      );
      return;
    }
    if (newValue == widget.value) {
      setState(() => _isEditing = false);
      return;
    }

    setState(() => _isSaving = true);
    await widget.onSave(newValue);
    if (mounted) {
      setState(() {
        _isSaving = false;
        _isEditing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(widget.icon, color: Colors.white54, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.label,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 4),
                _isEditing
                    ? TextField(
                        controller: _controller,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        keyboardType: widget.keyboardType,
                        autofocus: true,
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 4),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _save(),
                      )
                    : Text(
                        widget.value,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
              ],
            ),
          ),
          if (_isSaving)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent),
            )
          else if (_isEditing)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                  onPressed: () {
                    _controller.text = widget.value;
                    setState(() => _isEditing = false);
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.greenAccent, size: 20),
                  onPressed: _save,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            )
          else
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.white38, size: 20),
              onPressed: () => setState(() => _isEditing = true),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
        ],
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: Colors.white54, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
