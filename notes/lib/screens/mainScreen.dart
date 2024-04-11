import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes/assets/constants.dart';
import 'package:notes/components/componentUtils.dart';
import 'package:notes/components/dialogs/enterPasswordDialog.dart';
import 'package:notes/components/fileListView.dart';
import 'package:notes/components/myButton.dart';
import 'package:notes/components/myDrawerHeader.dart';
import 'package:notes/components/richTextEditor.dart';
import 'package:notes/data/clearDatabase.dart';
import 'package:notes/data/synchronizationDatabase.dart';
import 'package:notes/data/userDatabase.dart';
import 'dart:developer';
import 'package:notes/components/myTreeview.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notes/model/myTreeNode.dart';
import 'package:notes/screens/settings.dart';
import 'package:notes/services/firestoreService.dart';
import 'package:notes/services/nodeService.dart';
import 'package:notes/services/utilService.dart';

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
  Key treeViewKey = UniqueKey();
  String lastSync = "";
  int mainScreenCount = 0;

  ClearDatabase db = ClearDatabase();
  UserDatabase userDB = UserDatabase();
  NodeService nodeService = NodeService();
  SynchronizationDatabase syncDb = SynchronizationDatabase();
  late final FirestoreService firestoreService;
  late StreamSubscription<User?> authStateSubscription;
  final _textDialogController = TextEditingController();

  @override
  void initState() {
    super.initState();
    firestoreService = FirestoreService(
      auth: widget.auth,
      fireStore: widget.firestore,
    );
    authStateSubscription = widget.auth.authStateChanges().listen((event) {
      reloadTreeView();
    });
    lastSync = UtilService.getFormattedDate(syncDb.getLastSyncTime());
  }

  @override
  void dispose() {
    authStateSubscription.cancel();
    _textDialogController.dispose();
    super.dispose();
  }

  void checkLock(bool isNote, String id) {
    if (!isNote) {
      _changeScreen(DIRECTORY_SCREEN, id);
    } else {
      MyTreeNode? node = nodeService.getNode(id);
      if (node!.isLocked) {
        showDialog(
            context: context,
            builder: (context) {
              return EnterPasswordDialog(
                  titleText: node.isNote
                      ? AppLocalizations.of(context)!.createNote
                      : AppLocalizations.of(context)!.createFile,
                  confirmButtonText: AppLocalizations.of(context)!.create,
                  controller: _textDialogController,
                  onConfirm: () {
                    if (nodeService.comparePassword(_textDialogController.text, node.password!)) {
                      _textDialogController.clear();
                      Navigator.of(context).pop();
                      _changeScreen(NOTE_SCREEN, id);
                    } else {
                      ComponentUtils.showErrorToast(AppLocalizations.of(context)!.wrongPassword);
                    }
                  },
                  onCancel: () {
                    _textDialogController.clear();
                    Navigator.of(context).pop();
                  });
            });
      } else {
        _changeScreen(NOTE_SCREEN, id);
      }
    }
  }

  void controlPassword() {}

  void _changeScreen(int screenType, String id) {
    setState(() {
      log("Changing screen");
      _noteId = id;
      _pageType = screenType;
      log("Page type: $_pageType, Note id: $_noteId");
    });
  }

  void reloadTreeView() {
    setState(() {
      treeViewKey = UniqueKey();
      lastSync = UtilService.getFormattedDate(syncDb.getLastSyncTime());
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

  void onChange() {
    log("On change");
    mainScreenCount++;
    _changeScreen(MAIN_SCREEN, "");
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _widgetTypes = <Widget>[
      Container(
        padding: const EdgeInsets.all(50),
        child: FittedBox(
          child: mainScreenCount == 0
              ? Text(
                  AppLocalizations.of(context)!.welcome,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 32.0,
                  ),
                  textAlign: TextAlign.center,
                )
              : const Text(
                  "Home screen",
                  style: TextStyle(
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
        navigateWithParam: (isNote, nodeId) => checkLock(isNote, nodeId),
      ),
    ];

    return Scaffold(
      backgroundColor: _pageType == DIRECTORY_SCREEN ? Colors.grey[200] : Colors.white,
      appBar: AppBar(
          title: _noteId == ""
              ? Text(AppLocalizations.of(context)!.appName)
              : FittedBox(child: Text(_noteId)),
          actions: [
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
          children: <Widget>[
            UserDrawerHeader(
              auth: widget.auth,
              firestore: widget.firestore,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: MyTreeView(
                  key: treeViewKey,
                  navigateWithParam: (bool isNote, String id) => checkLock(isNote, id),
                  onChange: () => onChange(),
                ),
              ),
            ),
            if (widget.auth.currentUser != null)
              Padding(
                padding: const EdgeInsets.all(5),
                child: Column(
                  children: [
                    Text(AppLocalizations.of(context)!.lastSynchronization(lastSync)),
                    MyButton(
                        onTap: () async {
                          await firestoreService.synchronize();
                          reloadTreeView();
                          onChange();
                        },
                        text: AppLocalizations.of(context)!.synchronize),
                  ],
                ),
              )
          ],
        ),
      ),
      body: Center(
        child: _widgetTypes[_pageType],
      ),
    );
  }
}
