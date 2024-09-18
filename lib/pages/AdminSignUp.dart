import 'package:authentication/pages/Login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gif_view/gif_view.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminSignUp extends StatefulWidget {
  const AdminSignUp({super.key});

  @override
  State<AdminSignUp> createState() => _AdminSignUpState();
}

class _AdminSignUpState extends State<AdminSignUp> {
  String _statusMessage = "";
  bool _isNfcReading = false;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            if (_isNfcReading) {
              _readNfcTag();
            }
          },
          icon: const Icon(
            CupertinoIcons.refresh,
            color: Colors.white,
          ),
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
              _isNfcReading
                  ? Column(
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
                  : Column(
                children: [
                  SizedBox(height: mediaQuery.size.height * 0.1),
                  Container(
                    alignment: Alignment.center,
                    height: 50,
                    width: mediaQuery.size.width * 0.6,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: const BeveledRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(13),
                          ),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _isNfcReading = true;
                        });
                        _readNfcTag();
                      },
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            "SignUp Admin",
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
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _setAdminStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAdminSet', true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
    );
  }

  Future<void> _setAdminTagId(String tagId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('adminTagId', tagId);
  }

  void _readNfcTag() {
    setState(() {
      _statusMessage = "Bring your NFC tag close to the mobile...";
    });
    String tagIdHex = "";
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      try {
        setState(() {
          _statusMessage = "Tag detected successfully, wait for check...";
        });
        if (tag.data.containsKey('nfca')) {
          final tagId = tag.data['nfca']?['identifier'];
          if (tagId != null) {
            tagIdHex = tagId.map((e) => e.toRadixString(16).padLeft(2, '0')).join(':').toUpperCase();
            if (tagIdHex.isNotEmpty) {
              await _setAdminTagId(tagIdHex);
              await _setAdminStatus();
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
}
