import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:notes/assets/constants.dart';
import 'package:notes/boxes.dart';
import 'package:notes/model/myTreeNode.dart';
import 'dart:developer';

class FirebaseService extends ChangeNotifier {
  //get instance of auth and firestore
  final FirebaseAuth auth;
  final FirebaseFirestore fireStore;

  FirebaseService({required this.auth, required this.fireStore});

  bool isLoggedIn() {
    return auth.currentUser != null;
  }

  // SAVE hierarchy
  Future<void> saveTreeStructure(MyTreeNode treeViewData) async {
    var map = treeViewData.toMap();
    String userId = auth.currentUser!.uid;
    await fireStore
        .collection(userId)
        .doc(FIREBASE_TREE)
        .set(map, SetOptions(merge: true));
  }

  // SAVE hierarchy sync time
  Future<void> saveTreeTime() async {
    String userId = auth.currentUser!.uid;
    await fireStore.collection(userId).doc(FIREBASE_TREE_TIME).set({
      'updateTime': FieldValue.serverTimestamp(),
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
  Future<DateTime?> getTreeTime() async {
    String userId = auth.currentUser!.uid;
    try {
      var documentSnapshot =
          await fireStore.collection(userId).doc(FIREBASE_TREE_TIME).get();
      if (documentSnapshot.exists) {
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;
        Timestamp updateTime = data['updateTime'];
        return updateTime.toDate(); // Convert Timestamp to DateTime
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
    log(value);
    String userId = auth.currentUser!.uid;
    var collectionId = userId + FIREBASE_NOTES;
    await fireStore
        .collection(collectionId)
        .doc(noteId)
        .set({'content': value});
  }

  // GET notes
  Future<List<Map<String, dynamic>>> getAllNotes() async {
    String userId = auth.currentUser!.uid;
    var collectionId = userId + FIREBASE_NOTES;
    var querySnapshot = await fireStore.collection(collectionId).get();

    List<Map<String, dynamic>> notes = [];
    for (var doc in querySnapshot.docs) {
      var content = doc.get('content'); // Get the content directly
      notes.add({
        'noteId': doc.id, // Include the noteId for reference
        'content': content // Include the content of the note
      });
    }
    return notes;
  }

  // GET note
  Future<String?> getNote(String noteId) async {
    String userId = auth.currentUser!.uid;
    var collectionId = userId + FIREBASE_NOTES;
    var documentSnapshot =
        await fireStore.collection(collectionId).doc(noteId).get();

    if (documentSnapshot.exists) {
      return documentSnapshot.get('content'); // Return the content directly
    } else {
      return null; // Note does not exist
    }
  }
}
