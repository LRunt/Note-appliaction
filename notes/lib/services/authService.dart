import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:notes/assets/constants.dart';
import 'package:notes/data/notesDatabase.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// A service class for handling authentication operations with Firebase Authentication.
///
/// This class provides methods to register, login, and logout users using Firebase Authentication.
/// It extends [ChangeNotifier] to allow widgets to be rebuilt in response to authentication state changes.
class AuthService extends ChangeNotifier {
  /// The [FirebaseAuth] instance for interacting getting authentification data.
  final FirebaseAuth auth;

  /// A function that provides localizations based on the current build context.
  /// This is used to retrieve localized strings throughout the authentication process.
  final AppLocalizations Function(BuildContext) localizationProvider;

  /// Instance of [NotesDatabase] for performing operations on the notes database.
  final NotesDatabase db = NotesDatabase();

  /// The Google Sign-In instance used for authenticating users via Google OAuth.
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Constructor for creating a [AuthService] instance.
  ///
  /// Requires:
  ///   - [auth] representing the [FirebaseAuth] instance for authentication operations.
  ///   - [localizationProvider] representing a function that returns [AppLocalizations] for the given [BuildContext].
  ///
  /// Example:
  /// ```
  ///   AuthService authService = AuthService(
  ///    auth: FirebaseAuth.instance,
  ///    firestore: FirebaseFirestore.instance,
  ///    localizationProvider: (BuildContext context) => AppLocalizations.of(context)!,
  //    );
  /// ```
  AuthService({required this.auth, required this.localizationProvider});

  /// Registers a new user with the given email and password.
  ///
  /// On successful registration synchronize data (save data to the firecloud).
  /// Returns a [UserCredential] upon successful registration.
  /// Throws a [FirebaseAuthException] if a Firebase Authentication error occurs.
  Future<UserCredential> register(String email, String password) async {
    try {
      UserCredential userCredential =
          await auth.createUserWithEmailAndPassword(email: email, password: password);
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
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw e.code;
    }
  }

  /// Signs in a user using their Google account and synchronizes their data.
  ///
  /// Returns `true` on successful sign-in and synchronization,
  /// throws an `google-sing-error` error otherwise.
  Future<bool> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication gAuth = await gUser!.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );
      await auth.signInWithCredential(credential);
      return true;
    } on FirebaseAuthException catch (e) {
      throw e.code;
    } catch (e) {
      throw 'google-sign-error';
    }
  }

  /// Logs out the currently signed-in user.
  ///
  /// It signs out the user from Firebase Authentication.
  Future<String> logout() async {
    try {
      await _googleSignIn.signOut();
      await auth.signOut();
      return SUCCESS;
    } on FirebaseAuthException catch (e) {
      return e.code;
    } catch (e) {
      throw 'unexpected-logout-error';
    }
  }

  /// Sends a password reset email to the given email address.
  ///
  /// Returns `true` if the email was sent successfully, throws an error if not.
  Future<bool> resetPassword(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      throw e.code;
    } catch (e) {
      throw e.toString();
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
      'google-sign-error': (ctx) => localizations.googleSignFailed,
    };
    // Default error message for unspecified errors
    String defaultErrorMessage = "$errorCode.";
    return errorMessages[errorCode]?.call(context) ?? defaultErrorMessage;
  }
}
