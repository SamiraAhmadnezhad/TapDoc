import 'dart:convert';
import 'package:pointycastle/export.dart';
import 'package:rsa_encrypt/rsa_encrypt.dart';

class Doc {
  String userId;
  String? id;
  String title;
  String? description;
  String? files;

  Doc({
    required this.userId,
    this.id,
    required this.title,
    this.description,
    this.files,
  });

  Map<String, Object?> toMap(String key) {
    return {
      'id': (id!=null) ? encrypt(id!,pemToPublicKey(key)) : null,
      'userId': userId,
      'title': (title!=null) ? encrypt(title!,pemToPublicKey(key)) : null,
      'description': (description!=null) ? encrypt(description!,pemToPublicKey(key)) : null,
      'files': (files!=null) ? encrypt(files!,pemToPublicKey(key)) : null,
    };
  }

  //pem to public key
  static RSAPublicKey pemToPublicKey(String pem) {
    var helper = RsaKeyHelper();
    return helper.parsePublicKeyFromPem(pem);
  }



}
