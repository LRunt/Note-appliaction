import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:notes/constants.dart';
import 'package:notes/data/local_databases.dart';
import 'package:notes/model/theme.dart';
import 'package:notes/screens/screens.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:notes/model/myTreeNode.dart';
import 'boxes.dart';

/// A Flutter application for note-taking.
///
/// This application provides functionality for taking notes, managing hierarchical data,
/// and synchronizing data with Firebase Firestore. It supports multiple themes and
/// internationalization.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initializing the logger
  // await AppLogger.init();

  //AppLogger.log("Inicializing the application");
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
  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyATPz_4XG0Nk9jLSpXINcZbidN3vtpz_TI",
          appId: "1:61772139773:web:db0e9f389e6aa60301c294",
          messagingSenderId: "61772139773",
          projectId: "note-taking-application-7c5e4",
        ),
      );
    } else {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    print("Firebase failed to initialize: $e");
    return;
  }

  //AppLogger.log("Running the application");
  // Running the application
  runApp(const MyApp());
}

/// The root widget of the application.
///
/// This widget initializes the entire application and handles changes in locale and theme.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  /// Sets the locale for the application.
  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;
  UserDatabase db = UserDatabase();
  ThemeMode initialThemeMode = ThemeMode.system;

  /// An instance of firebase authentification, created in main because of testing.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// An instance of firebase firestore to store data, create in main because of testing.
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Sets the locale for the application.
  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void initState() {
    // Loading user preferences
    if (db.localePreferenceExist()) {
      Locale locale = db.loadLocale();
      setLocale(locale);
    }
    initialThemeMode = db.loadTheme();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(themeMode: initialThemeMode, userDb: db),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Notes',
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: ThemeData(useMaterial3: true, colorScheme: themeProvider.lightScheme),
            darkTheme: ThemeData(useMaterial3: true, colorScheme: themeProvider.darkScheme),
            themeMode: themeProvider.themeMode,
            locale: _locale,
            home: MainScreen(
              auth: _auth,
              firestore: _firestore,
            ),
          );
        },
      ),
    );
  }
}
