import 'dart:convert';
import 'dart:io';

import 'package:authentication/pages/Login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gif_view/gif_view.dart';
import 'package:nfc_manager/nfc_manager.dart';

class SignUp extends StatefulWidget{
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState ();
}

class _SignUpState extends State<SignUp> {
  @override
  void initState() {
    super.initState();
  }
  bool _inf=true;
  String _tagId = "";
  String _name = "";
  String _lastName = "";
  String _username = "";
  String _statusMessage = "";
  bool _validateName=true;
  bool _validateUsername=true;
  bool _validateLastNamse=true;
  bool _checkUsername=false; // not exist



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
            setState(() {
              _inf=true;
              _validateName=true;
              _validateUsername=true;
              _validateLastNamse=true;
              _checkUsername=false;
            });
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
        child: Column(
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
            const SizedBox(height: 40,),
            if (_inf)
            SizedBox(
              width: 300,
              child: Column(
                mainAxisAlignment:MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                TextField(
                  onChanged: (text) {
                    setState(() {
                     _username=text;
                     if (_username=="")
                       _validateUsername=true;
                     else
                       _validateUsername=false;
                    });
                  },
                  decoration: InputDecoration(
                    errorText: _validateUsername ? "Username can not be empty!" : (_checkUsername? "This Username already exist": null) ,
                      labelText: 'Username',
                      hintText: "Enter Username",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                      ),
                      fillColor: Colors.orangeAccent.withOpacity(0.1),
                      filled: true,
                      prefixIcon: const Icon(Icons.person)),
                ),
                const SizedBox(height: 20,),
                  TextField(
                    onChanged: (text) {
                      setState(() {
                        _name=text;
                        if (_name=="")
                          _validateName=true;
                        else
                          _validateName=false;
                      });
                    },
                    decoration: InputDecoration(
                        errorText: _validateName ? "Name can not be empty!": null ,
                        labelText: 'Name',
                        hintText: "Enter Name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                        fillColor: Colors.orangeAccent.withOpacity(0.1),
                        filled: true,
                        prefixIcon: const Icon(Icons.person)),
                  ),
                const SizedBox(height: 20,),
                  TextField(
                    onChanged: (text) {
                      setState(() {
                        _lastName=text;
                        if (_lastName=="")
                          _validateLastNamse=true;
                        else
                          _validateLastNamse=false;
                      });
                    },
                    decoration: InputDecoration(
                        errorText: _validateLastNamse ? "Last Name can not be empty!": null ,
                        labelText: 'Last Name',
                        hintText: "Enter Last Name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                        fillColor: Colors.orangeAccent.withOpacity(0.1),
                        filled: true,
                        prefixIcon: const Icon(Icons.person)),
                  ),
                  const SizedBox(height: 30,),
                  Container(
                    alignment: Alignment.bottomRight,
                    child: SizedBox(
                      width: 120,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyan,
                          shape: const BeveledRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(13))),
                        ),
                        onPressed: () {
                          print("$_validateLastNamse+ $_validateName+$_validateName");
                          if (!_validateUsername && !_validateName && !_validateLastNamse) {
                            checkSignUpUsername(_username);
                          }

                        },
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text("Next",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(width: 10,),
                            Icon(Icons.next_plan_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
              ),
            ),
            if (!_inf)
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
          ],
        ),
      ),
    );
  }

  void _readNfcTag() {
    setState(() {
      _statusMessage = "Bring your nfc tag close to the mobile...";
    });

    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      try {
        _statusMessage = "Tag detected successfully, wait for Login...";

        if (tag.data.containsKey('nfca')) {
          final tagId = tag.data['nfca']?['identifier'];
          if (tagId != null) {
            setState(() {
              _tagId = tagId.map((e) => e.toRadixString(16).padLeft(2, '0')).join(':').toUpperCase();
              if (_tagId!=""){
                checkSignUpNFCID(_tagId);
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
              //print (_tagId);
              if (_tagId!=""){
                checkSignUpNFCID(_tagId);
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
              //print (_tagId);
              if (_tagId!=""){
                checkSignUpNFCID(_tagId);
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
              //print (_tagId);
              if (_tagId!=""){
                checkSignUpNFCID(_tagId);
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

  checkSignUpUsername(String username) async {
    String res='';
    String request="checkSignUpUsername\n$username\u0000";
    var socket = await Socket.connect("192.168.1.107", 8080);
    socket.write(request);
    socket.flush();

    var subscription =socket.listen((response) {
      res+=String.fromCharCodes(response);
    });
    print(res);
    await subscription.asFuture<void>();
    if (res.contains("username is unavailable")) {
      setState(() {
        _checkUsername=true;
        _inf=true;
      });
    }
    else {
      setState(() {
        _checkUsername=false;
        _inf=false;
        _readNfcTag();
      });
    }
  }


  checkSignUpNFCID(String NFCID) async {
    String res='';
    String request="checkSignUpNFCID\n$NFCID\u0000";
    var socket = await Socket.connect("192.168.1.107", 8080);
    socket.write(request);
    socket.flush();

    var subscription =socket.listen((response) {
      res+=String.fromCharCodes(response);
    });
    await subscription.asFuture<void>();
    print(res);
    if (res.contains("NFC ID is unavailable")) {
      setState(() {
        _statusMessage="NFC ID is unavailable!";
      });
    }
    else {
      signUp(_tagId,_username,_name,_lastName);
    }
  }

  signUp(String NFCID,String username, String name, String lastName) async {
   // print("signup start");
    String res='';
    String request="signUp\n$NFCID#$username#$name#$lastName#\u0000";
    var socket = await Socket.connect("192.168.1.107", 8080);
    //print("start");
    socket.write(request);
    socket.flush();
    var subscription =socket.listen((response) {
      res+=String.fromCharCodes(response);
    });
    await subscription.asFuture<void>();
    if (res.contains("SignUp successfully!")) {
      setState(() {
        _inf=true;
        _validateName=true;
        _validateUsername=true;
        _validateLastNamse=true;
        _checkUsername=false;
      });
      Navigator.of(context).pop(context);
    }
  }

}