import 'package:flutter/material.dart';

// Keys for [boxHierachy]
const String TREE_STORAGE = "TreeView";
// Keys for [boxSynchronization]
const String TREE_CHANGE = "tree_change";
const String TREE_SYNC = "tree_sync";
// Keys for [boxUser]
const String LOCALE = "locale";

// User database constants (keys)
const String USER_LOGGED = "isLogged";
const String USER_USERNAME = "username";
const String USER_PASSWORD = "password";

// Names of boxes
const String BOX_TREE = "Notes_Database";
const String BOX_NOTES = "Notes";
const String BOX_USERS = "User";
const String BOX_SYNCHRONIZATION = "Synchronization";

// Firebase cloud constants
const String FIREBASE_TREE = "user_tree";
const String FIREBASE_TREE_TIME = "tree_time";
const String FIREBASE_NOTES = "user_notes";

const String DELIMITER = "|";

// Widgets decorative constants
const String OBSCURE_CHAR = '*';
const double DEFAULT_TEXT_SIZE = 16.0;
const double DEFAULT_GAP_SIZE = 30.0;
const double BORDER_RADIUS = 10.0;
const double BUTTON_BORDER_RADIUS = 5.0;

// Bootstrap Colors
const Color COLOR_ERROR = Color.fromRGBO(220, 53, 69, 1.0);
const Color COLOR_INFO = Color.fromRGBO(13, 111, 253, 1.0);
const Color COLOR_SUCCESS = Color.fromRGBO(25, 135, 84, 1.0);
const Color COLOR_WARNING = Color.fromRGBO(255, 193, 7, 1.0);

// Main screen page types
const int WELCOME_SCREEN = 0;
const int NOTE_SCREEN = 1;
const int DIRECTORY_SCREEN = 2;
