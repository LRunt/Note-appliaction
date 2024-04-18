import 'package:flutter/material.dart';

//------------------------------------------------------------------------------
//                          DATABASE CONSTANTS
//------------------------------------------------------------------------------
//                             HIVE DATABASE
//------------------------------------------------------------------------------
// Keys for [boxHierachy]
const String TREE_STORAGE = "TreeView";
const String CONFLICT = "Conflict";
// Keys for [boxSynchronization]
const String LAST_CHANGE = "lastChange";
const String LOCAL_SYNC = "lastSync";
const String NOTE_LIST = "noteList";
const String ROOT_LIST = "rootList";
// Keys for [boxNotes]
// Keys for [boxUser]
const String LOCALE = "locale";
const String THEME = "theme";

// User database constants (keys)
const String USER_LOGGED = "isLogged";
const String USER_USERNAME = "username";
const String USER_PASSWORD = "password";

// Names of boxes
const String BOX_TREE = "NotesDatabase";
const String BOX_NOTES = "Notes";
const String BOX_USERS = "User";
const String BOX_SYNCHRONIZATION = "Synchronization";

//------------------------------------------------------------------------------
//                             FIREBASE DATABASE
//------------------------------------------------------------------------------
// Firebase cloud constants
const String FIREBASE_NOTES = "user_notes";
const String FIREBASE_LAST_SYNC = "lastSync";
const String FIREBASE_TREE_PROPERTIES = "properties";
const String ROOTS_LAST_CHANGE = "rootsLastChange";
const String FIREBASE_ROOT_LIST = "rootList";

// Firebase fields
const String LAST_SYNC_FIELD = "Sync_timestamp";

// Firebase sync fields
const String FIREBASE_LAST_CHANGE = "lastChange";

// Firebase note fields
const String NOTES_LIST = "noteList";
const String NOTE_ID = "noteId";
const String CONTENT = "content";
const String NOTE_TIMESTAMP = "timestamp";

//------------------------------------------------------------------------------
//                          DESIGN CONSTANTS
//------------------------------------------------------------------------------
// Widgets decorative constants
const String OBSCURE_CHAR = '*';
const double DEFAULT_TEXT_SIZE = 16.0;
const double DEFAULT_GAP_SIZE = 30.0;
const double SMALL_GAP = 15.0;
const double ROW_TEXT_GAP = 4.0;
const double BORDER_RADIUS = 10.0;
const double BUTTON_BORDER_RADIUS = 5.0;
const double DEFAULT_PADDING = 10.0;
const double SETTINGS_BUTTON_SIZE = 130.0;
const double DEFAULT_PAGE_PADDING = 25.0;
const double TREE_VIEW_PADDING = 4.0;
const double MAX_WIDGET_WIDTH = 500.0;

// Bootstrap Colors
const Color COLOR_ERROR = Color.fromRGBO(220, 53, 69, 1.0);
const Color COLOR_INFO = Color.fromRGBO(13, 111, 253, 1.0);
const Color COLOR_SUCCESS = Color.fromRGBO(25, 135, 84, 1.0);
const Color COLOR_WARNING = Color.fromRGBO(255, 193, 7, 1.0);
const Color COLOR_DEFAULT_TOAST = Color.fromRGBO(100, 100, 100, 1.0);

const LIGHT_COLOR_SCHEME = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF00658F),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFC8E6FF),
  onPrimaryContainer: Color(0xFF001E2E),
  secondary: Color(0xFF006874),
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: Color(0xFF97F0FF),
  onSecondaryContainer: Color(0xFF001F24),
  tertiary: Color(0xFF00658F),
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: Color(0xFF97F0FF),
  onTertiaryContainer: Color(0xFF001F24),
  error: Color(0xFFBA1A1A),
  errorContainer: Color(0xFFFFDAD6),
  onError: Color(0xFFFFFFFF),
  onErrorContainer: Color(0xFF410002),
  background: Color(0xFFFCFCFF),
  onBackground: Color(0xFF191C1E),
  surface: Color(0xFFFCFCFF),
  onSurface: Color(0xFF191C1E),
  surfaceVariant: Color(0xFFDDE3EA),
  onSurfaceVariant: Color(0xFF41484D),
  outline: Color(0xFF71787E),
  onInverseSurface: Color(0xFFF0F0F3),
  inverseSurface: Color(0xFFFFFFFF),
  inversePrimary: Color(0xFF87CEFF),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFF00658F),
  outlineVariant: Color(0xFFC1C7CE),
  scrim: Color(0xFF000000),
);

const DARK_COLOR_SCHEME = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFFCAE0E4),
  onPrimary: Color(0xFF00344D),
  primaryContainer: Color(0xFF004C6D),
  onPrimaryContainer: Color(0xFFC8E6FF),
  secondary: Color(0xFF4FD8EB),
  onSecondary: Color(0xFF00363D),
  secondaryContainer: Color(0xFF004F58),
  onSecondaryContainer: Color(0xFF97F0FF),
  tertiary: Color(0xFF004C6D),
  onTertiary: Color(0xFF00363D),
  tertiaryContainer: Color(0xFF004F58),
  onTertiaryContainer: Color(0xFF97F0FF),
  error: Color(0xFFFFB4AB),
  errorContainer: Color(0xFF93000A),
  onError: Color(0xFF690005),
  onErrorContainer: Color(0xFFFFDAD6),
  background: Color(0xFF191C1E),
  onBackground: Color(0xFFE2E2E5),
  surface: Color(0xFF191C1E),
  onSurface: Color(0xFFE2E2E5),
  surfaceVariant: Color(0xFF41484D),
  onSurfaceVariant: Color(0xFFC1C7CE),
  outline: Color(0xFF8B9198),
  onInverseSurface: Color(0xFF191C1E),
  inverseSurface: Color(0xFFE2E2E5),
  inversePrimary: Color(0xFF00658F),
  shadow: Color(0xFF000000),
  surfaceTint: Color(0xFF87CEFF),
  outlineVariant: Color(0xFF41484D),
  scrim: Color(0xFF000000),
);

//------------------------------------------------------------------------------
//                          LOGIC CONSTANTS
//------------------------------------------------------------------------------
// Main screen page types
const int MAIN_SCREEN = 0;
const int NOTE_SCREEN = 1;
const int DIRECTORY_SCREEN = 2;

const String DELIMITER = "|";
const List DISABLED_CHARS = ["|", "/"];

// Theme constants
const String LIGHT = "light";
const String DARK = "dark";
const String SYSTEM = "system";

// Success
const String SUCCESS = "Success";

//------------------------------------------------------------------------------
//                            WIDGETS
//------------------------------------------------------------------------------
ButtonStyle defaultButtonStyle = ButtonStyle(
  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
    RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(BUTTON_BORDER_RADIUS),
    ),
  ),
);

RoundedRectangleBorder dialogBorder = const RoundedRectangleBorder(
  borderRadius: BorderRadius.all(
    Radius.circular(BORDER_RADIUS),
  ),
);

TextStyle defaultTextStyle = const TextStyle(fontSize: DEFAULT_TEXT_SIZE);

//------------------------------------------------------------------------------
//                          PICTURE PATHS
//------------------------------------------------------------------------------
const String GOOGLE_AUTH_IMG = 'assets/google.png';
