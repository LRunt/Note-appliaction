import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes/services/loginOrRegister.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:developer';

class UserDrawerHeader extends StatefulWidget {
  const UserDrawerHeader({super.key});

  @override
  State<UserDrawerHeader> createState() => _UserDrawerHeaderState();
}

class _UserDrawerHeaderState extends State<UserDrawerHeader> {
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        this.user = user;
      });
    });
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
  }

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
                      builder: (context) => const LoginOrRegister()),
                );
              },
              child: Text(AppLocalizations.of(context)!.login))
        ] else ...[
          Text('Logged user: ${user!.email}',
              style: const TextStyle(fontSize: 16)),
          ElevatedButton(
            onPressed: () => logout(),
            child: Text(AppLocalizations.of(context)!.signOut),
          ),
        ]
      ],
    ));
  }
}
