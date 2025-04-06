import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

  void _submit() {
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
        const Text("Team name"),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            hintText: 'Enter team name',
          ),
        ),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
            ),
            child: _image == null
                ? const Center(child: Text('Add logo'))
                : Image.file(_image!, fit: BoxFit.cover),
          ),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text("Add team"),
        ),
      ],
    );
  }
}