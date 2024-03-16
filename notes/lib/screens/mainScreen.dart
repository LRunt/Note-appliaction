import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes/assets/constants.dart';
import 'package:notes/components/fileListView.dart';
import 'package:notes/components/myButton.dart';
import 'package:notes/components/myDrawerHeader.dart';
import 'package:notes/components/richTextEditor.dart';
import 'package:notes/data/clearDatabase.dart';
import 'package:notes/data/userDatabase.dart';
import 'dart:developer';
import 'package:notes/components/myTreeview.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notes/model/myTreeNode.dart';
import 'package:notes/screens/settings.dart';
import 'package:notes/services/firestoreService.dart';
import 'package:notes/services/nodeService.dart';

class MainScreen extends StatefulWidget {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  const MainScreen({super.key, required this.auth, required this.firestore});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _pageType = 0;
  String _noteId = "";

  ClearDatabase db = ClearDatabase();
  UserDatabase userDB = UserDatabase();
  NodeService nodeService = NodeService();
  late final FirestoreService firestoreService;

  @override
  void initState() {
    firestoreService = FirestoreService(
      auth: widget.auth,
      fireStore: widget.firestore,
    );
    super.initState();
  }

  void _changeScreen(int screenType, String id) {
    setState(() {
      log("Changing screen");
      _noteId = id;
      _pageType = screenType;
      log("Page type: $_pageType, Note id: $_noteId");
    });
  }

  void navigateWithParam(bool isNote, String id) {
    log("Navigation $id");
    if (isNote) {
      _changeScreen(NOTE_SCREEN, id);
    } else {
      _changeScreen(DIRECTORY_SCREEN, id);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _widgetTypes = <Widget>[
      Container(
        padding: const EdgeInsets.all(50),
        child: FittedBox(
          child: Text(
            AppLocalizations.of(context)!.welcome,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 32.0,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      RichTextEditor(noteId: _noteId, key: ValueKey(_noteId)),
      FileListView(
        nodeId: _noteId,
        key: ValueKey(_noteId),
        navigateWithParam: (isNote, nodeId) => navigateWithParam(isNote, nodeId),
      ),
    ];

    return Scaffold(
      backgroundColor: _pageType == DIRECTORY_SCREEN ? Colors.grey[200] : Colors.white,
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.appName), actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SettingsPage(),
              ),
            );
          },
        )
      ]),
      drawer: Drawer(
        child: Column(
          children: [
            UserDrawerHeader(
              auth: widget.auth,
              firestore: widget.firestore,
            ),
            Expanded(
              child: MyTreeView(
                navigateWithParam: (bool isNote, String id) => navigateWithParam(isNote, id),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5),
              child: MyButton(
                  onTap: () {
                    firestoreService.synchronize();
                  },
                  text: "Synchronize"),
            )
          ],
        ),
      ),
      body: Center(
        child: _widgetTypes[_pageType],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          log("Pressed floating button");
          MyTreeNode? node = nodeService.getNode('|Home|poznámka');
          log("Node: $node");
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
