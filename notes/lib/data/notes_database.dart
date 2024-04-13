part of local_databases;

/// Class [NotesDatabase] saves user notes and its timestamps to the local storage.
///
/// Database class provides methods for managing notes in the local database.
class NotesDatabase {
  /// Saves all notes provided in the list to the local database.
  ///
  /// For each note, its content is stored in [boxNotes] and its timestamp is stored in [boxSynchronization].
  Future<void> saveAllNotes(List<Map<String, dynamic>> notes) async {
    for (var note in notes) {
      String noteId = note[NOTE_ID];
      String? content = note[CONTENT];
      int timestamp = note[NOTE_TIMESTAMP];
      await boxNotes.put(noteId, content);
      boxSynchronization.put(noteId, timestamp);
    }
  }

  /// Saves the note content and its update time to the local database.
  ///
  /// [noteId] is the ID of the note.
  /// [content] is the content of the note.
  /// [updateTime] is the time of the note's last update.
  void saveNote(String noteId, String content, int updateTime) {
    boxNotes.put(noteId, content);
    boxSynchronization.put(noteId, updateTime);
  }

  /// Changes the ID of a note from [oldId] to [newId] in the local database.
  ///
  /// The content of the note remains unchanged. Timestamp of the note is updated to the current time.
  Future<void> changeNoteId(String oldId, String newId) async {
    final data = await boxNotes.get(oldId);
    if (data != null) {
      await boxNotes.put(newId, data);
      await boxSynchronization.put(newId, DateTime.now().microsecondsSinceEpoch);
      await boxNotes.delete(oldId);
    }
  }

  /// Deletes the note with the given [noteId] from the local database.
  ///
  /// Removes the note's content from [boxNotes] and its timestamp from [boxSynchronization].
  Future<void> deleteNote(String noteId) async {
    boxNotes.delete(noteId);
    boxSynchronization.delete(noteId);
  }

  /// Retrieves the content of the note with the given [noteId] from the local database.
  ///
  /// Returns the content of the note if found, otherwise returns `null`.
  String? getNote(String noteId) {
    return boxNotes.get(noteId);
  }

  /// Updates the content of the note with the given [noteId] in the local database.
  ///
  /// The note's content is replaced with the provided [content].
  /// The timestamp of the note is updated to the current time.
  void updateNote(String noteId, String content) {
    boxNotes.put(noteId, content);
    boxSynchronization.put(noteId, DateTime.now().microsecondsSinceEpoch);
  }

  /// Creates a new note with the given [noteId] in the local database.
  ///
  /// The note is initialized with no content. The timestamp of the note is set to the current time.
  void createNote(String noteId) {
    boxNotes.put(noteId, null);
    boxSynchronization.put(noteId, DateTime.now().microsecondsSinceEpoch);
  }
}
