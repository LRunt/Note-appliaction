part of services;

/// Service class for interacting with Firestore database.
class FirestoreService extends ChangeNotifier {
  /// Instance of FirebaseAuth for authentication.
  final FirebaseAuth auth;

  /// Instance of FirebaseFirestore for Firestore database operations.
  final FirebaseFirestore fireStore;

  /// Database instance for managing hierarchy data.
  HierarchyDatabase hierarchyDatabase = HierarchyDatabase();

  /// Database instance for managing notes data.
  NotesDatabase notesDatabase = NotesDatabase();

  /// Database instance for managing synchronization data.
  SynchronizationDatabase syncDatabase = SynchronizationDatabase();

  /// Constructor for FirestoreService.
  ///
  /// Required:
  /// - [auth] is the instance of FirebaseAuth.
  /// - [fireStore] is the instance of FirebaseFirestore.
  FirestoreService({required this.auth, required this.fireStore});

  /// Checks if a user is logged in.
  ///
  /// Returns `true` if a user is logged in, otherwise `false`.
  bool isLoggedIn() {
    return auth.currentUser != null;
  }

  /// Synchronizes data between local and cloud databases.
  ///
  /// Returns a string indicating the synchronization status.
  Future<String> synchronize(BuildContext context) async {
    ComponentUtils.showDefaultToast(AppLocalizations.of(context)!.synchronizingStart);
    if (isLoggedIn()) {
      String userId = auth.currentUser!.uid;
      try {
        var documentSnapshot = await fireStore.collection(userId).doc(FIREBASE_LAST_SYNC).get();
        // if the user have data on account, but he is connected first time -> upload all data
        if (documentSnapshot.exists) {
          if (!boxSynchronization.containsKey(LOCAL_SYNC) ||
              boxSynchronization.get(LOCAL_SYNC) == null) {
            // If there are no prevous synchronization -> download all data
            log("Downloading data");
            await downloadAllData();
          } else {
            log("document exist");
            Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
            var lastSyncCloud = data[LAST_SYNC_FIELD];
            log("Cloud sync: $lastSyncCloud");
            var lastSyncLocal = boxSynchronization.get(LOCAL_SYNC);
            log("Local sync: $lastSyncLocal");
            // Last synchronization was from actual device -> upload changes
            if (lastSyncCloud == lastSyncLocal) {
              log("same time sync");
              await uploadAllData();
            } else {
              // Last synchronization wasnt form actual device -> check versions, resolve conflicts
              log("different time sync");
              await resolveConflicts(lastSyncLocal, lastSyncCloud, context);
            }
          }
        } else {
          log("Document does not exist");
          await uploadAllData();
        }
        ComponentUtils.showSuccesToast(AppLocalizations.of(context)!.synchronizingSuccess);
        return "Succes";
      } catch (e) {
        ComponentUtils.showErrorToast(AppLocalizations.of(context)!.synchronizingFailed);
        log("Error fetching document: $e");
        return "$e";
      }
    } else {
      ComponentUtils.showErrorToast(AppLocalizations.of(context)!.notLogged);
      return "not-logged-user";
    }
  }

  /// Uploads all data to the cloud.
  ///
  /// This method saves root nodes, notes, and sync time to the cloud Firestore database.
  Future<void> uploadAllData() async {
    await saveRoots();
    await saveAllNotes();
    var now = DateTime.now().microsecondsSinceEpoch;
    await saveSyncTime(now);
    syncDatabase.saveLastSyncTime(now);
  }

  /// Downloads all data from the cloud.
  ///
  /// This method retrieves root nodes, notes, sync time, and all notes from the cloud Firestore database
  /// and saves them locally in the hierarchy and notes databases.
  Future<void> downloadAllData() async {
    await downloadRoots();
    List notes = await getNoteList();
    hierarchyDatabase.saveNoteList(notes);
    int syncTime = await getSyncTime();
    log("Sync time: $syncTime");
    syncDatabase.saveLastSyncTime(syncTime);
    // Save notes
    List<Map<String, dynamic>> allNotes = await getAllNotes();
    notesDatabase.saveAllNotes(allNotes);
  }

  /// Resolves conflicts between local and cloud data.
  ///
  /// This method compares the synchronization times between local and cloud data
  /// to determine the appropriate synchronization strategy. It synchronizes roots and notes
  /// based on the comparison results and handles conflicts if detected.
  ///
  /// [localTimeSync] The local synchronization time.
  /// [cloudTimeSync] The cloud synchronization time.
  Future<void> resolveConflicts(int localTimeSync, int cloudTimeSync, BuildContext context) async {
    int treeChangeTimeCloud = await getUpdateTime();
    int treeChangeTimeLocal = syncDatabase.getLastHierarchyChangeTime();
    if (localTimeSync > treeChangeTimeCloud && localTimeSync > treeChangeTimeLocal) {
      // Only synchronize notes, because hierarchy is not changed
      List notes = await getUserNoteList();
      synchronizeNotes(notes, localTimeSync, context);
    } else if (localTimeSync > treeChangeTimeLocal) {
      List roots = await getUserRoots();
      synchronizeRoots(roots, localTimeSync, context);
      List notes = await getUserNoteList();
      synchronizeNotes(notes, localTimeSync, context);
    } else if (localTimeSync > treeChangeTimeCloud) {
      // Local or cloud is not changed
      List roots = hierarchyDatabase.getRootList();
      saveRoots();
      synchronizeRoots(roots, localTimeSync, context);
      List notes = hierarchyDatabase.getNoteList();
      synchronizeNotes(notes, localTimeSync, context);
    } else {
      // Conflict
      ComponentUtils.showWarningToast(AppLocalizations.of(context)!.synchronizationConflict);
      hierarchyDatabase.saveConflictData();
      downloadAllData();
    }
    var now = DateTime.now().microsecondsSinceEpoch;
    await saveSyncTime(now);
    syncDatabase.saveLastSyncTime(now);
  }

  /// Retrieves the list of root nodes associated with the current user from Firestore.
  ///
  /// This method fetches the root nodes stored in the Firestore database for the current user.
  ///
  /// Returns a Future that resolves to a List containing the IDs of the root nodes,
  /// or an empty List if no root nodes are found or an error occurs.
  Future<List> getUserRoots() async {
    String userId = auth.currentUser!.uid;
    var documentSnapshot = await fireStore.collection(userId).doc(FIREBASE_TREE_PROPERTIES).get();
    if (documentSnapshot.exists) {
      return documentSnapshot.get(FIREBASE_ROOT_LIST);
    } else {
      log("Document does not exist");
      return [];
    }
  }

  /// Retrieves the list of user notes associated with the current user from Firestore.
  ///
  /// This method fetches the user notes stored in the Firestore database for the current user.
  ///
  /// Returns a Future that resolves to a List containing the IDs of the user notes,
  /// or an empty List if no user notes are found or an error occurs.
  Future<List> getUserNoteList() async {
    String userId = auth.currentUser!.uid;
    var documentSnapshot = await fireStore.collection(userId).doc(FIREBASE_TREE_PROPERTIES).get();
    if (documentSnapshot.exists) {
      return documentSnapshot.get(NOTES_LIST);
    } else {
      log("Document does not exist");
      return [];
    }
  }

  /// Synchronizes the root nodes between the local database and Firestore.
  ///
  /// This method synchronizes the root nodes stored in the local database with
  /// their corresponding data in the Firestore database. It compares the local
  /// and cloud versions of each root node to detect conflicts and resolve them
  /// accordingly.
  ///
  /// [rootIds] is a List containing the IDs of the root nodes to synchronize.
  /// [localTimeSync] is the local timestamp representing the synchronization time.
  ///
  /// Throws an error if there's an issue during synchronization.
  Future<void> synchronizeRoots(List rootIds, int localTimeSync, BuildContext context) async {
    String userId = auth.currentUser!.uid;
    hierarchyDatabase.saveRootList(rootIds);
    var documentSnapshot = await fireStore.collection(userId).doc(ROOTS_LAST_CHANGE).get();
    if (documentSnapshot.exists) {
      for (var root in rootIds) {
        var cloud = documentSnapshot.get(root);
        if (!boxHierachy.containsKey(root) || boxHierachy.get(root) == null) {
          MyTreeNode downloadedRoot = await getRoot(root);
          hierarchyDatabase.downloadRoot(downloadedRoot, cloud);
        } else {
          var local = syncDatabase.getLastNoteChangeTime(root);
          // Conflict
          if (localTimeSync < cloud && localTimeSync < local) {
            ComponentUtils.showWarningToast(AppLocalizations.of(context)!.synchronizationConflict);
            hierarchyDatabase.saveConflictRoot(root);
          } else if (localTimeSync > cloud) {
            // saving to the cloud
            saveRoot(root);
          } else if (localTimeSync > local) {
            // saving to the local
            MyTreeNode downloadedRoot = await getRoot(root);
            hierarchyDatabase.downloadRoot(downloadedRoot, cloud);
          }
        }
      }
    }
  }

  /// Synchronizes the notes between the local database and Firestore.
  ///
  /// This method synchronizes the notes stored in the local database with their
  /// corresponding data in the Firestore database. It compares the local and cloud
  /// versions of each note to detect conflicts and resolve them accordingly.
  ///
  /// [noteIds] is a List containing the IDs of the notes to synchronize.
  /// [localTimeSync] is the local timestamp representing the synchronization time.
  ///
  /// Throws an error if there's an issue during synchronization.
  Future<void> synchronizeNotes(List noteIds, int localTimeSync, BuildContext context) async {
    hierarchyDatabase.saveNoteList(noteIds);
    String userId = auth.currentUser!.uid;
    var collectionId = userId + FIREBASE_NOTES;
    for (var noteId in noteIds) {
      var documentSnapshot = await fireStore.collection(collectionId).doc(noteId).get();
      if (documentSnapshot.exists) {
        var cloud = documentSnapshot.get(NOTE_TIMESTAMP);
        if (!boxSynchronization.containsKey(noteId) || boxSynchronization.get(noteId) == null) {
          String? note = await getNote(noteId);
          if (note != null) {
            notesDatabase.saveNote(noteId, note, cloud);
          }
        } else {
          var local = await boxSynchronization.get(noteId);
          if (localTimeSync < cloud && localTimeSync < local) {
            // Conflict
            ComponentUtils.showWarningToast(AppLocalizations.of(context)!.synchronizationConflict);
            hierarchyDatabase.saveConflictNote(noteId);
            String? note = await getNote(noteId);
            if (note != null) {
              notesDatabase.saveNote(noteId, note, cloud);
            }
          } else if (localTimeSync > cloud) {
            // saving to the cloud
            saveNote(noteId);
          } else if (localTimeSync > local) {
            // saving to the local
            String? note = await getNote(noteId);
            if (note != null) {
              notesDatabase.saveNote(noteId, note, cloud);
            }
          }
        }
      } else {
        saveNote(noteId);
      }
    }
  }

  /// Synchronizes a single note between the local database and Firestore.
  ///
  /// This method synchronizes a single note identified by [noteId] between the local
  /// database and the Firestore database. It compares the local and cloud versions
  /// of the note to detect conflicts and resolves them accordingly.
  ///
  /// If the note exists in the Firestore database, its content and timestamp are
  /// compared with the local version. If conflicts are detected, they are resolved
  /// based on the timestamps. If the note does not exist in the Firestore database,
  /// it is saved to Firestore.
  ///
  /// [noteId] is the ID of the note to synchronize.
  ///
  /// Throws an error if there's an issue during synchronization.
  Future<void> synchronizeNote(String noteId) async {
    log("Synchronizing note $noteId");
    String userId = auth.currentUser!.uid;
    var collectionId = userId + FIREBASE_NOTES;
    var documentSnapshot = await fireStore.collection(collectionId).doc(noteId).get();
    if (documentSnapshot.exists) {
      var cloud = documentSnapshot.get(NOTE_TIMESTAMP);
      if (!boxSynchronization.containsKey(noteId) || boxSynchronization.get(noteId) == null) {
        String? note = await getNote(noteId);
        if (note != null) {
          notesDatabase.saveNote(noteId, note, cloud);
        }
      } else {
        var local = await boxSynchronization.get(noteId);
        if (local > cloud) {
          saveNote(noteId);
        } else {
          String? note = await getNote(noteId);
          if (note != null) {
            notesDatabase.saveNote(noteId, note, cloud);
          }
        }
      }
      // Return the content directly
    } else {
      saveNote(noteId);
    }
  }

  /// Saves the root nodes and associated notes to the Firestore database.
  ///
  /// This method saves the root nodes and their associated notes to the Firestore
  /// database. It retrieves the root list and note list from the [HierarchyDatabase]
  /// and saves them along with the last change timestamp to the Firestore document
  /// specified by [FIREBASE_TREE_PROPERTIES]. Additionally, it iterates through
  /// each root node to individually save them to Firestore.
  ///
  /// Throws an error if there's an issue during the saving process.
  Future<void> saveRoots() async {
    List roots = HierarchyDatabase.rootList;
    List notes = HierarchyDatabase.noteList;
    log("Saving roots: $notes");
    int lastChange = syncDatabase.getLastChange();
    String userId = auth.currentUser!.uid;
    await fireStore.collection(userId).doc(FIREBASE_TREE_PROPERTIES).set({
      FIREBASE_ROOT_LIST: roots,
      NOTES_LIST: notes,
      FIREBASE_LAST_CHANGE: lastChange,
    }, SetOptions(merge: true));
    for (String rootId in roots) {
      saveRoot(rootId);
    }
  }

  /// Downloads root nodes and their data from Firestore.
  ///
  /// Retrieves root list and last change timestamps from Firestore.
  /// Downloads root nodes and updates local database.
  Future<void> downloadRoots() async {
    String userId = auth.currentUser!.uid;
    var documentSnapshot = await fireStore.collection(userId).doc(FIREBASE_TREE_PROPERTIES).get();
    var documentChangeTimes = await fireStore.collection(userId).doc(ROOTS_LAST_CHANGE).get();
    if (documentSnapshot.exists && documentChangeTimes.exists) {
      List rootList = documentSnapshot.get(FIREBASE_ROOT_LIST);
      hierarchyDatabase.saveRootList(rootList);
      for (String rootId in rootList) {
        MyTreeNode root = await getRoot(rootId);
        var lastChange = documentChangeTimes.get(rootId);
        hierarchyDatabase.downloadRoot(root, lastChange);
      }
    }
  }

  /// Retrieves a root node from Firestore.
  ///
  /// Retrieves the root node with the specified [rootId] from Firestore
  /// and returns it as a [MyTreeNode] object.
  Future<MyTreeNode> getRoot(String rootId) async {
    String userId = auth.currentUser!.uid;
    var snapshot = await fireStore.collection(userId).doc(rootId).get();
    var map = snapshot.data();
    return MyTreeNode.fromMap(map!);
  }

  /// Saves a root node and its last change time to Firestore.
  ///
  /// Retrieves the root node with the specified [rootId] from the hierarchy database
  /// and its last change time. The retrieved data is then merged with the existing
  /// data in Firestore using the provided [rootId].
  Future<void> saveRoot(String rootId) async {
    MyTreeNode root = hierarchyDatabase.getRoot(rootId);
    int lastChange = hierarchyDatabase.getRootLastChangeTime(rootId);
    var map = root.toMap();
    String userId = auth.currentUser!.uid;
    await fireStore.collection(userId).doc(rootId).set(map, SetOptions(merge: true));
    await fireStore
        .collection(userId)
        .doc(ROOTS_LAST_CHANGE)
        .set({rootId: lastChange}, SetOptions(merge: true));
  }

  /// Saves the synchronization time to Firestore.
  ///
  /// [time] is the synchronization time to be saved.
  Future<void> saveSyncTime(time) async {
    String userId = auth.currentUser!.uid;
    await fireStore.collection(userId).doc(FIREBASE_LAST_SYNC).set({
      LAST_SYNC_FIELD: time,
    }, SetOptions(merge: true));
  }

  /// Retrieves the list of notes from Firestore.
  ///
  /// Returns the list of notes retrieved from Firestore.
  Future<List> getNoteList() async {
    String userId = auth.currentUser!.uid;
    try {
      var documentSnapshot = await fireStore.collection(userId).doc(FIREBASE_TREE_PROPERTIES).get();
      if (documentSnapshot.exists) {
        return documentSnapshot.get(NOTES_LIST);
      } else {
        log("Document does not exist");
        return [];
      }
    } catch (e) {
      log("Error fetching document: $e");
      return [];
    }
  }

  /// Retrieves the synchronization time from Firestore.
  ///
  /// Returns the synchronization time retrieved from Firestore.
  Future<int> getSyncTime() async {
    String userId = auth.currentUser!.uid;
    try {
      var documentSnapshot = await fireStore.collection(userId).doc(FIREBASE_LAST_SYNC).get();
      if (documentSnapshot.exists) {
        Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
        return data[LAST_SYNC_FIELD];
      } else {
        log("Document does not exist");
        return 0;
      }
    } catch (e) {
      log("Error fetching document: $e");
      return 0;
    }
  }

  /// Retrieves the update time for the hierarchy from Firestore.
  ///
  /// Returns the update time for the hierarchy retrieved from Firestore.
  Future<int> getUpdateTime() async {
    String userId = auth.currentUser!.uid;
    try {
      var documentSnapshot = await fireStore.collection(userId).doc(FIREBASE_TREE_PROPERTIES).get();
      if (documentSnapshot.exists) {
        return documentSnapshot.get(FIREBASE_LAST_CHANGE);
      } else {
        log("Document does not exist");
        return 0;
      }
    } catch (e) {
      log("Error fetching document: $e");
      return 0;
    }
  }

  /// Saves all notes to Firestore.
  Future<void> saveAllNotes() async {
    var keys = boxNotes.keys;
    for (var key in keys) {
      saveNote(key);
    }
  }

  /// Saves a note to Firestore.
  ///
  /// [noteId] is the ID of the note to be saved.
  Future<void> saveNote(String noteId) async {
    var value = boxNotes.get(noteId);
    var timestamp = boxSynchronization.get(noteId);
    //log(value);
    String userId = auth.currentUser!.uid;
    var collectionId = userId + FIREBASE_NOTES;
    await fireStore.collection(collectionId).doc(noteId).set({
      CONTENT: value,
      NOTE_TIMESTAMP: timestamp,
    });
  }

  /// Retrieves all notes from Firestore.
  ///
  /// Returns a list of maps containing information about each note.
  Future<List<Map<String, dynamic>>> getAllNotes() async {
    String userId = auth.currentUser!.uid;
    var collectionId = userId + FIREBASE_NOTES;
    var querySnapshot = await fireStore.collection(collectionId).get();

    List<Map<String, dynamic>> notes = [];
    for (var doc in querySnapshot.docs) {
      var content = doc.get(CONTENT); // Get the content directly
      var timestamp = doc.get(NOTE_TIMESTAMP);
      notes.add({
        NOTE_ID: doc.id, // Include the noteId for reference
        CONTENT: content, // Include the content of the note
        NOTE_TIMESTAMP: timestamp,
      });
    }
    return notes;
  }

  /// Retrieves a specific note from Firestore.
  ///
  /// [noteId] is the ID of the note to be retrieved.
  ///
  /// Returns the content of the note if it exists, otherwise returns null.
  Future<String?> getNote(String noteId) async {
    String userId = auth.currentUser!.uid;
    var collectionId = userId + FIREBASE_NOTES;
    var documentSnapshot = await fireStore.collection(collectionId).doc(noteId).get();
    if (documentSnapshot.exists) {
      return documentSnapshot.get(CONTENT);
    } else {
      return null; // Note does not exist
    }
  }
}
