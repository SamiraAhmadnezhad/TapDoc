import 'dart:io';
import 'dart:typed_data';
import 'package:authentication/Doc.dart';
import 'package:authentication/pages/AddDoc.dart';
import 'package:authentication/pages/DocDetailsPage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:authentication/repository/UserRepository.dart';
import 'package:authentication/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:authentication/User.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class HomePage extends StatefulWidget {
  final User user;
  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState(user: user);
}

class _HomePageState extends State<HomePage> {
  _HomePageState({required this.user});
  User user;

  @override
  void initState() {
    super.initState();
    setState(() {
      if (user.name != null) _name = user.name!;
    });
  }

  String docPath = '';
  String _name = "user name";

  _imageSelect(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: const Text("Select image"),
            children: [
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text("Camera"),
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
                padding: const EdgeInsets.all(20),
                child: const Text("Gallery"),
                onPressed: () async {
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
          );
        });
  }

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Exit"),
          content: const Text("Are you sure you want to leave?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(
          CupertinoIcons.plus,
          color: Colors.white,
        ),
        backgroundColor: Colors.orange,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddDoc(user: user)),
          ).then((_) {
            setState(() {});
          });
        },
      ),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () async {
            bool exitConfirmed = await _showExitConfirmationDialog(context);
            if (exitConfirmed) {
              Navigator.pop(context);
            }
          },
          icon: const Icon(
            CupertinoIcons.back,
            color: Colors.white,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                _name,
                style: TextStyle(
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () async {
                String? newName = await _showEditNameDialog(context, _name);
                if (newName != null && newName.isNotEmpty) {
                  setState(() {
                    _name = newName;
                    user.name = newName;
                  });
                  await UserRepository.updateUser(user);
                }
              },
            ),
          ],
        ),
        backgroundColor: Colors.cyan.shade600,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 20),
              if (user.profile != null)
                Stack(
                  children: [
                    SizedBox(
                      height: 200,
                      width: 200,
                      child: FutureBuilder<Uint8List>(
                        future: _loadImage(user.profile!),
                        builder: (BuildContext context, AsyncSnapshot<Uint8List> snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return const Center(child: Text('Error loading image'));
                          } else if (snapshot.hasData) {
                            return ClipOval(
                              child: Image.memory(
                                snapshot.data!,
                                fit: BoxFit.cover,
                                width: 200,
                                height: 200,
                              ),
                            );
                          } else {
                            return const Center(child: Text('No image available'));
                          }
                        },
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt),
                        onPressed: () {
                          _imageSelect(context);
                        },
                        iconSize: 40,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                )
              else
                Stack(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      width: 200,
                      height: 200,
                      child: const Center(
                        child: Text(
                          'No Image',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt),
                        onPressed: () {
                          _imageSelect(context);
                        },
                        iconSize: 40,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              if (user.docs != null && user.docs!.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: user.docs!.length,
                  itemBuilder: (context, index) {
                    final doc = user.docs![index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: const Icon(
                          Icons.description,
                          color: Colors.orange,
                          size: 40,
                        ),
                        title: Text(
                          doc.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: doc.description != null
                            ? Text(
                          doc.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        )
                            : null,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DocDetailsPage(
                                doc: doc,
                                user: user,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                )
              else
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'No documents available.',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              const SizedBox(height: 20),
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

  Future<String?> _showEditNameDialog(BuildContext context, String currentName) {
    TextEditingController _nameController = TextEditingController(text: currentName);

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Name'),
          content: TextField(
            controller: _nameController,
            decoration: const InputDecoration(hintText: "Enter new name"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await UserRepository.updateUser(user);
                Navigator.of(context).pop(_nameController.text);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
