import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:notes/assets/constants.dart';
import 'package:notes/boxes.dart';
import 'package:notes/data/hierarchyDatabase.dart';
import 'package:notes/data/notesDatabase.dart';
import 'package:notes/model/myTreeNode.dart';
import 'dart:developer';

class FirestoreService extends ChangeNotifier {
  //get instance of auth and firestore
  final FirebaseAuth auth;
  final FirebaseFirestore fireStore;
  HierarchyDatabase hierarchyDatabase = HierarchyDatabase();
  NotesDatabase notesDatabase = NotesDatabase();

  FirestoreService({required this.auth, required this.fireStore});

  bool isLoggedIn() {
    return auth.currentUser != null;
  }

  Future<String> synchronize() async {
    if (isLoggedIn()) {
      String userId = auth.currentUser!.uid;
      try {
        var documentSnapshot = await fireStore.collection(userId).doc(LAST_SYNC).get();
        // if the user have data on account, but he is connected first time
        if (documentSnapshot.exists) {
          if (!boxHierachy.containsKey(TREE_STORAGE) || boxHierachy.get(TREE_STORAGE) == null) {
            downloadAllData();
          } else {
            log("document exist");
            //Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
            //var lastSyncCloud = data[LAST_SYNC_FIELD];
            //var lastSyncLocal = boxSynchronization.get(LAST_SYNC);
            /*if (lastSyncCloud == lastSyncLocal) {
              // checking update time while synchronizing
            } else {
              // Download data #TODO check conflicts
            }*/
            synchronizeData();
          }
        } else {
          log("Document does not exist");
          await uploadAllData();
        }
        return "Succes";
      } catch (e) {
        log("Error fetching document: $e");
        return "$e";
      }
    } else {
      return "not-logged-user";
    }
  }

  // Uploading all data to the cloud
  Future<void> uploadAllData() async {
    var updateTime = boxSynchronization.get(TREE_CHANGE);
    await saveTreeStructure(HierarchyDatabase.roots.first, updateTime);
    await saveAllNotes();
    var now = DateTime.now().microsecondsSinceEpoch;
    await saveSyncTime(now);
    boxSynchronization.put(LAST_SYNC, now);
  }

  // Downloading all data from the cloud
  Future<void> downloadAllData() async {
    // Save hierarchy
    MyTreeNode hierarchy = await getTreeNode();
    hierarchyDatabase.saveHierarchy(hierarchy);
    // Save notes
    List<Map<String, dynamic>> allNotes = await getAllNotes();
    notesDatabase.saveAllNotes(allNotes);
  }

  Future<void> synchronizeData() async {
    // Get tree update time
    // Compare times
    var localTimestamp = boxSynchronization.get(TREE_CHANGE);
    var cloudTimestamp = await getUpdateTime();
    if (localTimestamp > cloudTimestamp) {
      saveTreeStructure(HierarchyDatabase.roots.first, localTimestamp);
    } else {
      MyTreeNode downloadedHierarchy = await getTreeNode();
      hierarchyDatabase.saveHierarchy(downloadedHierarchy);
    }
    // download or upload
    // do the same with notes
  }

  // SAVE hierarchy
  Future<void> saveTreeStructure(MyTreeNode treeViewData, var updateTime) async {
    var map = treeViewData.toMap();
    String userId = auth.currentUser!.uid;
    await fireStore.collection(userId).doc(FIREBASE_TREE).set(map, SetOptions(merge: true));
    await fireStore
        .collection(userId)
        .doc(FIREBASE_TREE_TIME)
        .set({'timestamp': DateTime.now().microsecondsSinceEpoch, 'updateTime': updateTime});
  }

  // SAVE hierarchy sync time
  Future<void> saveSyncTime(time) async {
    String userId = auth.currentUser!.uid;
    await fireStore.collection(userId).doc(LAST_SYNC).set({
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

  // Get hierarchy sync time
  Future<DateTime?> getSyncTime() async {
    String userId = auth.currentUser!.uid;
    try {
      var documentSnapshot = await fireStore.collection(userId).doc(FIREBASE_TREE_TIME).get();
      if (documentSnapshot.exists) {
        Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
        return data['timestamp'];
      } else {
        log("Document does not exist");
        return null;
      }
    } catch (e) {
      log("Error fetching document: $e");
      return null;
    }
  }

  // Get hierarchy sync time
  Future<DateTime?> getUpdateTime() async {
    String userId = auth.currentUser!.uid;
    try {
      var documentSnapshot = await fireStore.collection(userId).doc(FIREBASE_TREE_TIME).get();
      if (documentSnapshot.exists) {
        Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
        return data['updateTime'];
      } else {
        log("Document does not exist");
        return null;
      }
    } catch (e) {
      log("Error fetching document: $e");
      return null;
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
    log(value);
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
      return documentSnapshot.get('content'); // Return the content directly
    } else {
      return null; // Note does not exist
    }
  }
}
