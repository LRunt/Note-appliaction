import 'package:flutter/material.dart';

class FileListViewTile extends StatelessWidget {
  final bool isNote;
  final String fileName;

  const FileListViewTile(
      {super.key, required this.isNote, required this.fileName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.folder),
          Text(fileName),
        ],
      ),
    );
  }
}
