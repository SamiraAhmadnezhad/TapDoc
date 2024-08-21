import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:authentication/Doc.dart';

class DocDetailsPage extends StatelessWidget {
  final Doc doc;

  const DocDetailsPage({super.key, required this.doc});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            CupertinoIcons.back,
            color: Colors.white,
          ),
        ),
        title: Text(doc.title,
        style: TextStyle(
          color: Colors.white
        ),),
        backgroundColor: Colors.cyan,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              doc.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (doc.description != null)
              Text(
                doc.description!,
                style: TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 16),
            if (doc.files != null && doc.files!.isNotEmpty)
              Text(
                "File: ${doc.files!.first}",
                style: TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}
