import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:authentication/Doc.dart';
import 'dart:io';
import 'package:flutter_pdfview/flutter_pdfview.dart';

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
        title: Text(
          doc.title,
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.cyan,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // بخش تایتل
              Container(
                margin: const EdgeInsets.only(bottom: 16.0), // اضافه کردن مارجین در پایین

                child: Text(
                  doc.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (doc.description != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Description:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      margin: const EdgeInsets.only(bottom: 16.0),

                      child: Text(
                        doc.description!,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              if (doc.files != null && doc.files!.isNotEmpty) ...[
                const Text(
                  'Attached Files:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildFilePreview(doc.files!, context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilePreview(String filePath, BuildContext context) {
    final file = File(filePath);
    final extension = filePath.split('.').last.toLowerCase();

    if (['png', 'jpg', 'jpeg', 'gif'].contains(extension)) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: Colors.grey.shade300),
        ),
        padding: const EdgeInsets.all(8.0),
        child: Image.file(file),
      );
    } else if (extension == 'pdf') {
      if (!file.existsSync()) {
        return Text(
          "File not found: ${file.path}",
          style: const TextStyle(color: Colors.red),
        );
      }
      return Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        height: 500,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: PDFView(
          filePath: file.path,
          enableSwipe: true,
          swipeHorizontal: true,
          autoSpacing: false,
          pageFling: true,
          onRender: (_pages) {
            print("PDF rendered with $_pages pages");
          },
          onError: (error) {
            print(error.toString());
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error displaying PDF')),
            );
          },
          onPageError: (page, error) {
            print('$page: ${error.toString()}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error on page $page')),
            );
          },
        ),
      );
    } else {
      return Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          "Unsupported file: ${file.path}",
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }
  }
}
