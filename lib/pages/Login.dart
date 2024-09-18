import 'dart:convert';
import 'dart:io';

import 'package:authentication/User.dart';
import 'package:authentication/pages/HomePage.dart';
import 'package:authentication/pages/Admin.dart';
import 'package:authentication/repository/UserRepository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gif_view/gif_view.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  void initState() {
    super.initState();
    setState(() {
      _statusMessage = "Starting NFC read session...";
    });
  }

  String _tagId = "";
  String _statusMessage = "";
  bool _card = false;

  @override
  Widget build(BuildContext context) {
    // Get screen size
    var screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: _readNfcTag,
          icon: const Icon(
            CupertinoIcons.refresh,
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: screenSize.height * 0.05),
            Container(
              alignment: Alignment.center,
              height: screenSize.height * 0.2,
              child: Image.asset("assets/images/hamrah.png"),
            ),
            Container(
              alignment: Alignment.center,
              height: screenSize.height * 0.1,
              child: const Text(
                "Hamrah Aval",
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
                      SizedBox(height: screenSize.height * 0.1),
                      Container(
                        alignment: Alignment.center,
                        height: 50,
                        width: screenSize.width * 0.6,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            shape: const BeveledRectangleBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(13))),
                          ),
                          onPressed: () {
                            setState(() {
                              _card = true;
                            });
                            _readNfcTag();
                          },
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text(
                                "Login",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                              SizedBox(width: 10),
                              Icon(
                                Icons.nfc,
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
                        height: screenSize.height * 0.4,
                        width: screenSize.width * 0.8,
                        frameRate: 30, // default is 15 FPS
                      ),
                      SizedBox(height: screenSize.height * 0.05),
                      Text(
                        _statusMessage,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _readNfcTag() {
    setState(() {
      _statusMessage = "Starting NFC read session...";
    });
    String nfcMessage = "";
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      try {
        print(tag.data);
        _statusMessage = "Tag detected successfully, wait for login...";

        var ndef = Ndef.from(tag);
        if (ndef != null && ndef.cachedMessage != null) {
          for (var record in ndef.cachedMessage!.records) {
            nfcMessage += String.fromCharCodes(record.payload.sublist(3));
          }
          print("read key : " + nfcMessage);
        } else {
          setState(() {
            _statusMessage = "No NDEF message found.";
          });
        }

        if (tag.data.containsKey('nfca')) {
          final tagId = tag.data['nfca']?['identifier'];
          if (tagId != null) {
            setState(() {
              _tagId = tagId
                  .map((e) => e.toRadixString(16).padLeft(2, '0'))
                  .join(':')
                  .toUpperCase();
              if (_tagId != "") {
                if(tag.data["ndef"]!=null)
                  _checkLoginId(_tagId, nfcMessage,(tag.data["ndef"]!["isWritable"] ?? false));
                else
                  _checkLoginId(_tagId, nfcMessage, false);
              }
            });
          } else {
            setState(() {
              _statusMessage = "please try again!";
            });
          }
        } else if (tag.data.containsKey('nfcb')) {
          final tagId = tag.data['nfcb']?['identifier'];
          if (tagId != null) {
            setState(() {
              _tagId = tagId
                  .map((e) => e.toRadixString(16).padLeft(2, '0'))
                  .join(':')
                  .toUpperCase();
              if (_tagId != "") {
                if(tag.data["ndef"]!=null)
                  _checkLoginId(_tagId, nfcMessage,(tag.data["ndef"]!["isWritable"] ?? false));
                else
                  _checkLoginId(_tagId, nfcMessage, false);
              }
            });
          } else {
            setState(() {
              _statusMessage = "please try again!";
            });
          }
        } else if (tag.data.containsKey('nfcf')) {
          final tagId = tag.data['nfcf']?['identifier'];
          if (tagId != null) {
            setState(() {
              _tagId = tagId
                  .map((e) => e.toRadixString(16).padLeft(2, '0'))
                  .join(':')
                  .toUpperCase();
              if (_tagId != "") {
                if(tag.data["ndef"]!=null)
                  _checkLoginId(_tagId, nfcMessage,(tag.data["ndef"]!["isWritable"] ?? false));
                else
                  _checkLoginId(_tagId, nfcMessage, false);
              }
            });
          } else {
            setState(() {
              _statusMessage = "please try again!";
            });
          }
        } else if (tag.data.containsKey('nfcv')) {
          final tagId = tag.data['nfcv']?['identifier'];
          if (tagId != null) {
            setState(() {
              _tagId = tagId
                  .map((e) => e.toRadixString(16).padLeft(2, '0'))
                  .join(':')
                  .toUpperCase();
              if (_tagId != "") {
                if(tag.data["ndef"]!=null)
                _checkLoginId(_tagId, nfcMessage,(tag.data["ndef"]!["isWritable"] ?? false));
                else
                  _checkLoginId(_tagId, nfcMessage, false);
              }
            });
          } else {
            setState(() {
              _statusMessage = "please try again!";
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

  void _checkLoginId(String id, String privateKey,bool isWritable) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedAdminTagId = prefs.getString('adminTagId');
    print("start");
    if (id == savedAdminTagId) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Admin()),
      );
    } else {
      final User? user = await UserRepository.getUserById(id, privateKey,isWritable);
      if (user != null) {
        _card = false;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage(user: user)),
        );
      } else {
        setState(() {
          _statusMessage = "User not found";
        });
      }
    }
  }
}
