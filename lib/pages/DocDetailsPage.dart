import 'package:authentication/User.dart';
import 'package:authentication/pages/EditDocPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:authentication/Doc.dart';
import 'dart:io';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:just_audio/just_audio.dart';

class DocDetailsPage extends StatefulWidget {
  final Doc doc;
  final User user;

  const DocDetailsPage({super.key, required this.doc, required this.user});

  @override
  _DocDetailsPageState createState() => _DocDetailsPageState();
}

class _DocDetailsPageState extends State<DocDetailsPage> {
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

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
          widget.doc.title,
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.cyan,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () async {
              final updatedDoc = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditDocPage(
                    doc: widget.doc,
                    user: widget.user,
                  ),
                ),
              );

              if (updatedDoc != null) {
                setState(() {
                  widget.doc.title = updatedDoc.title;
                  widget.doc.description = updatedDoc.description;
                });
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.doc.description != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Description:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        widget.doc.description!,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              if (widget.doc.files != null && widget.doc.files!.isNotEmpty) ...[
                const Text(
                  'Attached Files:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildFilePreview(widget.doc.files!, context),
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
    final screenHeight = MediaQuery.of(context).size.height;

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
        height: screenHeight * 0.6,
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
    } else if (['mp3', 'wav', 'm4a'].contains(extension)) {
      return _buildAudioPlayer(filePath);
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
  Widget _buildAudioPlayer(String filePath) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          const Text(
            "Audio File",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          StreamBuilder<Duration?>(
            stream: _audioPlayer.positionStream,
            builder: (context, positionSnapshot) {
              final position = positionSnapshot.data ?? Duration.zero;
              final duration = _audioPlayer.duration;

              String remaining = "";
              if (duration != null) {
                final remainingDuration = duration - position;
                remaining = "${remainingDuration.inMinutes}:${(remainingDuration.inSeconds % 60).toString().padLeft(2, '0')}";
              } else {
                remaining = "Calculating...";
              }

              return Column(
                children: [
                  Slider(
                    value: position.inSeconds.toDouble(),
                    min: 0.0,
                    max: duration?.inSeconds.toDouble() ?? 0.0,
                    onChanged: (value) {
                      _audioPlayer.seek(Duration(seconds: value.toInt()));
                    },
                  ),
                  Text(
                    "Current Position: ${position.inMinutes}:${(position.inSeconds % 60).toString().padLeft(2, '0')}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    "Remaining: $remaining",
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.play_arrow),
                onPressed: () async {
                  await _audioPlayer.setFilePath(filePath);
                  _audioPlayer.play();
                },
              ),
              IconButton(
                icon: const Icon(Icons.pause),
                onPressed: () {
                  _audioPlayer.pause();
                },
              ),
              IconButton(
                icon: const Icon(Icons.stop),
                onPressed: () {
                  _audioPlayer.stop();
                },
              ),
              IconButton(
                icon: const Icon(Icons.skip_next),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }



}