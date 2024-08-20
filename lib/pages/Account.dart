
import 'dart:convert';
import 'dart:typed_data';
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
  Uint8List? _file;
  _imageSelect (BuildContext context) async{
    return showDialog(context: context,
        builder: (context){
          return SimpleDialog(
            title: const Text("Select image"),
            children: [
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text("Take a photo"),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List? file = await pickImage(ImageSource.camera);
                  if (file != null) {
                    setState(() {
                      _file = file;
                    });
                    print("start");
                    sendImageToBackend(file);
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
              IconButton(
                icon: Icon(Icons.camera_alt),
                onPressed: () {
                  print((user.profile!.length!=0));
                  _imageSelect(context);
                },
                iconSize: 150,
                color: Colors.orange,
        
              ),
            if   (user.profile != null && user.profile!.length!=0)
              Image.memory(base64Decode(user.profile!.toString()))
            else Text("No image selected."),
            ],
          ),
        ),
      ),
    );
  }



  sendImageToBackend(Uint8List? file) async {

  }
}