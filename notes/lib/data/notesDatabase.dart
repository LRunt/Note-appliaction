import 'package:notes/boxes.dart';
//import 'package:notes/services/firebaseService.dart';

class NotesDatabase {
  void saveAllNotes(List<Map<String, dynamic>> notes) async {
    for (var note in notes) {
      String noteId = note['noteId'];
      String content = note['content'];
      await boxNotes.put(noteId, content);
    }
  }

  void changeNoteId(String oldId, String newId) async {
    final data = boxNotes.get(oldId);
    if (data != null) {
      await boxNotes.put(newId, data);
      await boxNotes.delete(oldId);
    }
  }

  void deleteNote(String noteId) async {
    await boxNotes.delete(noteId);
  }

  String? getNote(String noteId) {
    return boxNotes.get(noteId);
  }

  void updateNote(String noteId, String content) {
    boxNotes.put(noteId, content);
    boxSynchronization.put(noteId, DateTime.now().microsecondsSinceEpoch);
  }

  void createNote(String noteId) async {
    await boxNotes.put(noteId, null);
    await boxSynchronization.put(noteId, DateTime.now().microsecondsSinceEpoch);
  }
}
