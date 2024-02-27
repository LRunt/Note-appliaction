import 'package:notes/boxes.dart';

class ClearDatabase {
  void clearAllData() async {
    await boxHierachy.clear();
    await boxNotes.clear();
    await boxUser.clear();
    await boxSynchronization.clear();
  }

  void clearNoteData() async {
    await boxNotes.clear();
  }
}
