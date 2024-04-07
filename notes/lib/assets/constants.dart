import 'package:flutter/material.dart';

// Keys for [boxHierachy]
const String TREE_STORAGE = "TreeView";
const String CONFLICT = "conflict";
// Keys for [boxSynchronization]
const String LAST_CHANGE = "lastChange";
//const String TREE_CHANGE = "treeChange";
const String LOCAL_SYNC = "lastSync";
const String NOTE_LIST = "noteList";
const String ROOT_LIST = "rootList";
// Keys for [boxNotes]
// Keys for [boxUser]
const String LOCALE = "locale";

// User database constants (keys)
const String USER_LOGGED = "isLogged";
const String USER_USERNAME = "username";
const String USER_PASSWORD = "password";

// Names of boxes
const String BOX_TREE = "NotesDatabase";
const String BOX_NOTES = "Notes";
const String BOX_USERS = "User";
const String BOX_SYNCHRONIZATION = "Synchronization";

// Firebase cloud constants
const String FIREBASE_TREE = "user_tree";
const String FIREBASE_TREE_TIME = "tree_time";
const String FIREBASE_NOTES = "user_notes";
const String FIREBASE_LAST_SYNC = "last_sync";
const String FIREBASE_NOTES_LIST = "notes";
const String FIREBASE_TREE_PROPERTIES = "properties";

// Firebase fields
const String LAST_SYNC_FIELD = "Sync_timestamp";

const String DELIMITER = "|";
const List DISABLED_CHARS = ["|", "/"];

// Widgets decorative constants
const String OBSCURE_CHAR = '*';
const double DEFAULT_TEXT_SIZE = 16.0;
const double DEFAULT_GAP_SIZE = 30.0;
const double SMALL_GAP = 15.0;
const double ROW_TEXT_GAP = 4.0;
const double BORDER_RADIUS = 10.0;
const double BUTTON_BORDER_RADIUS = 5.0;

// Bootstrap Colors
const Color COLOR_ERROR = Color.fromRGBO(220, 53, 69, 1.0);
const Color COLOR_INFO = Color.fromRGBO(13, 111, 253, 1.0);
const Color COLOR_SUCCESS = Color.fromRGBO(25, 135, 84, 1.0);
const Color COLOR_WARNING = Color.fromRGBO(255, 193, 7, 1.0);
const Color COLOR_DEFAULT_TOAST = Color.fromRGBO(100, 100, 100, 1.0);

// Main screen page types
const int WELCOME_SCREEN = 0;
const int NOTE_SCREEN = 1;
const int DIRECTORY_SCREEN = 2;

// Pictures paths
const String GOOGLE_AUTH_IMG = 'assets/google.png';
