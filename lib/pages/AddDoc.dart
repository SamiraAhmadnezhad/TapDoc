import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:authentication/Doc.dart';
import 'package:authentication/User.dart';
import 'package:authentication/repository/UserRepository.dart';
import 'package:authentication/utils/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class AddDoc extends StatefulWidget {
  final User user;
  const AddDoc({super.key, required this.user});
  @override
  _AddDocState createState() => _AddDocState(user: user);
}

class _AddDocState extends State<AddDoc> {
  _AddDocState({required this.user});
  User user;
  final _formKey = GlobalKey<FormState>();
  String? _title;
  String? _description;
  String _docPath = '';
  String _fileName = '';
  bool _isLoading = false;

  _imageSelect(BuildContext context) async {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take a photo'),
                  onTap: () async {
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
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choose from gallery'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    Uint8List? file = await pickImage(ImageSource.gallery);
                    if (file != null) {
                      final imageBytes = await _saveImage(file);
                      setState(() {
                        user.profile = imageBytes;
                      });
                      await UserRepository.updateUser(user);
                    }
                  },
                ),
              ],
            ),
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
            _fileName = result.files.single.name;
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
          'Add Document',
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
          _isLoading
              ? const Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          )
              : IconButton(
            icon: const Icon(
              Icons.save,
              color: Colors.white,
            ),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                setState(() {
                  _isLoading = true;
                });
                _formKey.currentState!.save();
                if (_title != null) {
                  Doc doc = Doc(
                      userId: user.id,
                      title: _title!,
                      description:  (_description!=null && _description!='') ? _description : null,
                      files: (_docPath!=null &&_docPath!='') ? _docPath : null
                  );
                  user.addDoc(doc);
                }
                await UserRepository.updateUser(user);
                setState(() {
                  _isLoading = false;
                });
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: const Text('Document Saved Successfully!'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                    label: 'Title',
                    onSaved: (value) => _title = value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Title cannot be empty';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Description',
                    onSaved: (value) => _description = value,
                    maxLines: 5,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.attach_file, color: Colors.white),
                    label: const Text(
                      'Add File',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan,
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      minimumSize: const Size(150, 40),
                    ),
                    onPressed: _pickFile,
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
                          const Icon(
                            Icons.insert_drive_file,
                            color: Colors.blue,
                          ),
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    int maxLines = 1,
    FormFieldValidator<String>? validator,
    FormFieldSetter<String>? onSaved,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      maxLines: maxLines,
      validator: validator,
      onSaved: onSaved,
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

  Future<String> _saveFile(Uint8List fileBytes) async {
    print('start'+ base64Encode(fileBytes));
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = '${directory.path}/${timestamp}_$_fileName';
    final file = File(filePath);
    await file.writeAsBytes(fileBytes);
    return filePath;
  }
}
