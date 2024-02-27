import 'package:notes/boxes.dart';
import 'package:notes/services/firebaseService.dart';

class NotesDatabase {
  final FirebaseService _firebaseService = FirebaseService();

  void saveAllNotes() async {
    List<Map<String, dynamic>> notes = await _firebaseService.getAllNotes();
    for (var note in notes) {
      String noteId = note['noteId'];
      String content = note['content'];
      await boxNotes.put(noteId, content);
    }
  }
}
