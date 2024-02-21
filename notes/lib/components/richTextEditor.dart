import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class RichTextEditor extends StatefulWidget {
  const RichTextEditor({super.key});

  @override
  State<RichTextEditor> createState() => _RichTextEditorState();
}

class _RichTextEditorState extends State<RichTextEditor> {
  QuillController _controller = QuillController.basic();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        QuillToolbar.simple(configurations: QuillSimpleToolbarConfigurations(controller: _controller)),
        QuillEditor.basic(configurations: QuillEditorConfigurations(controller: _controller))
      ],
    );
  }
}
