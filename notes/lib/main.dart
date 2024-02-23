import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:notes/screens/mainScreen.dart';
import 'package:notes/model/myTreeNode.dart';
import 'boxes.dart';

/// main - entry point of the program
void main() async {
  // initialize hive
  await Hive.initFlutter();

  // registring myTreeNodeAdapter
  Hive.registerAdapter(MyTreeNodeAdapter());

  // open a boxes
  boxHierachy = await Hive.openBox<MyTreeNode>("Notes_Database");
  boxNotes = await Hive.openBox("Notes");
  boxUser = await Hive.openBox("User");

  runApp(const MyApp());
}

/// Class [MyApp] starts the entire appliaction
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Note-taking application',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: _locale,
      home: const MainScreen(),
    );
  }
}
