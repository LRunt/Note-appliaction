import 'package:flutter/material.dart';
import 'package:notes/components/myDrawerHeader.dart';
import 'package:notes/components/richTextEditor.dart';
import 'package:notes/main.dart';
import 'package:notes/model/language.dart';
import 'dart:developer';
import 'package:notes/components/myTreeview.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _pageType = 0;
  String _noteId = "";

  void _changeScreen(int screenType, String id) {
    setState(() {
      log("Changing screen");
      _noteId = id;
      _pageType = screenType;
      log("Page type: $_pageType, Note id: $_noteId");
    });
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
    ];

    return Scaffold(
      appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.appName),
          actions: <Widget>[
            DropdownButton(
                icon: const Icon(Icons.language),
                items: Language.languageList()
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(
                            e.flag,
                            style: const TextStyle(fontSize: 30),
                          ),
                        ))
                    .toList(),
                onChanged: (Language? language) {
                  if (language != null) {
                    MyApp.setLocale(context, Locale(language.langCode));
                  }
                })
          ]),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: [
            const UserDrawerHeader(),
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
