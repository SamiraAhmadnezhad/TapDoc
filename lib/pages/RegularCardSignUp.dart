import 'package:authentication/User.dart';
import 'package:authentication/repository/UserRepository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gif_view/gif_view.dart';
import 'package:nfc_manager/nfc_manager.dart';

class RegularCardSignUp extends StatefulWidget{
  const RegularCardSignUp({super.key});

  @override
  State<RegularCardSignUp> createState() => _RegularCardSignUpState ();
}

class _RegularCardSignUpState extends State<RegularCardSignUp> {
  @override
  void initState() {
    super.initState();
    _readNfcTag();
  }

  String _statusMessage = "";

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to make layout responsive
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
        ),
        title: const Text(
          "NFC",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.cyan.shade600,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: mediaQuery.size.width * 0.1,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: mediaQuery.size.height * 0.05),
              Container(
                alignment: Alignment.center,
                height: mediaQuery.size.height * 0.2,
                child: Image.asset("assets/images/hamrah.png"),
              ),
              SizedBox(height: mediaQuery.size.height * 0.02),
              Container(
                alignment: Alignment.center,
                child: const Text(
                  "Hamrah Aval",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              SizedBox(height: mediaQuery.size.height * 0.05),
              Column(
                children: [
                  GifView.asset(
                    'assets/gifs/gif1.gif',
                    height: mediaQuery.size.height * 0.4,
                    width: mediaQuery.size.width * 0.8,
                    frameRate: 30,
                  ),
                  SizedBox(height: mediaQuery.size.height * 0.03),
                  Text(
                    _statusMessage,
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
      ),
    );
  }

  void _readNfcTag() {
    setState(() {
      _statusMessage = "Bring your NFC tag close to the mobile...";
    });
    String tagIdHex = "";
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      try {
        _statusMessage = "Tag detected successfully, wait for check...";
        if (tag.data.containsKey('nfca')) {
          final tagId = tag.data['nfca']?['identifier'];
          if (tagId != null) {
            tagIdHex = tagId.map((e) => e.toRadixString(16).padLeft(2, '0')).join(':').toUpperCase();
            if (tagIdHex.isNotEmpty) {
              _insertUser(tagIdHex);
            }
          } else {
            setState(() {
              _statusMessage = "Tag not detected!";
            });
          }
        } else if (tag.data.containsKey('nfcb')) {
          final tagId = tag.data['nfcb']?['identifier'];
          if (tagId != null) {
            tagIdHex = tagId.map((e) => e.toRadixString(16).padLeft(2, '0')).join(':').toUpperCase();
            if (tagIdHex.isNotEmpty) {
              _insertUser(tagIdHex);
            }
          } else {
            setState(() {
              _statusMessage = "Tag not detected!";
            });
          }
        } else if (tag.data.containsKey('nfcf')) {
          final tagId = tag.data['nfcf']?['identifier'];
          if (tagId != null) {
            tagIdHex = tagId.map((e) => e.toRadixString(16).padLeft(2, '0')).join(':').toUpperCase();
            if (tagIdHex.isNotEmpty) {
              _insertUser(tagIdHex);
            }
          } else {
            setState(() {
              _statusMessage = "Tag not detected!";
            });
          }
        } else if (tag.data.containsKey('nfcv')) {
          final tagId = tag.data['nfcv']?['identifier'];
          if (tagId != null) {
            tagIdHex = tagId.map((e) => e.toRadixString(16).padLeft(2, '0')).join(':').toUpperCase();
            if (tagIdHex.isNotEmpty) {
              _insertUser(tagIdHex);
            }
          } else {
            setState(() {
              _statusMessage = "Tag not detected!";
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

  Future<String> _insertUser(String id) async {
    bool? checkUser = await UserRepository.checkUserById(id);
    String privateKey = "";
    if (checkUser == false) {
      await UserRepository.insertRegular(id);
      setState(() {
        _statusMessage = "SignUp successful!";
      });
    } else {
      setState(() {
        _statusMessage = "User already exists";
      });
    }
    return privateKey;
  }


}
