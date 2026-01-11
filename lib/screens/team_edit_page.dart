import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sportsy_front/custom_colors.dart';
import 'package:sportsy_front/dto/get_teams_dto.dart';
import 'package:sportsy_front/features/teams/data/teams_remote_service.dart';

class TeamEditPage extends StatefulWidget {
  const TeamEditPage({
    super.key,
    required this.roomId,
    required this.team,
    this.bracketExists = false,
  });
  final int roomId;
  final GetTeamsDto team;
  final bool bracketExists;

  @override
  State<TeamEditPage> createState() => _TeamEditPageState();
}

class _TeamEditPageState extends State<TeamEditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  // Align with TeamAddForm: hold File, convert to bytes only on save
  File? _imageFile;
  static const String _defaultAsset = 'lib/assets/logo.png';
  bool _saving = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.team.name);
    // If team already has icon bytes, write them to a temp file so UI behaves like TeamAddForm
    final existing = widget.team.icon?.data;
    if (existing != null && existing.isNotEmpty) {
      _imageFile = _bytesToTempFile(existing, 'team_${widget.team.id}.png');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<File> _assetToTempFile(String assetPath, String fileName) async {
    final bytes = await rootBundle.load(assetPath);
    final buffer = bytes.buffer;
    final tempDir = Directory.systemTemp;
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(
      buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
      flush: true,
    );
    return file;
  }

  File _bytesToTempFile(Uint8List data, String fileName) {
    final tempDir = Directory.systemTemp;
    final file = File('${tempDir.path}/$fileName');
    file.writeAsBytesSync(data, flush: true);
    return file;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      // Convert chosen file (or fallback asset) to bytes similarly as in TeamAddForm
      Uint8List? iconBytes;
      if (_imageFile != null) {
        iconBytes = await _imageFile!.readAsBytes();
      } else {
        final fallback = await _assetToTempFile(_defaultAsset, 'logo.png');
        iconBytes = await fallback.readAsBytes();
      }

      await TeamsRemoteService.updateTeam(
        roomId: widget.roomId,
        id: widget.team.id,
        name: _nameController.text.trim(),
        icon: iconBytes, // send bytes; service will serialize to Buffer shape
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _deleteTeam() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Team'),
        content: const Text('Are you sure you want to delete this team?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _saving = true);
    try {
      // Check if team has games
      final details = await TeamsRemoteService.getTeamDetails(
        roomId: widget.roomId,
        teamId: widget.team.id,
      );

      if (details.games.isNotEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot delete team that has created games')),
        );
        return;
      }

      await TeamsRemoteService.deleteTeam(widget.roomId, widget.team.id);
      if (!mounted) return;
      Navigator.pop(context, true); // Return true to reload list
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete team: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Edit Team'),
        actions: [
          if (!widget.bracketExists)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: _saving ? null : _deleteTeam,
            ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 42,
                    backgroundColor: Colors.grey.shade900,
                    foregroundImage:
                        _imageFile != null ? FileImage(_imageFile!) : null,
                    child:
                        _imageFile == null
                            ? const Icon(Icons.add_a_photo, color: Colors.white)
                            : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Team name',
                  labelStyle: TextStyle(color: Colors.white70),
                  prefixIcon: Icon(Icons.group, color: Colors.white70),
                ),
                validator:
                    (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Name required'
                            : null,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child:
                      _saving
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
