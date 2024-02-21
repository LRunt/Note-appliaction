import 'package:flutter/material.dart';
import 'package:notes/services/loginOrRegister.dart';

class UserDrawerHeader extends StatefulWidget {
  const UserDrawerHeader({super.key});

  @override
  State<UserDrawerHeader> createState() => _UserDrawerHeaderState();
}

class _UserDrawerHeaderState extends State<UserDrawerHeader> {
  int _isConnected = 0;

  void _changeState() {
    setState(() {
      if (_isConnected == 0) {
        _isConnected = 1;
      } else {
        _isConnected = 0;
      }
    });
  }

  Widget build(BuildContext context) {
    // Two types of header (unlogged, logged)
    List<Widget> _widgetOptions = <Widget>[
      DrawerHeader(
          child: Column(
        children: [
          const Text("Not logged user"),
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const LoginOrRegister()),
                );
              },
              child: const Text("Login"))
        ],
      )),
      DrawerHeader(
          child: Column(
        children: [
          const UserAccountsDrawerHeader(
              accountName: Text('Lukas Runt'),
              accountEmail: Text('lukas.runt@gmail.com')),
          ElevatedButton(onPressed: () {}, child: const Text("Log out"))
        ],
      ))
    ];

    return DrawerHeader(
        child: Column(
      children: [
        const Text("Not logged user"),
        ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const LoginOrRegister()),
              );
            },
            child: const Text("Login"))
      ],
    ));
  }
}
