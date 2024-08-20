import 'dart:typed_data';

import 'package:authentication/Doc.dart';
class User {
  String id;
  Uint8List? profile;
  List<Doc>? extra;

  User({
    required this.id,
    this.profile,
    this.extra,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'profile': profile,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      profile: map['profile'] as Uint8List,
    );
  }
}
