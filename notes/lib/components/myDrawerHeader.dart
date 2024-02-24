import 'package:flutter/material.dart';
import 'package:notes/assets/constants.dart';
import 'package:notes/boxes.dart';
import 'package:notes/data/user_database.dart';
import 'package:notes/services/loginOrRegister.dart';
import 'dart:developer';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserDrawerHeader extends StatefulWidget {
  const UserDrawerHeader({super.key});

  @override
  State<UserDrawerHeader> createState() => _UserDrawerHeaderState();
}

class _UserDrawerHeaderState extends State<UserDrawerHeader> {
  int _isConnected = 0;

  /// The database instance for managing data ofthe user.
  UserDatabase db = UserDatabase();

  void _changeState() {
    setState(() {
      if (_isConnected == 0) {
        _isConnected = 1;
      } else {
        _isConnected = 0;
      }
    });
  }

  @override
  void initState() {
    if (!boxUser.containsKey(USER_LOGGED) ||
        boxHierachy.get(USER_LOGGED) == null) {
      log("User in not logged");
      db.createDefaultData();
    } else {
      log("Loading data!");
      db.loadData();
      log("Controling if the user is logged");
      if (db.isLogged == 1) {
        // Todo login the user if there is an internet connection
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Two types of header (unlogged, logged)
    List<Widget> _widgetOptions = <Widget>[
      DrawerHeader(
          child: Column(
        children: [
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
        ],
      )),
      DrawerHeader(
          child: Column(
        children: [
          const UserAccountsDrawerHeader(
              accountName: Text('Lukas Runt'),
              accountEmail: Text('lukas.runt@gmail.com')),
          ElevatedButton(
              onPressed: () {},
              child: Text(AppLocalizations.of(context)!.signOut))
        ],
      ))
    ];

    return DrawerHeader(child: Center(child: _widgetOptions[_isConnected]));
  }
}
