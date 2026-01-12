import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class TeamAddForm extends StatefulWidget {
  final void Function(String name, File? logo) onTeamAdded;

  const TeamAddForm({required this.onTeamAdded, super.key});

  @override
  State<TeamAddForm> createState() => _TeamAddFormState();
}

class _TeamAddFormState extends State<TeamAddForm> {
  static const String _defaultAsset = 'lib/assets/logo.png';
  static const int _maxImageSize = 256; // Max width/height in pixels
  static const int _jpegQuality = 85; // JPEG quality (0-100)
  
  final _nameController = TextEditingController();
  File? _image;
  final picker = ImagePicker();
  bool _isProcessing = false;

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512, // Initial limit from picker
      maxHeight: 512,
    );
    if (pickedFile != null) {
      setState(() {
        _isProcessing = true;
      });
      
      try {
        final processedFile = await _processImage(File(pickedFile.path));
        setState(() {
          _image = processedFile;
          _isProcessing = false;
        });
      } catch (e) {
        debugPrint('Error processing image: $e');
        setState(() {
          _image = File(pickedFile.path);
          _isProcessing = false;
        });
      }
    }
  }

  /// Process image: resize and convert to JPEG for optimal size
  Future<File> _processImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final originalImage = img.decodeImage(bytes);
    
    if (originalImage == null) {
      return imageFile;
    }

    // Resize if larger than max size
    img.Image resized;
    if (originalImage.width > _maxImageSize || originalImage.height > _maxImageSize) {
      if (originalImage.width > originalImage.height) {
        resized = img.copyResize(originalImage, width: _maxImageSize);
      } else {
        resized = img.copyResize(originalImage, height: _maxImageSize);
      }
    } else {
      resized = originalImage;
    }

    // Encode as JPEG for smaller file size
    final jpegBytes = img.encodeJpg(resized, quality: _jpegQuality);

    // Save to temp file
    final tempDir = Directory.systemTemp;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${tempDir.path}/team_logo_$timestamp.jpg');
    await file.writeAsBytes(jpegBytes, flush: true);

    debugPrint('Image processed: ${bytes.length} bytes -> ${jpegBytes.length} bytes');
    
    return file;
  }

  Future<File> _assetToTempFile(String assetPath, String fileName) async {
    final bytes = await rootBundle.load(assetPath);
    final buffer = bytes.buffer;
    final uint8List = buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
    
    // Process the default asset too
    final originalImage = img.decodeImage(uint8List);
    if (originalImage != null) {
      img.Image resized;
      if (originalImage.width > _maxImageSize || originalImage.height > _maxImageSize) {
        if (originalImage.width > originalImage.height) {
          resized = img.copyResize(originalImage, width: _maxImageSize);
        } else {
          resized = img.copyResize(originalImage, height: _maxImageSize);
        }
      } else {
        resized = originalImage;
      }
      
      final jpegBytes = img.encodeJpg(resized, quality: _jpegQuality);
      final tempDir = Directory.systemTemp;
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(jpegBytes, flush: true);
      return file;
    }
    
    // Fallback if decoding fails
    final tempDir = Directory.systemTemp;
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(uint8List, flush: true);
    return file;
  }

  void _submit() async {
    widget.onTeamAdded(
      _nameController.text,
      _image ?? await _assetToTempFile(_defaultAsset, 'logo.jpg'),
    );

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
            onPressed: _isProcessing ? null : _pickImage,
            child: _isProcessing
                ? const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : _image == null
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
