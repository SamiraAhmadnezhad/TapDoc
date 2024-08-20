import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:authentication/repository/UserRepository.dart';
import 'package:authentication/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:authentication/User.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget{
  final User user;
  const HomePage({super.key,required this.user});

  @override
  State<HomePage> createState() => _HomePageState (user: user);
}

class _HomePageState extends State<HomePage> {
  _HomePageState({required this.user});
  User user;
  @override
  void initState() {
    super.initState();
  }
  _imageSelect (BuildContext context) async{
    return showDialog(context: context,
        builder: (context){
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
                    print("start");
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
        }
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(CupertinoIcons.back,
            color: Colors.white,),
        ),
        title: const Text("NFC",
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
              const SizedBox(height: 20,),
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