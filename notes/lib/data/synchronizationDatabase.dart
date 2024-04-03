import 'package:notes/assets/constants.dart';
import 'package:notes/boxes.dart';

class SynchronizationDatabase {
  void synchronization(int syncTime) {
    boxSynchronization.put(LOCAL_SYNC, syncTime);
  }

  void saveNote(String noteId, String content, int updateTime) {
    boxNotes.put(noteId, content);
    boxSynchronization.put(noteId, updateTime);
  }

  int getLastTreeChangeTime() {
    return boxSynchronization.get(TREE_CHANGE);
  }

  int getLastSyncTime() {
    return boxSynchronization.get(LOCAL_SYNC);
  }
}
