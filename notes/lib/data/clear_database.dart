part of local_databases;

/// Manages the clearing of stored data within the application's local database.
///
/// Provides methods to clear data from various Hive boxes, which are used to store
/// different types of application data such as hierarchy structures, notes, and user settings.
class ClearDatabase {
  /// Clears all stored data from the application's database.
  ///
  /// This method clears data across all categories including hierarchy structures,
  /// notes, user preferences, and synchronization data. It is typically used for
  /// resetting the application or during major updates that require a clean state.
  Future<void> clearAllData() async {
    await boxHierachy.clear();
    await boxNotes.clear();
    await boxUser.clear();
    await boxSynchronization.clear();
    HierarchyDatabase.noteList = [];
    HierarchyDatabase.rootList = [];
    HierarchyDatabase.roots = [];
    HierarchyDatabase.conflictData = [];
  }

  /// Clears data related to the hierarchy structures from the database.
  ///
  /// Targets only the data stored in the hierarchy box, making it useful for
  /// specific reset operations related to app content structure.
  Future<void> clearHierarchyStructure() async {
    await boxHierachy.clear();
  }

  /// Clears all note-related data from the database.
  ///
  /// Focuses on clearing entries from the notes box, effectively removing all stored notes.
  Future<void> clearNoteData() async {
    await boxNotes.clear();
  }

  /// Clears user-specific data and preferences from the database.
  ///
  /// This action deletes all information held in the user preferences box, suitable
  /// for privacy resets or preparing the app for a new user.
  Future<void> clearUserData() async {
    await boxUser.clear();
  }

  /// Clears synchronization timestamps from the database.
  ///
  /// Removes all entries related to synchronization times, useful for troubleshooting
  /// or resetting sync mechanisms.
  Future<void> clearSyncTimes() async {
    await boxSynchronization.clear();
  }
}
