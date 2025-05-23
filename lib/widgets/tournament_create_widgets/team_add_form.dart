import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sportsy_front/dto/team_add_dto.dart';
import 'package:sportsy_front/modules/services/auth.dart';

class TeamAddForm extends StatefulWidget {
  final void Function(String name, File? logo) onTeamAdded;

  const TeamAddForm({required this.onTeamAdded, super.key});

  @override
  State<TeamAddForm> createState() => _TeamAddFormState();
}

class _TeamAddFormState extends State<TeamAddForm> {
  final _nameController = TextEditingController();
  File? _image;
  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _submit() async {
    
    widget.onTeamAdded(_nameController.text, _image);
    _nameController.clear();
    setState(() {
      _image = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(hintText: 'Team name'),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 100,
          width: 100,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(padding: EdgeInsets.zero),
            onPressed: _pickImage,

            child:
                _image == null
                    ? const Center(
                      child: Text('Add logo', style: TextStyle(fontSize: 12)),
                    )
                    : ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Image.file(
                        _image!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
          ),
        ),
        const SizedBox(height: 15),
        ElevatedButton(onPressed: _submit, child: const Text("Add team")),
      ],
    );
  }
}
