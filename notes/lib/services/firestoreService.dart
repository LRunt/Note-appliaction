import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:notes/assets/constants.dart';
import 'package:notes/boxes.dart';
import 'package:notes/components/componentUtils.dart';
import 'package:notes/data/hierarchyDatabase.dart';
import 'package:notes/data/notesDatabase.dart';
import 'package:notes/data/synchronizationDatabase.dart';
import 'package:notes/model/myTreeNode.dart';
import 'dart:developer';

class FirestoreService extends ChangeNotifier {
  //get instance of auth and firestore
  final FirebaseAuth auth;
  final FirebaseFirestore fireStore;
  HierarchyDatabase hierarchyDatabase = HierarchyDatabase();
  NotesDatabase notesDatabase = NotesDatabase();
  SynchronizationDatabase syncDatabase = SynchronizationDatabase();
  ComponentUtils utils = ComponentUtils();

  FirestoreService({required this.auth, required this.fireStore});

  bool isLoggedIn() {
    return auth.currentUser != null;
  }

  Future<String> synchronize() async {
    utils.showDefaultToast("Synchronizing data");
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
            downloadAllData();
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
              await resolveConflicts(lastSyncLocal, lastSyncCloud);
            }
          }
        } else {
          log("Document does not exist");
          await uploadAllData();
        }
        utils.showSuccesToast("Data synchronized");
        return "Succes";
      } catch (e) {
        log("Error fetching document: $e");
        return "$e";
      }
    } else {
      ComponentUtils.showErrorToast("Not logged user");
      return "not-logged-user";
    }
  }

  // Uploading all data to the cloud
  Future<void> uploadAllData() async {
    await saveRoots();
    await saveAllNotes();
    var now = DateTime.now().microsecondsSinceEpoch;
    await saveSyncTime(now);
    syncDatabase.synchronization(now);
  }

  // Downloading all data from the cloud
  Future<void> downloadAllData() async {
    await downloadRoots();
    List notes = await getNoteList();
    hierarchyDatabase.saveNotes(notes);
    int syncTime = await getSyncTime();
    log("Sync time: $syncTime");
    syncDatabase.synchronization(syncTime);
    // Save notes
    List<Map<String, dynamic>> allNotes = await getAllNotes();
    notesDatabase.saveAllNotes(allNotes);
  }

  Future<void> resolveConflicts(int localTimeSync, int cloudTimeSync) async {
    int treeChangeTimeCloud = await getUpdateTime();
    int treeChangeTimeLocal = syncDatabase.getLastHierarchyChangeTime();
    if (localTimeSync > treeChangeTimeCloud && localTimeSync > treeChangeTimeLocal) {
      // Only synchronize notes, because hierarchy is not changed
      List notes = hierarchyDatabase.getNotes();
      synchronizeNotes(notes, localTimeSync);
    } else if (localTimeSync > treeChangeTimeLocal) {
      List roots = await getUserRoots();
      synchronizeRoots(roots, localTimeSync);
      List notes = await getUserNoteList();
      synchronizeNotes(notes, localTimeSync);
    } else if (localTimeSync > treeChangeTimeCloud) {
      // Local or cloud is not changed
      List roots = hierarchyDatabase.getRoots();
      saveRoots();
      synchronizeRoots(roots, localTimeSync);
      List notes = hierarchyDatabase.getNotes();
      synchronizeNotes(notes, localTimeSync);
    } else {
      // Conflict
      utils.showWarningToast("Possible conflict saved in Settings->Conflicts.");
      hierarchyDatabase.saveConflictData();
      downloadAllData();
    }
    var now = DateTime.now().microsecondsSinceEpoch;
    await saveSyncTime(now);
    syncDatabase.synchronization(now);
  }

  Future<List> getUserRoots() async {
    String userId = auth.currentUser!.uid;
    var documentSnapshot = await fireStore.collection(userId).doc(FIREBASE_TREE_PROPERTIES).get();
    if (documentSnapshot.exists) {
      return documentSnapshot.get('rootList');
    } else {
      log("Document does not exist");
      return [];
    }
  }

  Future<List> getUserNoteList() async {
    String userId = auth.currentUser!.uid;
    var documentSnapshot = await fireStore.collection(userId).doc(FIREBASE_TREE_PROPERTIES).get();
    if (documentSnapshot.exists) {
      return documentSnapshot.get('noteList');
    } else {
      log("Document does not exist");
      return [];
    }
  }

  Future<void> synchronizeRoots(List rootIds, int localTimeSync) async {
    String userId = auth.currentUser!.uid;
    hierarchyDatabase.saveRootList(rootIds);
    var documentSnapshot = await fireStore.collection(userId).doc("rootsLastChange").get();
    if (documentSnapshot.exists) {
      for (var root in rootIds) {
        var cloud = documentSnapshot.get(root);
        if (!boxHierachy.containsKey(root) || boxHierachy.get(root) == null) {
          MyTreeNode downloadedRoot = await getRoot(root);
          hierarchyDatabase.downloadRoot(downloadedRoot, cloud);
        } else {
          var local = syncDatabase.getLastChangeTime(root);
          // Conflict
          if (localTimeSync < cloud && localTimeSync < local) {
            utils.showWarningToast("Possible conflict saved in Settings->Conflicts.");
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

  Future<void> synchronizeNotes(List noteIds, int localTimeSync) async {
    for (var noteId in noteIds) {
      String userId = auth.currentUser!.uid;
      var collectionId = userId + FIREBASE_NOTES;
      var documentSnapshot = await fireStore.collection(collectionId).doc(noteId).get();
      if (documentSnapshot.exists) {
        var cloud = documentSnapshot.get('timestamp');
        if (!boxSynchronization.containsKey(noteId) || boxSynchronization.get(noteId) == null) {
          String? note = await getNote(noteId);
          if (note != null) {
            syncDatabase.saveNote(noteId, note, cloud);
          }
        } else {
          var local = await boxSynchronization.get(noteId);
          if (localTimeSync < cloud && localTimeSync < local) {
            // Conflict
            utils.showWarningToast("Possible conflict saved in Settings->Conflicts.");
            hierarchyDatabase.saveConflictNote(noteId);
            String? note = await getNote(noteId);
            if (note != null) {
              syncDatabase.saveNote(noteId, note, cloud);
            }
          } else if (localTimeSync > cloud) {
            // saving to the cloud
            saveNote(noteId);
          } else if (localTimeSync > local) {
            // saving to the local
            String? note = await getNote(noteId);
            if (note != null) {
              syncDatabase.saveNote(noteId, note, cloud);
            }
          }
        }
      } else {
        saveNote(noteId);
      }
    }
  }

  Future<void> synchronizeData() async {
    // Get tree update time
    // Compare times
    var localTimestamp = boxSynchronization.get(LAST_CHANGE);
    var cloudTimestamp = await getUpdateTime();
    log("LocalTimestamp $localTimestamp");
    log("CloudTimestamp $cloudTimestamp");
    if (localTimestamp > cloudTimestamp) {
      List notes = hierarchyDatabase.getNotes();
      saveTreeStructure(HierarchyDatabase.roots.first, notes, localTimestamp);
      var keys = boxNotes.keys;
      for (var key in keys) {
        await synchronizeNote(key);
      }
    } else if (localTimestamp < cloudTimestamp) {
      MyTreeNode downloadedHierarchy = await getTreeNode();
      hierarchyDatabase.saveHierarchy(downloadedHierarchy);
      String userId = auth.currentUser!.uid;
      var collectionId = userId + FIREBASE_NOTES;
      var querySnapshot = await fireStore.collection(collectionId).get();
      for (var doc in querySnapshot.docs) {
        synchronizeNote(doc.id);
      }
    } else {
      var keys = boxNotes.keys;
      for (var key in keys) {
        await synchronizeNote(key);
      }
    }
  }

  Future<void> synchronizeNote(String noteId) async {
    log("Synchronizing note $noteId");
    String userId = auth.currentUser!.uid;
    var collectionId = userId + FIREBASE_NOTES;
    var documentSnapshot = await fireStore.collection(collectionId).doc(noteId).get();
    if (documentSnapshot.exists) {
      var cloud = documentSnapshot.get('timestamp');
      if (!boxSynchronization.containsKey(noteId) || boxSynchronization.get(noteId) == null) {
        String? note = await getNote(noteId);
        if (note != null) {
          syncDatabase.saveNote(noteId, note, cloud);
        }
      } else {
        var local = await boxSynchronization.get(noteId);
        if (local > cloud) {
          saveNote(noteId);
        } else {
          String? note = await getNote(noteId);
          if (note != null) {
            syncDatabase.saveNote(noteId, note, cloud);
          }
        }
      }
      // Return the content directly
    } else {
      saveNote(noteId);
    }
  }

  Future<void> saveRoots() async {
    List roots = HierarchyDatabase.rootList;
    List notes = HierarchyDatabase.noteList;
    log("Saving roots: $notes");
    int lastChange = hierarchyDatabase.getLastChange();
    String userId = auth.currentUser!.uid;
    await fireStore.collection(userId).doc(FIREBASE_TREE_PROPERTIES).set({
      'rootList': roots,
      'noteList': notes,
      'lastChange': lastChange,
    }, SetOptions(merge: true));
    for (String rootId in roots) {
      saveRoot(rootId);
    }
  }

  Future<void> downloadRoots() async {
    String userId = auth.currentUser!.uid;
    var documentSnapshot = await fireStore.collection(userId).doc(FIREBASE_TREE_PROPERTIES).get();
    var documentChangeTimes = await fireStore.collection(userId).doc("rootsLastChange").get();
    if (documentSnapshot.exists && documentChangeTimes.exists) {
      List rootList = documentSnapshot.get('rootList');
      hierarchyDatabase.saveRootList(rootList);
      for (String rootId in rootList) {
        MyTreeNode root = await getRoot(rootId);
        var lastChange = documentChangeTimes.get(rootId);
        hierarchyDatabase.downloadRoot(root, lastChange);
      }
    }
  }

  Future<MyTreeNode> getRoot(String rootId) async {
    String userId = auth.currentUser!.uid;
    var snapshot = await fireStore.collection(userId).doc(rootId).get();
    var map = snapshot.data();
    return MyTreeNode.fromMap(map!);
  }

  Future<void> saveRoot(String rootId) async {
    MyTreeNode root = hierarchyDatabase.getRoot(rootId);
    int lastChange = hierarchyDatabase.getRootLastChangeTime(rootId);
    var map = root.toMap();
    String userId = auth.currentUser!.uid;
    await fireStore.collection(userId).doc(rootId).set(map, SetOptions(merge: true));
    await fireStore
        .collection(userId)
        .doc('rootsLastChange')
        .set({rootId: lastChange}, SetOptions(merge: true));
  }

  // SAVE hierarchy
  Future<void> saveTreeStructure(MyTreeNode treeViewData, List notes, var updateTime) async {
    var map = treeViewData.toMap();
    String userId = auth.currentUser!.uid;
    await fireStore.collection(userId).doc(FIREBASE_TREE).set(map, SetOptions(merge: true));
    await fireStore.collection(userId).doc(FIREBASE_TREE_PROPERTIES).set({
      'updateTime': updateTime,
      'notes': notes,
    });
  }

  // SAVE hierarchy sync time
  Future<void> saveSyncTime(time) async {
    String userId = auth.currentUser!.uid;
    await fireStore.collection(userId).doc(FIREBASE_LAST_SYNC).set({
      LAST_SYNC_FIELD: time,
    }, SetOptions(merge: true));
  }

  // GET hierarchy
  // not a realtime for now (not using stream builder)
  Future<MyTreeNode> getTreeNode() async {
    String userId = auth.currentUser!.uid;
    var snapshot = await fireStore.collection(userId).doc(FIREBASE_TREE).get();
    var map = snapshot.data();
    return MyTreeNode.fromMap(map!);
  }

  Future<List> getNoteList() async {
    String userId = auth.currentUser!.uid;
    try {
      var documentSnapshot = await fireStore.collection(userId).doc(FIREBASE_TREE_PROPERTIES).get();
      if (documentSnapshot.exists) {
        return documentSnapshot.get('noteList');
      } else {
        log("Document does not exist");
        return [];
      }
    } catch (e) {
      log("Error fetching document: $e");
      return [];
    }
  }

  // Get hierarchy sync time
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

  // Get hierarchy sync time
  Future<int> getUpdateTime() async {
    String userId = auth.currentUser!.uid;
    try {
      var documentSnapshot = await fireStore.collection(userId).doc(FIREBASE_TREE_PROPERTIES).get();
      if (documentSnapshot.exists) {
        return documentSnapshot.get('lastChange');
      } else {
        log("Document does not exist");
        return 0;
      }
    } catch (e) {
      log("Error fetching document: $e");
      return 0;
    }
  }

  // SAVE notes
  /// Saving all notes
  Future<void> saveAllNotes() async {
    var keys = boxNotes.keys;
    for (var key in keys) {
      saveNote(key);
    }
  }

  // SAVE note
  Future<void> saveNote(String noteId) async {
    var value = boxNotes.get(noteId);
    var timestamp = boxSynchronization.get(noteId);
    //log(value);
    String userId = auth.currentUser!.uid;
    var collectionId = userId + FIREBASE_NOTES;
    await fireStore
        .collection(collectionId)
        .doc(noteId)
        .set({'content': value, 'timestamp': timestamp});
  }

  // GET notes
  Future<List<Map<String, dynamic>>> getAllNotes() async {
    String userId = auth.currentUser!.uid;
    var collectionId = userId + FIREBASE_NOTES;
    var querySnapshot = await fireStore.collection(collectionId).get();

    List<Map<String, dynamic>> notes = [];
    for (var doc in querySnapshot.docs) {
      var content = doc.get('content'); // Get the content directly
      var timestamp = doc.get('timestamp');
      notes.add({
        'noteId': doc.id, // Include the noteId for reference
        'content': content, // Include the content of the note
        'timestamp': timestamp,
      });
    }
    return notes;
  }

  // GET note
  Future<String?> getNote(String noteId) async {
    String userId = auth.currentUser!.uid;
    var collectionId = userId + FIREBASE_NOTES;
    var documentSnapshot = await fireStore.collection(collectionId).doc(noteId).get();
    if (documentSnapshot.exists) {
      return documentSnapshot.get('content');
    } else {
      return null; // Note does not exist
    }
  }
}
