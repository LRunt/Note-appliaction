part of screens;

/// A StatefulWidget that serves as the main screen of the application.
///
/// This screen is responsible for coordinating interactions between various services such as authentication,
/// database interactions, and managing the user interface for different parts of the application.
/// It provides a scaffold where different pages or views can be loaded based on user interactions.
class MainScreen extends StatefulWidget {
  /// FirebaseAuth instance for managing authentication.
  final FirebaseAuth auth;

  /// FirebaseFirestore instance for managing cloud database operations.
  final FirebaseFirestore firestore;

  /// Constructs a MainScreen widget which initializes Firebase services.
  ///
  /// - `auth`: Firebase Authentication instance to handle user authentication.
  /// - `firestore`: Firebase Firestore instance for database interactions.
  const MainScreen({
    super.key,
    required this.auth,
    required this.firestore,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

/// The state class for the MainScreen widget, responsible for managing its state and behavior.
///
/// This class implements the functionality for handling user interactions, navigating between screens,
/// controlling synchronization, and managing the UI components displayed on the main screen of the application.
class _MainScreenState extends State<MainScreen> {
  /// Integer variable representing the type of the current page.
  int _pageType = 0;

  /// String variable representing the ID of the current note.
  String _noteId = "";

  /// Key variable for the tree view, initialized with a unique key.
  Key treeViewKey = UniqueKey();

  /// String variable representing the last synchronization time.
  String lastSync = "";

  /// Integer variable representing the count of main screen interactions.
  int mainScreenCount = 0;

  /// Database instance for managing data clearance.
  ClearDatabase db = ClearDatabase();

  /// Database instance for managing user data.
  UserDatabase userDB = UserDatabase();

  /// Service instance for managing nodes.
  NodeService nodeService = NodeService();

  /// Database instance for managing synchronization.
  SynchronizationDatabase syncDb = SynchronizationDatabase();

  /// Firestore service instance for interacting with Firestore.
  late final FirestoreService firestoreService;

  /// Stream subscription for listening to authentication state changes.
  late StreamSubscription<User?> authStateSubscription;

  /// Controller for handling text input in dialogs.
  final _textDialogController = TextEditingController();

  // Initializes the state of the widget.
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

  /// Disposes resources used by the widget.
  @override
  void dispose() {
    authStateSubscription.cancel();
    _textDialogController.dispose();
    super.dispose();
  }

  /// Checks if a note is locked and handles screen navigation accordingly.
  ///
  /// - [isNote]: A boolean indicating whether the item is a note.
  /// - [id]: The ID of the item.
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
                  titleText: AppLocalizations.of(context)!.unlockNode(node.title),
                  confirmButtonText: AppLocalizations.of(context)!.unlock,
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

  /// Changes the screen to the specified type and ID.
  /// - [screenType]: The type of the screen to change to.
  /// - [id]: The ID of the note.
  void _changeScreen(int screenType, String id) {
    setState(() {
      log("Changing screen");
      _noteId = id;
      _pageType = screenType;
      log("Page type: $_pageType, Note id: $_noteId");
    });
  }

  /// Reloads the tree view.
  ///
  /// Sets the state to generate a new unique key for the tree view and updates the last synchronization time.
  void reloadTreeView() {
    log("reloading tree");
    setState(() {
      treeViewKey = UniqueKey();
      lastSync = UtilService.getFormattedDate(syncDb.getLastSyncTime());
    });
  }

  /// Navigates to a screen with the given parameters.
  ///
  /// - [isNote]: A boolean indicating whether the item is a note.
  /// - [id]: The ID of the item.
  void navigateWithParam(bool isNote, String id) {
    log("Navigation $id");
    if (isNote) {
      _changeScreen(NOTE_SCREEN, id);
    } else {
      _changeScreen(DIRECTORY_SCREEN, id);
    }
  }

  /// Handles the 'onChange' event.
  ///
  /// Increments the mainScreenCount and changes the screen to the main screen.
  void onChange() {
    log("On change");
    mainScreenCount++;
    _changeScreen(MAIN_SCREEN, "");
  }

  /// Deletes data and resets the state.
  void deleteData() {
    lastSync = "";
    mainScreenCount++;
    _changeScreen(MAIN_SCREEN, "");
  }

  // Builds the UI of the main screen.
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
      backgroundColor: _pageType == DIRECTORY_SCREEN
          ? Theme.of(context).colorScheme.surfaceVariant
          : Theme.of(context).scaffoldBackgroundColor,
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
                    builder: (context) => SettingsPage(
                      onCleanDataAction: () => deleteData(),
                    ),
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
              loginSuccess: () {
                log("login success");
                reloadTreeView();
              },
              logoutSuccess: () {
                reloadTreeView();
                _changeScreen(0, "");
              },
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
                    StyledButton(
                        onTap: () async {
                          await firestoreService.synchronize(context);
                          reloadTreeView();
                          onChange();
                          log(lastSync);
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
