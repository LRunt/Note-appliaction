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
    int? lastChangeTime = boxSynchronization.get(LAST_CHANGE);
    if (lastChangeTime == null) {
      return 0;
    } else {
      return lastChangeTime;
    }
  }

  int? getLastSyncTime() {
    return boxSynchronization.get(LOCAL_SYNC);
  }
}
