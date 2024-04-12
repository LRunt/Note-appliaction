import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes/services/authService.dart';
import 'package:notes/services/loginOrRegister.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:developer';

/// A StatefulWidget that creates a drawer header showing the user's login status.
///
/// This widget listens to Firebase Authentication state changes to update the state of the UI.
/// It also uses Firebase Authentication to manage the user state.
class UserDrawerHeader extends StatefulWidget {
  /// Instance of firebase authentification.
  final FirebaseAuth auth;

  /// Instance of firebase firestore.
  final FirebaseFirestore firestore;

  final VoidCallback loginSuccess;

  /// Constructor of [UserDrawerHeader] class.
  const UserDrawerHeader(
      {super.key, required this.auth, required this.firestore, required this.loginSuccess});

  @override
  State<UserDrawerHeader> createState() => _UserDrawerHeaderState();
}

/// The state class for [UserDrawerHeader], handling user authentication state.
/// Content of the [UserDrawerHeader] depends on whether the user si logged in.
class _UserDrawerHeaderState extends State<UserDrawerHeader> {
  /// The current user, obtained from Firebase Authentification.
  /// null when user is not logged in.
  User? user;

  /// Subscribtion to the authentification state changes.
  /// Listens for updates of the user's status and updates the UI.
  late final StreamSubscription<User?> authSubscription;

  late final AuthService _authService;

  /// Inicialization of the state
  /// Adding listener to the authentication state changes (login/logout) and update the UI by setting the current user.
  /// If an error occurs while listening, it is logged to the console.
  @override
  void initState() {
    super.initState();
    user = widget.auth.currentUser;
    _authService = AuthService(
      auth: widget.auth,
      localizationProvider: (BuildContext context) => AppLocalizations.of(context)!,
    );
    authSubscription = widget.auth.authStateChanges().listen(
      (User? currentUser) {
        if (mounted) {
          setState(
            () {
              user = currentUser;
            },
          );
        }
      },
      onError: (error) {
        log('Error listening to authentification state changes: $error');
      },
    );
  }

  /// Cancel the subscription to auth state changes when the widget is disposed
  /// to prevent memory leaks and unnecessary processing.
  @override
  void dispose() {
    authSubscription.cancel();
    super.dispose();
  }

  /// Log out from Firebase Authentication.
  /// This method attempts to sign out the current user.
  /// If an error occurs, it logs the error message.
  void logout() async {
    String result = await _authService.logout();
    if (result == "Success") {
      log("Success");
    } else {
      log('Logout failed with error: $result');
    }
  }

  /// Builds the UI based on the user's authentication status.
  @override
  Widget build(BuildContext context) {
    return DrawerHeader(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor, // Optional: Adds color to the DrawerHeader
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (user == null)
            Column(
              children: [
                Container(
                  width: double.infinity,
                ),
                Text(
                  AppLocalizations.of(context)!.notLogged,
                  style: const TextStyle(
                      fontSize: 20, color: Colors.white), // Makes text larger and white
                ),
                const SizedBox(height: 10), // Adds spacing between text and buttons
                SizedBox(
                  width: 200,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.login),
                    label: Text(AppLocalizations.of(context)!.login),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginOrRegister(
                            auth: widget.auth,
                            firestore: widget.firestore,
                            showLoginPage: true,
                            loginSuccess: widget.loginSuccess,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.person_add),
                    label: Text(AppLocalizations.of(context)!.registration),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginOrRegister(
                            auth: widget.auth,
                            firestore: widget.firestore,
                            showLoginPage: false,
                            loginSuccess: widget.loginSuccess,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                const SizedBox(
                  width: double.infinity,
                ),
                Text(
                  AppLocalizations.of(context)!.loggedUser(user!.email),
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 200,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.exit_to_app),
                    label: Text(AppLocalizations.of(context)!.signOut),
                    onPressed: () => logout(),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
