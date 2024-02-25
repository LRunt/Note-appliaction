import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:notes/assets/constants.dart';
import 'package:notes/model/myTreeNode.dart';

class FirebaseService extends ChangeNotifier {
  //get instance of auth and firestore
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  bool isLoggedIn() {
    return _firebaseAuth.currentUser != null;
  }

  // SAVE hierarchy
  Future<void> saveTreeStructure(MyTreeNode treeViewData) async {
    var map = treeViewData.toMap();
    String userId = _firebaseAuth.currentUser!.uid;
    await _fireStore
        .collection(userId)
        .doc(FIREBASE_TREE)
        .set(map, SetOptions(merge: true));
  }

  // GET hierarchy
  // not a realtime for now (not using stream builder)
  Future<MyTreeNode> getTreeNode() async {
    String userId = _firebaseAuth.currentUser!.uid;
    var snapshot = await _fireStore.collection(userId).doc(FIREBASE_TREE).get();
    var map = snapshot.data();
    return MyTreeNode.fromMap(map!);
  }

  // SAVE notes

  // SAVE note
  Future<void> saveNote() async {}

  // GET notes

  // GET note
}
