import 'dart:io';
import 'dart:typed_data';
import 'package:authentication/Doc.dart';
import 'package:authentication/pages/AddDoc.dart';
import 'package:authentication/pages/DocDetailsPage.dart';
import 'package:path/path.dart';
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
    setState(() {});
  }

  String docPath = '';

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
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(
          CupertinoIcons.plus,
          color: Colors.white,
        ),
        backgroundColor: Colors.orange,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => addDoc(user: user)),
          ).then((_) {
            setState(() {}); // Refresh the state when returning to the page
          });
        },
      ),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            CupertinoIcons.back,
            color: Colors.white,
          ),
        ),
        title: const Text(
          "NFC",
          style: TextStyle(
            color: Colors.white,
          ),
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
                    Container(
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
                  physics: NeverScrollableScrollPhysics(),
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
                        leading: Icon(
                          Icons.description,
                          color: Colors.orange,
                          size: 40,
                        ),
                        title: Text(
                          doc.title,
                          style: TextStyle(
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
                              builder: (context) => DocDetailsPage(doc: doc),
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
}
