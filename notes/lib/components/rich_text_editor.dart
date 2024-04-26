part of components;

/// A rich text editor widget for creating and editing notes.
///
/// This widget uses the flutter_quill library to provide a rich text editing experience.
///
/// Usage Example:
/// ```dart
/// final editor = RichTextEditor(noteId: 'note_1');
/// ```
class RichTextEditor extends StatefulWidget {
  /// Id of the note what will be loaded and edited.
  final String noteId;

  /// Constrictor of the [RichTextEditor] class.
  ///
  /// Required:
  /// - [noteId] a Id of the note.
  const RichTextEditor({
    super.key,
    required this.noteId,
  });

  /// States of the [RichTextEditor].
  @override
  State<RichTextEditor> createState() => _RichTextEditorState();
}

/// Class [_RichTextEditorState] represents states of the [RichTextEditor].
class _RichTextEditorState extends State<RichTextEditor> {
  /// Controller of the rich text editor.
  QuillController _controller = QuillController.basic();

  /// Instance of [NotesDatabase] for managing note data.
  NotesDatabase notesDatabase = NotesDatabase();

  // Is the controls visible or not.
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

  /// Toggles the visibility of editing controls.
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

  /// Builds the UI of the [RichTextEditor].
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
