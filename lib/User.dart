import 'dart:typed_data';

import 'package:authentication/Doc.dart';
class User {
  String id;
  String? profile;
  List<Doc>? docs=[];

  User({
    required this.id,
    this.profile,
    this.docs,
  });

  addDoc(Doc doc){
    docs ??= [];
    docs!.add(doc);
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'profile': profile,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      profile: map['profile'] as String,
    );
  }
}
