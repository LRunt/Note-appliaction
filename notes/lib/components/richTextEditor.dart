import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:notes/boxes.dart';

class RichTextEditor extends StatefulWidget {
  final String noteId;

  const RichTextEditor({super.key, required this.noteId});

  @override
  State<RichTextEditor> createState() => _RichTextEditorState();
}

class _RichTextEditorState extends State<RichTextEditor> {
  QuillController _controller = QuillController.basic();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_saveDocument);
    _loadDocument();
  }

  @override
  void dispose() {
    _controller.removeListener(_saveDocument);
    _controller.dispose();
    super.dispose();
  }

  void _loadDocument() async {
    final documentJson = boxNotes.get(widget.noteId);
    if (documentJson != null) {
      final document = Document.fromJson(jsonDecode(documentJson));
      _controller = QuillController(
          document: document,
          selection: const TextSelection.collapsed(offset: 0));
    }
  }

  void _saveDocument() {
    var json = jsonEncode(_controller.document.toDelta().toJson());
    boxNotes.put(widget.noteId, json);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        QuillToolbar.simple(
            configurations:
                QuillSimpleToolbarConfigurations(controller: _controller)),
        QuillEditor.basic(
            configurations: QuillEditorConfigurations(controller: _controller))
      ],
    );
  }
}
