import 'package:notes/boxes.dart';

/// `ClearDatabase` provides methods to clear Hive boxes, so the data in the application's local database.
///
/// This class provides some methods to clear storage form necesery data.
///
/// Author: Lukas Runt
/// Date: 2024-02-27
/// Version: 1.0.0
class ClearDatabase {
  /// Clears all data from the application database.
  ///
  /// This method asynchronously clears all stored data by calling individual
  /// clear methods for hierarchy structures, notes, user data, and synchronization timestamps.
  void clearAllData() async {
    await boxHierachy.clear();
    await boxNotes.clear();
    await boxUser.clear();
    await boxSynchronization.clear();
  }

  /// Clears only the hierarchy structure data from the application database.
  void clearHierarchyStructure() async {
    await boxHierachy.clear();
  }

  /// Clears all note data from the application database.
  void clearNoteData() async {
    await boxNotes.clear();
  }

  /// Clears all user data and preferences from the application database.
  void clearUserData() async {
    await boxUser.clear();
  }

  /// Clears all timestamps of synchronization from the application database.
  void clearSyncTimes() async {
    await boxSynchronization.clear();
  }
}
