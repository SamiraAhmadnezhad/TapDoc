import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:authentication/Doc.dart';
import 'package:authentication/User.dart';
import 'package:authentication/repository/UserRepository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

class EditDocPage extends StatefulWidget {
  final Doc doc;
  final User user;

  const EditDocPage({super.key, required this.doc, required this.user});

  @override
  _EditDocPageState createState() => _EditDocPageState();
}

class _EditDocPageState extends State<EditDocPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  String _fileName = '';
  String _docPath = '';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.doc.title);
    _descriptionController = TextEditingController(text: widget.doc.description);
    if (widget.doc.files != null) {
      _fileName = widget.doc.files!.split('/').last;
      _docPath = widget.doc.files!;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        final filePath = result.files.single.path!;
        final file = File(filePath);
        final fileBytes = await file.readAsBytes();
        if (fileBytes != null) {
          setState(() {
            _fileName = result.files.single.name;
          });
          _docPath = await _saveFile(fileBytes);
        }
      }
    } catch (e) {
      print('Error picking file: $e');
    }
  }

  Future<String> _saveFile(Uint8List fileBytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = '${directory.path}/${timestamp}_$_fileName';
    final file = File(filePath);
    await file.writeAsBytes(fileBytes);
    return filePath;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Document',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.cyan,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            CupertinoIcons.back,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              if (_fileName.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.insert_drive_file, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _fileName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.attach_file, color: Colors.white),
                label: const Text(
                  'Change File',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
                onPressed: _pickFile,
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: screenWidth * 0.6,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text(
                    'Save',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan,
                  ),
                  onPressed: () async {
                    setState(() {
                      widget.doc.title = _titleController.text;
                      widget.doc.description = _descriptionController.text;
                      widget.doc.files = _docPath;
                    });
                    await UserRepository.updateUser(widget.user);
                    Navigator.pop(context, widget.doc);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
