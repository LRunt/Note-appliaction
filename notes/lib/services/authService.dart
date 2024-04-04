import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:notes/data/notesDatabase.dart';
import 'package:notes/services/firestoreService.dart';
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

  /// The [FirebaseFirestore] instance
  final FirebaseFirestore firestore;
  final AppLocalizations Function(BuildContext) localizationProvider;

  /// Instance of [FirestoreService] for accessing Firebase-related services.
  late final FirestoreService _firebaseService = FirestoreService(auth: auth, fireStore: firestore);

  /// Instance of [NotesDatabase] for performing operations on the notes database.
  final NotesDatabase db = NotesDatabase();

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthService({required this.auth, required this.firestore, required this.localizationProvider});

  /// Registers a new user with the given email and password.
  ///
  /// On successful registration synchronize data (save data to the firecloud).
  /// Returns a [UserCredential] upon successful registration.
  /// Throws a [FirebaseAuthException] if a Firebase Authentication error occurs.
  Future<UserCredential> register(String email, String password) async {
    try {
      UserCredential userCredential =
          await auth.createUserWithEmailAndPassword(email: email, password: password);
      _firebaseService.synchronize();
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
      UserCredential userCredential =
          await auth.signInWithEmailAndPassword(email: email, password: password);
      // Synchronization after login
      _firebaseService.synchronize();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw e.code;
    }
  }

  signInWithGoogle() async {
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication gAuth = await gUser!.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);

    _firebaseService.synchronize();
  }

  /// Logs out the currently signed-in user.
  ///
  /// It signs out the user from Firebase Authentication.
  Future<String> logout() async {
    try {
      await _googleSignIn.signOut();
      await auth.signOut();
      return "Success";
    } on FirebaseAuthException catch (e) {
      return e.code;
    } catch (e) {
      rethrow;
    }
  }

  /// Returns the human redable error description of `errorCode`.
  ///
  /// Returns a text translated description of error what occurs during login.
  /// Updated method to use localizationProvider for getting localized strings.
  String getErrorMessage(String errorCode, BuildContext context) {
    final AppLocalizations localizations = localizationProvider(context);
    Map<String, String Function(BuildContext)> errorMessages = {
      'channel-error': (ctx) => localizations.fieldsAreNotFilled,
      'user-not-found': (ctx) => localizations.userNotFound,
      'wrong-password': (ctx) => localizations.wrongPassword,
      'invalid-credential': (ctx) => localizations.invalidCreditial,
      'network-request-failed': (ctx) => localizations.networkRequestFailed,
      'invalid-email': (ctx) => localizations.invalidEmail,
      'weak-password': (ctx) => localizations.weakPassword,
      'email-already-in-use': (ctx) => localizations.accountWithEmailExists,
    };
    // Default error message for unspecified errors
    String defaultErrorMessage = "$errorCode.";
    return errorMessages[errorCode]?.call(context) ?? defaultErrorMessage;
  }
}
