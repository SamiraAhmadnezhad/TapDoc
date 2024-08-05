
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:authentication/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:authentication/User.dart';
import 'package:authentication/utils/utils.dart';
import 'package:authentication/User.dart';
import 'package:authentication/pages/Login.dart';
import 'package:authentication/pages/SingUp.dart';
import 'package:flutter/material.dart';

class Account extends StatefulWidget{
  final User user;
  const Account({super.key,required this.user});

  @override
  State<Account> createState() => _AccountState (user: user);
}

class _AccountState extends State<Account> {
  _AccountState({required this.user});
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
        title: const Text("NFC",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.cyan.shade600,
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              IconButton(
                icon: Icon(Icons.camera_alt),
                onPressed: () {
                  print((user.faceID!.length!=0));
                  _imageSelect(context);
                },
                iconSize: 150,
                color: Colors.orange,
        
              ),
            if   (user.faceID != null && user.faceID!.length!=0)
              Image.memory(base64Decode(user.faceID!))
            else Text("No image selected."),
            ],
          ),
        ),
      ),
    );
  }



  sendImageToBackend(Uint8List? file) async {
    print("send");
    if (file != null) {
      String base64Image = base64Encode(file!);
      print(base64Image);
      //send to server
      String res='';
      String request="sendImageToBackend\n${user.NFCID}#$base64Image\u0000";
      var socket = await Socket.connect("192.168.1.107", 8080);
      socket.write(request);
      socket.flush();

      var subscription =socket.listen((response) {
        res+=String.fromCharCodes(response);
      });
      await subscription.asFuture<void>();
      print(res);
      if (res.contains("change user successfully!")) {
        setState(() {
          user.faceID=base64Image;
        });
      }
      else {

      }
    } else {
      print("No image data available.");
    }

  }
}