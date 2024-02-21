import 'package:flutter/material.dart';
import 'package:notes/components/richTextEditor.dart';
import 'dart:developer';
import 'package:notes/services/loginOrRegister.dart';
import 'package:notes/components/myTreeview.dart';

class MainScreen extends StatefulWidget {
  static const appTitle = 'Notes';

  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _pageType = 0;
  String _noteId = "";

  void _changeScreen(int screenType, String id) {
    setState(() {
      _noteId = id;
      _pageType = screenType;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _widgetTypes = <Widget>[
      Container(
        padding: const EdgeInsets.all(50),
        child: const FittedBox(
          child: Text(
            "Welcome back!",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 32.0,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      RichTextEditor(noteId: _noteId)
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(MainScreen.appTitle),
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: [
            const DrawerHeader(
                decoration: BoxDecoration(color: Colors.blue),
                child: UserAccountsDrawerHeader(
                    accountName: Text('Lukas Runt'),
                    accountEmail: Text('lukas.runt@gmail.com'))),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const LoginOrRegister()),
                );
              },
              child: const Text('Login'),
            ),
            MyTreeView(
              navigateWithParam: (int pageType, String id) {
                log("Navigation $id");
                _changeScreen(pageType, id);
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: _widgetTypes[_pageType],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          log("Pressed floating button");
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
