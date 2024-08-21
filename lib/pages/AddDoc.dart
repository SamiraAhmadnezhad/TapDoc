import 'dart:io';
import 'dart:typed_data';

import 'package:authentication/Doc.dart';
import 'package:authentication/User.dart';
import 'package:authentication/repository/UserRepository.dart';
import 'package:authentication/utils/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class addDoc extends StatefulWidget {
  final User user;
  const addDoc({super.key, required this.user});
  @override
  _addDocState createState() => _addDocState(user: user);
}

class _addDocState extends State<addDoc> {
  _addDocState({required this.user});
  User user;
  final _formKey = GlobalKey<FormState>();
  String? _title;
  String? _description;
  String _docPath = '';
  String _fileName = ''; // متغیر برای ذخیره نام فایل

  _imageSelect(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: const Text("Select image"),
            children: [
              SimpleDialogOption(
                padding: const EdgeInsets.all(10),
                child: const Text("Take a photo"),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List? file = await pickImage(ImageSource.camera);
                  if (file != null) {
                    final imageBytes = await _saveImage(file);
                    setState(() {
                      user.profile = imageBytes;
                    });
                    await UserRepository.updateUser(user);
                  }
                },
              ),
              SimpleDialogOption(
                padding: const EdgeInsets.all(10),
                child: const Text("Chose from gallery"),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List? file = await pickImage(ImageSource.gallery);
                  if (file != null) {
                    final imageBytes = await _saveImage(file);
                    setState(() {
                      user.profile = imageBytes;
                    });
                    print("start");
                    await UserRepository.updateUser(user);
                  }
                },
              ),
            ],
          );
        });
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
            _fileName = result.files.single.name; // ذخیره نام فایل انتخاب شده
          });
          _docPath = await _saveFile(fileBytes);

        }
      }
    } catch (e) {
      print('Error picking file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            CupertinoIcons.back,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.cyan,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.save,
              color: Colors.white,
            ),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data Saved')),
                );
                if (_title != null) {
                  Doc doc = Doc(
                      userId: user.id, title: _title!, description: _description);
                  if (_docPath != null && _docPath != "") doc.addFiles(_docPath);
                  user.addDoc(doc);
                }
                await UserRepository.updateUser(user);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Title cannot be empty';
                  }
                  return null;
                },
                onSaved: (value) {
                  _title = value;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 5,
                onSaved: (value) {
                  _description = value;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(
                  Icons.attach_file,
                  color: Colors.black,
                ),
                label: const Text(
                  'Add File',
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: _pickFile,
              ),
              const SizedBox(height: 16),
              // ویجت برای نمایش نام فایل و آیکون
              if (_fileName.isNotEmpty)
                Row(
                  children: [
                    const Icon(
                      Icons.insert_drive_file,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Expanded( // یا Flexible
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

            ],
          ),
        ),
      ),
    );
  }

  Future<String> _saveImage(Uint8List imageBytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = '${directory.path}/image_$timestamp.png';
    final file = File(filePath);
    await file.writeAsBytes(imageBytes);
    return filePath;
  }

  Future<Uint8List> _loadImage(String filePath) async {
    final file = File(filePath);
    return await file.readAsBytes();
  }

  Future<String> _saveFile(Uint8List fileBytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = '${directory.path}/${timestamp}_$_fileName';
    final file = File(filePath);
    await file.writeAsBytes(fileBytes);
    return filePath;
  }

  Future<Uint8List> _loadFile(String filePath) async {
    final file = File(filePath);
    return await file.readAsBytes();
  }
}
