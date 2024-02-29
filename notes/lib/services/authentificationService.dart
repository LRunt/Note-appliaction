import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes/assets/constants.dart';
import 'package:notes/boxes.dart';
import 'package:notes/data/notesDatabase.dart';
import 'package:notes/model/myTreeNode.dart';
import 'package:notes/services/firebaseService.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// A service class for handling authentication operations with Firebase Authentication.
///
/// This class provides methods to register, login, and logout users using Firebase Authentication.
/// It extends [ChangeNotifier] to allow widgets to be rebuilt in response to authentication state changes.
/// Author: Lukas Runt
/// Date: 2024-02-29
/// Version: 1.0.0
class AuthentificationService extends ChangeNotifier {
  /// The [FirebaseAuth] instance for interacting getting authentification data.
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Instance of [FirebaseService] for accessing Firebase-related services.
  final FirebaseService _firebaseService = FirebaseService();

  /// Instance of [NotesDatabase] for performing operations on the notes database.
  final NotesDatabase db = NotesDatabase();

  /// Registers a new user with the given email and password.
  ///
  /// On successful registration synchronize data (save data to the firecloud).
  /// Returns a [UserCredential] upon successful registration.
  /// Throws a [FirebaseAuthException] if a Firebase Authentication error occurs.
  Future<UserCredential> register(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw e.code;
    }
  }

  /// Logs in a user with the given email and password.
  ///
  /// On succesfull login synchronize data with firestore database.
  /// Returns a [UserCredential] upon successful login.
  /// Throws a [FirebaseAuthException] if a Firebase Authentication error occurs.
  Future<UserCredential> login(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      // Synchronization after login
      MyTreeNode tree = await _firebaseService.getTreeNode();
      boxHierachy.put(TREE_STORAGE, tree);
      db.saveAllNotes();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw e.code;
    }
  }

  /// Logs out the currently signed-in user.
  ///
  /// It signs out the user from Firebase Authentication.
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  /// Returns the human redable error description of `errorCode`.
  ///
  /// Returns a text translated description of error what occurs during authentification.
  String getErrorMessage(String errorCode, BuildContext context) {
    String errorMessage = "";
    if (errorCode == 'user-not-found') {
      errorMessage = AppLocalizations.of(context)!.userNotFound;
    } else if (errorCode == 'wrong-password') {
      errorMessage = AppLocalizations.of(context)!.wrongPassword;
    } else if (errorCode == 'invalid-credential') {
      errorMessage = AppLocalizations.of(context)!.invalidCreditial;
    } else if (errorCode == "network-request-failed") {
      errorMessage = AppLocalizations.of(context)!.networkRequestFailed;
    } else if (errorCode == "invalid-email") {
      errorMessage = AppLocalizations.of(context)!.invalidEmail;
    } else {
      errorMessage = "$errorCode.";
    }
    return errorMessage;
  }
}
