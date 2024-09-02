
import 'package:authentication/User.dart';
import 'package:authentication/repository/UserRepository.dart';
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
    _readNfcTag();
  }
  String _statusMessage = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
    String tagIdHex = "";
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      try {
        _statusMessage = "Tag detected successfully, wait for check...";
        print(tag.data);
        if (tag.data.containsKey('nfca')) {
          final tagId = tag.data['nfca']?['identifier'];
          if (tagId != null) {
            tagIdHex = tagId.map((e) => e.toRadixString(16).padLeft(2, '0')).join(':').toUpperCase();
            if (tagIdHex!=""){
              _insertUser(tagIdHex);
            }
          } else {
            setState(() {
              _statusMessage="Tag not detect!";
            });
          }
        } else if (tag.data.containsKey('nfcb')) {
          final tagId = tag.data['nfcb']?['identifier'];
          if (tagId != null) {
            setState(() {
              tagIdHex = tagId.map((e) => e.toRadixString(16).padLeft(2, '0')).join(':').toUpperCase();
              //print (_tagId);
              if (tagIdHex!=""){
                _insertUser(tagIdHex);
              }
            });
          } else {
            setState(() {
              _statusMessage="Tag not detect!";
            });
          }
        } else if (tag.data.containsKey('nfcf')) {
          final tagId = tag.data['nfcf']?['identifier'];
          if (tagId != null) {
            setState(() {
              tagIdHex = tagId.map((e) => e.toRadixString(16).padLeft(2, '0')).join(':').toUpperCase();
              //print (_tagId);
              if (tagIdHex!=""){
                _insertUser(tagIdHex);
              }
            });
          } else {
            setState(() {
              _statusMessage="Tag not detect!";
            });
          }
        }else if (tag.data.containsKey('nfcv')) {
          final tagId = tag.data['nfcv']?['identifier'];
          if (tagId != null) {
            setState(() {
              tagIdHex = tagId.map((e) => e.toRadixString(16).padLeft(2, '0')).join(':').toUpperCase();
              //print (_tagId);
              if (tagIdHex!=""){
                _insertUser(tagIdHex);
              }
            });
          } else {
            setState(() {
              _statusMessage="Tag not detect!";
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

  Future<String> _insertUser(String id) async{
    bool? checkUser=await UserRepository.checkUserById(id);
    String privateKey="";
    if (checkUser==false){
      privateKey = await UserRepository.insert(id);
      print("write key : " + privateKey);
      setState(() {
        _statusMessage="please bring your nfc tag close to the mobile again ... ";
      });
      _writeNfcTag(privateKey);
    }
    else{
      setState(() {
        _statusMessage="User is already exist";
      });
    }
    return privateKey;
  }


  void _writeNfcTag(String record) {
    setState(() {
      _statusMessage = "Starting NFC write session...";
    });
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {

      var ndef = Ndef.from(tag);
      print(record);
      if (ndef != null && ndef.isWritable) {
        NdefRecord ndefRecord = NdefRecord.createText(record);
        NdefMessage message = NdefMessage([ndefRecord]);

        try {
          await ndef.write(message);
          setState(() {
            _statusMessage = "Write successful!";
          });

        } catch (e) {
          setState(() {
            _statusMessage = "Error while writing to tag: $e";
          });
        }
      } else {
        setState(() {
          _statusMessage = "Tag is not writable.";
        });
      }

      NfcManager.instance.stopSession();
    }).catchError((error) {
      setState(() {
        _statusMessage = "Error starting NFC session: $error";
      });
      NfcManager.instance.stopSession();
    });
  }

}