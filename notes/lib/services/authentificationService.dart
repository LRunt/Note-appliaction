import 'package:cloud_firestore/cloud_firestore.dart';
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
class AuthService extends ChangeNotifier {
  /// The [FirebaseAuth] instance for interacting getting authentification data.
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final AppLocalizations Function(BuildContext) localizationProvider;

  /// Instance of [FirebaseService] for accessing Firebase-related services.
  late final FirebaseService _firebaseService =
      FirebaseService(auth: auth, fireStore: firestore);

  /// Instance of [NotesDatabase] for performing operations on the notes database.
  final NotesDatabase db = NotesDatabase();

  AuthService(
      {required this.auth,
      required this.firestore,
      required this.localizationProvider});

  /// Registers a new user with the given email and password.
  ///
  /// On successful registration synchronize data (save data to the firecloud).
  /// Returns a [UserCredential] upon successful registration.
  /// Throws a [FirebaseAuthException] if a Firebase Authentication error occurs.
  Future<UserCredential> register(String email, String password) async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      MyTreeNode tree = boxHierachy.get(TREE_STORAGE);
      _firebaseService.saveTreeStructure(tree);
      _firebaseService.saveAllNotes();
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
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      // Synchronization after login
      MyTreeNode tree = await _firebaseService.getTreeNode();
      boxHierachy.put(TREE_STORAGE, tree);
      //db.saveAllNotes();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw e.code;
    }
  }

  /// Logs out the currently signed-in user.
  ///
  /// It signs out the user from Firebase Authentication.
  Future<void> logout() async {
    await auth.signOut();
  }

  //TODO předělat na mapu
  //Udělat testy

  /// Returns the human redable error description of `errorCode`.
  ///
  /// Returns a text translated description of error what occurs during login.
  /// Updated method to use localizationProvider for getting localized strings.
  String getErrorMessage(String errorCode, BuildContext context) {
    final AppLocalizations localizations = localizationProvider(context);
    String errorMessage = "";
    switch (errorCode) {
      case 'channel-error':
        errorMessage = localizations.fieldsAreNotFilled;
        break;
      case 'user-not-found':
        errorMessage = localizations.userNotFound;
        break;
      case 'wrong-password':
        errorMessage = localizations.wrongPassword;
        break;
      case 'invalid-credential':
        errorMessage = localizations.invalidCreditial;
        break;
      case 'network-request-failed':
        errorMessage = localizations.networkRequestFailed;
        break;
      case 'invalid-email':
        errorMessage = localizations.invalidEmail;
        break;
      default:
        errorMessage = "$errorCode.";
        break;
    }
    return errorMessage;
  }

  /// Returns the human redable error description of `errorCode`.
  ///
  /// Returns a text translated description of error what occurs during registration.
  String getRegisterErrorMessage(String errorCode, BuildContext context) {
    String errorMessage = "";
    if (errorCode == 'channel-error') {
      errorMessage = AppLocalizations.of(context)!.fieldsAreNotFilled;
    } else if (errorCode == 'weak-password') {
      errorMessage = AppLocalizations.of(context)!.weakPassword;
    } else if (errorCode == 'email-already-in-use') {
      errorMessage = AppLocalizations.of(context)!.accountWithEmailExists;
    } else if (errorCode == 'network-request-failed') {
      errorMessage = AppLocalizations.of(context)!.networkRequestFailed;
    } else if (errorCode == 'invalid-email') {
      errorMessage = AppLocalizations.of(context)!.invalidEmail;
    } else {
      errorMessage = "$errorCode.";
    }
    return errorMessage;
  }
}
