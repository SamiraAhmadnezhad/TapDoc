import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

class Doc {
  String userId;
  String title;
  String? description;
  String? files;

  Doc({
    required this.userId,
    required this.title,
    this.description,
    this.files,
  });

  Map<String, Object?> toMap(String key,bool isWritable) {
    final extractedIv;
    final extractedKey;
    final encrypter;
    if (isWritable==true){
      extractedIv = IV.fromBase64(key.substring(0, 24));
      extractedKey = Key.fromBase64(key.substring(24));
      encrypter = Encrypter(AES(extractedKey));
    }
    else{
      extractedKey = _generateAesKeyFromId(userId);
      extractedIv = IV.fromUtf8(userId.padRight(16, '0'));
      encrypter = Encrypter(AES(extractedKey));
    }
    return {
      'userId': userId,
      'title': (title!=null) ? base64.encode(encrypter.encrypt(title!, iv: extractedIv).bytes) : null,
      'description': (description!=null) ? base64.encode(encrypter.encrypt(description!, iv: extractedIv).bytes) : null,
      'files': (files!=null) ?base64.encode(encrypter.encrypt(files!, iv: extractedIv).bytes) : null,
    };
  }

  Key _generateAesKeyFromId(String id) {
    final idBytes = utf8.encode(id);
    final digest = sha256.convert(idBytes);
    final keyBytes = Uint8List.fromList(digest.bytes.sublist(0, 32));
    return Key(keyBytes);
  }



}
