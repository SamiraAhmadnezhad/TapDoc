import 'dart:convert';
import 'dart:typed_data';
import 'package:authentication/Doc.dart';
import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart';

class User {
  String? name;
  String id;
  String? profile;
  List<Doc>? docs=[];
  String  key;
  bool isWritable;

  User({
    required this.isWritable,
    required this.id,
    this.profile,
    this.docs,
    this.name,
    required this.key,
  });

  addDoc(Doc doc){
    docs ??= [];
    docs!.add(doc);
  }

  Map<String, Object?> toMap() {
    final extractedIv;
    final extractedKey;
    final encrypter;
    if (isWritable==true){
       extractedIv = IV.fromBase64(key.substring(0, 24));
       extractedKey = Key.fromBase64(key.substring(24));
       encrypter = Encrypter(AES(extractedKey));
    }
    else{
      extractedKey = _generateAesKeyFromId(id);
      extractedIv = IV.fromUtf8(id.padRight(16, '0'));
      encrypter = Encrypter(AES(extractedKey));
    }

      return {
      'id': id,
      'profile': (profile!=null) ? base64.encode(encrypter.encrypt(profile!, iv: extractedIv).bytes): null,
        'name': (name!=null) ? base64.encode(encrypter.encrypt(name!, iv: extractedIv).bytes): null,
    };
  }

  Key _generateAesKeyFromId(String id) {
    final idBytes = utf8.encode(id);
    final digest = sha256.convert(idBytes);
    final keyBytes = Uint8List.fromList(digest.bytes.sublist(0, 32));
    return Key(keyBytes);
  }

}
