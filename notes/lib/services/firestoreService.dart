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
        // if the user have data on account, but he is connected first time
        if (documentSnapshot.exists) {
          if (!boxSynchronization.containsKey(LOCAL_SYNC) ||
              boxSynchronization.get(LOCAL_SYNC) == null) {
            log("Downloading data");
            downloadAllData();
          } else {
            log("document exist");
            Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
            var lastSyncCloud = data[LAST_SYNC_FIELD];
            var lastSyncLocal = boxSynchronization.get(FIREBASE_LAST_SYNC);
            if (lastSyncCloud == lastSyncLocal) {
              log("same time sync");
              await uploadAllData();
            } else {
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
      utils.showErrorToast("Not logged user");
      return "not-logged-user";
    }
  }

  // Uploading all data to the cloud
  Future<void> uploadAllData() async {
    var updateTime = boxSynchronization.get(LAST_CHANGE);
    List notes = hierarchyDatabase.getNotes();
    await saveTreeStructure(HierarchyDatabase.roots.first, notes, updateTime);
    await saveAllNotes();
    var now = DateTime.now().microsecondsSinceEpoch;
    await saveSyncTime(now);
    boxSynchronization.put(FIREBASE_LAST_SYNC, now);
  }

  // Downloading all data from the cloud
  Future<void> downloadAllData() async {
    // Save hierarchy
    MyTreeNode hierarchy = await getTreeNode();
    hierarchyDatabase.saveHierarchy(hierarchy);
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
    int treeChangeTimeLocal = syncDatabase.getLastTreeChangeTime();
    if (localTimeSync > treeChangeTimeCloud && localTimeSync > treeChangeTimeLocal) {
      // Only synchronize notes, because hierarchy is not changed
      List notes = hierarchyDatabase.getNotes();
      synchronizeNotes(notes, localTimeSync);
    } else if (localTimeSync > treeChangeTimeCloud) {
      // Upload hierarchy
      List notes = hierarchyDatabase.getNotes();
      saveTreeStructure(HierarchyDatabase.roots.first, notes, treeChangeTimeLocal);
      synchronizeNotes(notes, localTimeSync);
    } else if (localTimeSync > treeChangeTimeLocal) {
      // Download hierarchy
      MyTreeNode downloadedHierarchy = await getTreeNode();
      hierarchyDatabase.saveHierarchy(downloadedHierarchy);
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
    boxSynchronization.put(FIREBASE_LAST_SYNC, now);
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
            utils.showWarningToast("Possible conflict saved in Settings->Conflicts.");
            hierarchyDatabase.saveConflictNote(noteId);
            String? note = await getNote(noteId);
            if (note != null) {
              syncDatabase.saveNote(noteId, note, cloud);
            }
            // Conflict
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
        return documentSnapshot.get('notes');
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
        return documentSnapshot.get('updateTime');
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
