import 'dart:typed_data';
import 'package:authentication/Doc.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:rsa_encrypt/rsa_encrypt.dart';

class User {
  String id;
  String? profile;
  List<Doc>? docs=[];
  String  publicKey;
  String  privateKey;

  User({
    required this.id,
    this.profile,
    this.docs,
    required this.publicKey,
    required this.privateKey,
  });

  addDoc(Doc doc){
    docs ??= [];
    docs!.add(doc);
  }

  Map<String, Object?> toMap() {
      return {
      'id': id,
      'profile': (profile!=null) ? encrypt(profile!,pemToPublicKey(publicKey)) : null,
      'publicKey' : publicKey,
        'privateKey' : privateKey,
    };
  }
  //pem to public key
  static RSAPublicKey pemToPublicKey(String pem) {
    var helper = RsaKeyHelper();
    return helper.parsePublicKeyFromPem(pem);
  }
}
