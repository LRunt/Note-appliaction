part of local_databases;

/// Class [SynchronizationDatabase] manages synchronization-related data in the local storage.
///
/// This database class provides methods for handling synchronization data such as sync times,
/// note content, and update times in the local database.
class SynchronizationDatabase {
  /// Updates the synchronization time in the local database.
  ///
  /// [syncTime] is the time of synchronization to be saved.
  void saveLastSyncTime(int syncTime) {
    boxSynchronization.put(LOCAL_SYNC, syncTime);
  }

  /// Retrieves the last synchronization time from the local database.
  ///
  /// Returns the last synchronization time as an integer, or `null` if not found.
  int? getLastSyncTime() {
    return boxSynchronization.get(LOCAL_SYNC);
  }

  /// Retrieves the last hierarchy change time from the local database.
  ///
  /// Returns the last hierarchy change time as an integer.
  int getLastHierarchyChangeTime() {
    int? lastChangeTime = boxSynchronization.get(LAST_CHANGE);
    if (lastChangeTime == null) {
      return 0;
    } else {
      return lastChangeTime;
    }
  }

  /// Retrieves the last change time for a specific note from the local database.
  ///
  /// [id] is the ID of the note.
  /// Returns the last change time for the note as an integer.
  int getLastNoteChangeTime(String id) {
    int? lastChangeTime = boxSynchronization.get(id);
    if (lastChangeTime != null) {
      return boxSynchronization.get(id);
    } else {
      return 0;
    }
  }
}
