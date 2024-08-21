import 'dart:convert';

class Doc {
  String userId;
  String? id;
  String title;
  String? description;
  List<String>? files;

  Doc({
    required this.userId,
    this.id,
    required this.title,
    this.description,
    this.files,
  });

  void addFiles(String path) {
    files ??= [];
    files!.add(path);
  }


  Map<String, Object?> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'files': files != null ? jsonEncode(files) : null,
    };
  }

  factory Doc.fromMap(Map<String, dynamic> map) {
    return Doc(
      userId: map['userId'] as String,
      id: map['id'] as String?,
      title: map['title'] as String,
      description: map['description'] as String?,
      files: map['files'] != null
          ? List<String>.from(jsonDecode(map['files']))
          : null,
    );
  }
}
