import 'package:flutter/material.dart';
import 'package:notes/screens/login.dart';
import 'package:notes/screens/register.dart';

/// A StatefulWidget that toggles between the login and register screens.
///
/// This widget serves as a container that decides whether to show the login screen
/// or the registration screen based on the user's choice. It provides a seamless way
/// for users to switch between the two screens without navigating back and forth in the app's navigation stack.
class LoginOrRegister extends StatefulWidget {
  /// Constructor of [LoginOrRegister] class.
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  /// A boolean value that determines which screen to show.
  /// `true`  - the login screen.
  /// `false` - the registration screen.
  bool showLoginPage = true;

  /// Toggles the boolean value to switch between screens.
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  /// Builds the widget based on the current state.
  ///
  /// If `showLoginPage` is true, the [LoginPage] widget is returned, otherwise,
  /// the [RegisterPage] widget is returned. Each screen provides an option to toggle
  /// to the other screen via the `onTap` callback, which invokes [togglePages].
  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(onTap: togglePages);
    } else {
      return RegisterPage(onTap: togglePages);
    }
  }
}
