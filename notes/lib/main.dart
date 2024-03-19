import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:notes/assets/constants.dart';
import 'package:notes/data/userDatabase.dart';
import 'package:notes/logger.dart';
import 'firebase_options.dart';

import 'package:notes/screens/mainScreen.dart';
import 'package:notes/model/myTreeNode.dart';
import 'boxes.dart';

/// main - entry point of the program
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initializing the logger
  await AppLogger.init();

  AppLogger.log("Inicializing the application");
  // initialize hive
  await Hive.initFlutter();

  // registring myTreeNodeAdapter
  Hive.registerAdapter(MyTreeNodeAdapter());

  // open a boxes
  boxHierachy = await Hive.openBox<MyTreeNode>(BOX_TREE);
  boxNotes = await Hive.openBox(BOX_NOTES);
  boxUser = await Hive.openBox(BOX_USERS);
  boxSynchronization = await Hive.openBox(BOX_SYNCHRONIZATION);

  // Initializing Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  AppLogger.log("Running the application");
  // Running the application
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
  UserDatabase db = UserDatabase();

  /// An instance of firebase authentification, created in main because of testing.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// An instance of firebase firestore to store data, create in main because of testing.
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void initState() {
    // Loading user preferences
    if (boxUser.containsKey(LOCALE) && boxUser.get(LOCALE) != null) {
      Locale locale = db.loadLocale();
      setLocale(locale);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Note-taking application',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: _locale,
      home: MainScreen(
        auth: _auth,
        firestore: _firestore,
      ),
    );
  }
}
