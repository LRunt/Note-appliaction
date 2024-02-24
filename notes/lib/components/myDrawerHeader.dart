import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes/services/loginOrRegister.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:developer';

/// A StatefulWidget that creates a drawer header showing the user's login status.
///
/// This widget listens to Firebase Authentication state changes to update the state of the UI.
/// It also uses Firebase Authentication to manage the user state.
class UserDrawerHeader extends StatefulWidget {
  /// Constructor of [UserDrawerHeader] class.
  const UserDrawerHeader({super.key});

  @override
  State<UserDrawerHeader> createState() => _UserDrawerHeaderState();
}

/// The state class for [UserDrawerHeader], handling user authentication state.
/// Content of the [UserDrawerHeader] depends on whether the user si logged in.
class _UserDrawerHeaderState extends State<UserDrawerHeader> {
  /// The current user, obtained from Firebase Authentification.
  /// null when user is not logged in.
  User? user = FirebaseAuth.instance.currentUser;

  /// Subscribtion to the authentification state changes.
  /// Listens for updates of the user's status and updates the UI.
  late final StreamSubscription<User?> authSubscription;

  /// Inicialization of the state
  /// Adding listener to the authentication state changes (login/logout) and update the UI by setting the current user.
  /// If an error occurs while listening, it is logged to the console.
  @override
  void initState() {
    super.initState();
    authSubscription = FirebaseAuth.instance.authStateChanges().listen(
      (User? currentUser) {
        if (mounted) {
          setState(() {
            user = currentUser;
          });
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
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      log('Error while logout: $e');
    }
  }

  /// Builds the UI based on the user's authentication status.
  @override
  Widget build(BuildContext context) {
    return DrawerHeader(
      child: Column(
        children: [
          if (user == null) ...[
            Text(AppLocalizations.of(context)!.notLogged),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const LoginOrRegister(showLoginPage: true),
                  ),
                );
              },
              child: Text(AppLocalizations.of(context)!.login),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const LoginOrRegister(showLoginPage: false),
                  ),
                );
              },
              child: Text(AppLocalizations.of(context)!.registration),
            ),
          ] else ...[
            Text(AppLocalizations.of(context)!.loggedUser(user!.email),
                style: const TextStyle(fontSize: 16)),
            ElevatedButton(
              onPressed: () => logout(),
              child: Text(AppLocalizations.of(context)!.signOut),
            ),
          ],
        ],
      ),
    );
  }
}
