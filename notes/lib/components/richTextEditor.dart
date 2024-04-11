import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'dart:developer';

import 'package:notes/data/notesDatabase.dart';

/// Class [RichTextEditor] creates rich text editor from the flutter_quill library.
class RichTextEditor extends StatefulWidget {
  /// Id of the note what will be loaded and edited.
  final String noteId;

  /// Constrictor of the [RichTextEditor] class.
  const RichTextEditor({super.key, required this.noteId});

  /// States of the [RichTextEditor].
  @override
  State<RichTextEditor> createState() => _RichTextEditorState();
}

/// Class [_RichTextEditorState] represents states of the [RichTextEditor].
class _RichTextEditorState extends State<RichTextEditor> {
  /// Controller of the rich text editor.
  QuillController _controller = QuillController.basic();

  NotesDatabase notesDatabase = NotesDatabase();

  late bool _controlsVisible;

  /// Inicialization of the class.
  /// Loading the note and adding a listener to save every change.
  @override
  void initState() {
    log("initializing rich text editor");
    super.initState();
    _loadDocument();
    _controller.addListener(_saveDocument);
    _controlsVisible = true;
  }

  /// Disposing when rich text editor is removed.
  @override
  void dispose() {
    _controller.removeListener(_saveDocument);
    _controller.dispose();
    super.dispose();
  }

  void showControls() {
    setState(() {
      _controlsVisible = !_controlsVisible;
    });
  }

  /// Loading content of the note with [widget.noteId].
  void _loadDocument() async {
    log("Loading new state");
    final documentJson = notesDatabase.getNote(widget.noteId);
    if (documentJson != null) {
      final document = Document.fromJson(jsonDecode(documentJson));
      _controller =
          QuillController(document: document, selection: const TextSelection.collapsed(offset: 0));
    } else {
      _controller = QuillController.basic();
    }
  }

  /// Saving content of the note.
  void _saveDocument() {
    var json = jsonEncode(_controller.document.toDelta().toJson());
    //log("Saving data: $json");
    notesDatabase.updateNote(widget.noteId, json);
    //boxNotes.put(widget.noteId, json);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          if (_controlsVisible)
            QuillToolbar.simple(
                configurations: QuillSimpleToolbarConfigurations(controller: _controller)),
          Expanded(
            child: QuillEditor.basic(
              configurations: QuillEditorConfigurations(
                  controller: _controller,
                  padding: const EdgeInsets.all(10),
                  readOnly: false,
                  autoFocus: true,
                  scrollable: true),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showControls();
        },
        child: _controlsVisible ? const Icon(Icons.arrow_upward) : const Icon(Icons.arrow_downward),
      ),
    );
  }
}
