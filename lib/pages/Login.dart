import 'dart:convert';
import 'dart:io';

import 'package:authentication/User.dart';
import 'package:authentication/pages/Account.dart';
import 'package:authentication/pages/SingUp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gif_view/gif_view.dart';
import 'package:nfc_manager/nfc_manager.dart';

class Login extends StatefulWidget{
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState ();
}

class _LoginState extends State<Login> {
  @override
  void initState() {
    super.initState();
  }
  String _tagId = "";
  String _statusMessage = "";
  bool _card=false;

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
      body: Column(
          mainAxisAlignment:MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 40,),
            Container(
                alignment: Alignment.center,
                height: 150,
                child: Image.asset("assets/images/hamrah.png")
            ),
            Container(
              alignment: Alignment.center,
              height: 80,
              child: const Text("Hamrah Aval",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            Column(
                children: [
                  if (!_card)
                  Column(
                    children: [
                      const SizedBox(height: 100,),
                      Container(
                        alignment: Alignment.center,
                        height: 50,
                        width: 250,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            shape: const BeveledRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(13))),
                          ),
                          onPressed: () {
                            setState(() {
                            });
                          },
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text("Face ID",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                              SizedBox(width: 10,),
                              Icon(Icons.face,
                                color: Colors.white,
                                size: 30,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20,),
                      Container(
                        alignment: Alignment.center,
                        height: 50,
                        width: 250,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            shape: const BeveledRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(13))),
                          ),
                          onPressed: () {
                            setState(() {
                              _card=true;
                            });
                            _readNfcTag();
                          },
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text("Card",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                              SizedBox(width: 10,),
                              Icon(Icons.nfc,
                                color: Colors.white,
                                size: 30,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_card)
                    Column(
                      children: [
                        GifView.asset(
                          'assets/gifs/gif1.gif',
                          height: 300,
                          width: 300,
                          frameRate: 30, // default is 15 FPS
                        ),
                        const SizedBox(height: 30,),
                        Text(_statusMessage,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    )
                ]
            ),
          ]
      ),
    );
  }

  void _readNfcTag() {
    setState(() {
      _statusMessage = "Starting NFC read session...";
    });

    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      try {
        _statusMessage = "Tag detected successfully, wait for login...";

        if (tag.data.containsKey('nfca')) {
          final tagId = tag.data['nfca']?['identifier'];
          if (tagId != null) {
            setState(() {
              _tagId = tagId.map((e) => e.toRadixString(16).padLeft(2, '0')).join(':').toUpperCase();
              if (_tagId!=""){
                checkLoginNFCID(_tagId);
              }
            });
          } else {
            setState(() {
              _statusMessage="please try again!";
            });
          }
        } else if (tag.data.containsKey('nfcb')) {
          final tagId = tag.data['nfcb']?['identifier'];
          if (tagId != null) {
            setState(() {
              _tagId = tagId.map((e) => e.toRadixString(16).padLeft(2, '0')).join(':').toUpperCase();
              if (_tagId!=""){
                checkLoginNFCID(_tagId);
              }
            });
          } else {
            setState(() {
              _statusMessage="please try again!";
            });
          }
        } else if (tag.data.containsKey('nfcf')) {
          final tagId = tag.data['nfcf']?['identifier'];
          if (tagId != null) {
            setState(() {
              _tagId = tagId.map((e) => e.toRadixString(16).padLeft(2, '0')).join(':').toUpperCase();
              if (_tagId!=""){
                checkLoginNFCID(_tagId);
              }
            });
          } else {
            setState(() {
              _statusMessage="please try again!";
            });
          }
        }else if (tag.data.containsKey('nfcv')) {
          final tagId = tag.data['nfcv']?['identifier'];
          if (tagId != null) {
            setState(() {
              _tagId = tagId.map((e) => e.toRadixString(16).padLeft(2, '0')).join(':').toUpperCase();
              if (_tagId!=""){
                checkLoginNFCID(_tagId);
              }
            });
          } else {
            setState(() {
              _statusMessage="please try again!";
            });
          }
        }


      } catch (e) {
        setState(() {
          _statusMessage = "Error reading NFC tag: $e";
        });
      } finally {
        NfcManager.instance.stopSession();
      }
    }).catchError((error) {
      setState(() {
        _statusMessage = "Error starting NFC session: $error";
      });
      NfcManager.instance.stopSession();
    });
  }

  checkLoginNFCID(String NFCID) async {
    String res='';
    String request="checkLoginNFCID\n$NFCID\u0000";
    var socket = await Socket.connect("192.168.1.107", 44560);
    socket.write(request);
    socket.flush();

    var subscription =socket.listen((response) {
      res+=String.fromCharCodes(response);
    });
    await subscription.asFuture<void>();
    print(res);
    List<String> list = LineSplitter().convert(res);
    if (list[0] == "Login successfully") {
      List<String> users=list[1].split("#");
      User user=User(username: users[1], name: users[2], lastName: users[3], NFCID: users[0]);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Account(user: user)),
      );
    }
  }

}