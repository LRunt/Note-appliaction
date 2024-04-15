part of local_databases;

/// Class [HierarchyDatabase] manages hierarchical data in the local storage.
///
/// This database class provides methods for creating, updating, and deleting hierarchical data,
/// such as roots and notes, in the local database.
class HierarchyDatabase {
  /// List of root nodes in the hierarchy database.
  static List<MyTreeNode> roots = [];

  /// List of root node IDs stored in the hierarchy database.
  static List rootList = [];

  /// List of note IDs stored in the hierarchy database.
  static List noteList = [];

  /// List of conflict data nodes in the hierarchy database.
  static List<MyTreeNode> conflictData = [];

  /// Checks if a root data exists in the local database.
  ///
  /// Returns `true` if a root data not exists, otherwise `false`.
  bool rootDataNotExist() {
    return !boxSynchronization.containsKey(ROOT_LIST) || boxSynchronization.get(ROOT_LIST) == null;
  }

  /// Creates default data for the database.
  ///
  /// Initializes lists and stores them in the local database.
  void createDefaultData() {
    boxSynchronization.put(ROOT_LIST, []);
    boxSynchronization.put(NOTE_LIST, []);
    MyTreeNode conflictNode =
        MyTreeNode(id: CONFLICT, title: CONFLICT, isNote: false, isLocked: false);
    boxSynchronization.put(CONFLICT, conflictNode);
  }

  /// Loads data from the local database.
  ///
  /// Retrieves root list from the database and initializes roots accordingly.
  void loadData() {
    log("Loading data...");

    roots = [];
    rootList = boxSynchronization.get(ROOT_LIST);
    log("Root list: $rootList");
    for (String root in rootList) {
      MyTreeNode node = boxHierachy.get(root);
      log("Adding node: $root, node: $node");
      roots.add(node);
    }
  }

  /// Saves a root node to the local database.
  ///
  /// [root] is the root node to be saved.
  void saveRoot(MyTreeNode root) {
    log("Creating root");
    roots.add(root);
    rootList.add(root.id);
    log("Root list $rootList");
    boxSynchronization.put(ROOT_LIST, rootList);
    boxSynchronization.put(root.id, DateTime.now().microsecondsSinceEpoch);
    boxHierachy.put(root.id, root);
    boxSynchronization.put(LAST_CHANGE, DateTime.now().microsecondsSinceEpoch);
  }

  /// Saves a list of root nodes to the local database.
  ///
  /// [rootList] is the list of root nodes to be saved.
  void saveRootList(List rootList) {
    log("Saving rootList: $rootList");
    boxSynchronization.put(ROOT_LIST, rootList);
    rootList = boxSynchronization.get(ROOT_LIST);
    log("Rootlist after synchronization: ");
  }

  /// Downloads a root node from an external source and saves it to the local database.
  ///
  /// [root] is the root node to be downloaded.
  /// [lastChangeTime] is the timestamp of the last change for the root node.
  void downloadRoot(MyTreeNode root, int lastChangeTime) {
    boxSynchronization.put(root.id, lastChangeTime);
    boxHierachy.put(root.id, root);
  }

  /// Deletes a root node from the local database.
  ///
  /// [root] is the root node to be deleted.
  void deleteRoot(MyTreeNode root) {
    log("Deleting root");
    rootList.remove(root.id);
    roots.remove(root);
    boxSynchronization.put(ROOT_LIST, rootList);
    boxSynchronization.delete(root.id);
    boxHierachy.delete(root.id);
    updateDatabase();
  }

  /// Updates the ID of a root node in the local database.
  ///
  /// [oldRootId] is the old ID of the root node.
  /// [newRootId] is the new ID of the root node.
  void updateRoot(String oldRootId, String newRootId) {
    log("Update root");
    rootList = boxSynchronization.get(ROOT_LIST);
    rootList.remove(oldRootId);
    rootList.add(newRootId);
    log("$rootList");
    boxSynchronization.delete(oldRootId);
    boxSynchronization.put(newRootId, DateTime.now().microsecondsSinceEpoch);
    boxSynchronization.put(LAST_CHANGE, DateTime.now().microsecondsSinceEpoch);
    boxSynchronization.put(ROOT_LIST, rootList);
  }

  /// Updates the last change time of a root node in the local database.
  ///
  /// [rootId] is the ID of the root node.
  updateRootLastChangeTime(String rootId) {
    boxSynchronization.put(rootId, DateTime.now().microsecondsSinceEpoch);
    boxSynchronization.put(LAST_CHANGE, DateTime.now().microsecondsSinceEpoch);
  }

  /// Updates the entire database with the current root nodes and their hierarchy.
  void updateDatabase() {
    log("Updating database: ${roots.firstOrNull}");
    boxSynchronization.put(ROOT_LIST, rootList);
    for (MyTreeNode root in roots) {
      boxHierachy.put(root.id, root);
    }
    // Adding timestamp of last change
    boxSynchronization.put(LAST_CHANGE, DateTime.now().microsecondsSinceEpoch);
  }

  /// Adds a note to the list of notes in the local database.
  ///
  /// [noteId] is the ID of the note to be added.
  void addNote(String noteId) {
    noteList = boxSynchronization.get(NOTE_LIST);
    noteList.add(noteId);
    log("$noteList");
    boxSynchronization.put(NOTE_LIST, noteList);
  }

  /// Deletes a note from the list of notes in the local database.
  ///
  /// [noteId] is the ID of the note to be deleted.
  void deleteNote(String noteId) {
    noteList = boxSynchronization.get(NOTE_LIST);
    noteList.remove(noteId);
    log("$noteList");
    boxSynchronization.put(NOTE_LIST, noteList);
  }

  /// Updates the ID of a note in the list of notes in the local database.
  ///
  /// [oldNoteId] is the old ID of the note.
  /// [newNoteId] is the new ID of the note.
  void updateNote(String oldNoteId, String newNoteId) {
    noteList = boxSynchronization.get(NOTE_LIST);
    noteList.remove(oldNoteId);
    noteList.add(newNoteId);
    log("$noteList");
    boxSynchronization.put(NOTE_LIST, noteList);
  }

  /// Retrieves a root node from the local database based on its ID.
  ///
  /// [rootId] is the ID of the root node to be retrieved.
  MyTreeNode getRoot(String rootId) {
    return boxHierachy.get(rootId);
  }

  /// Retrieves the last change time of a root node from the local database.
  ///
  /// [rootId] is the ID of the root node.
  int getRootLastChangeTime(String rootId) {
    return boxSynchronization.get(rootId);
  }

  /// Retrieves the list of notes from the local database.
  List getNoteList() {
    return boxSynchronization.get(NOTE_LIST);
  }

  /// Retrieves the list of root nodes from the local database.
  List getRootList() {
    return boxSynchronization.get(ROOT_LIST);
  }

  /// Saves the list of notes to the local database.
  ///
  /// [notes] is the list of notes to be saved.
  void saveNoteList(List notes) {
    noteList = notes;
    boxSynchronization.put(NOTE_LIST, notes);
  }

//------------------------------------------------------------------------------
//                             CONFLICT DATA
//------------------------------------------------------------------------------

  /// Checks if a conflict data exists in the local database.
  ///
  /// Returns `true` if a conflict data not exists, otherwise `false`.
  bool conflictDataNotExist() {
    return !boxHierachy.containsKey(CONFLICT) || boxHierachy.get(CONFLICT) == null;
  }

  /// Saves conflict data to the local database.
  void saveConflictData() {
    if (conflictDataNotExist()) {
      initConflictData();
    }
    MyTreeNode conflicts = boxHierachy.get(CONFLICT);
    String name = CONFLICT + DateTime.now().toString();
    MyTreeNode newConflict = MyTreeNode(id: name, title: name, isNote: false, isLocked: false);
    newConflict.addChild(roots.first);
    conflicts.addChild(newConflict);
    boxHierachy.put(CONFLICT, conflicts);
  }

  void saveConflict(MyTreeNode node) {
    if (conflictDataNotExist()) {
      initConflictData();
    }
    MyTreeNode conflict = boxHierachy.get(CONFLICT);
    conflict.addChild(node);
    boxHierachy.put(CONFLICT, conflict);
  }

  /// Saves conflict note to the local database.
  ///
  /// [noteId] is the ID of the note to be saved as a conflict.
  void saveConflictNote(MyTreeNode note, String noteId) {
    if (conflictDataNotExist()) {
      initConflictData();
    }
    MyTreeNode conflict = boxHierachy.get(CONFLICT);
    conflict.addChild(note);
    boxHierachy.put(CONFLICT, conflict);
    String content = boxNotes.get(noteId);
    boxNotes.put(note.id, content);
  }

  /// Saves conflict root to the local database.
  ///
  /// [rootId] is the ID of the root node to be saved as a conflict.
  void saveConflictRoot(String rootId) {
    if (conflictDataNotExist()) {
      initConflictData();
    }
    MyTreeNode conflicts = boxHierachy.get(CONFLICT);
    String name = CONFLICT + DateTime.now().toString() + DELIMITER + rootId;
    MyTreeNode newConflict = MyTreeNode(id: name, title: name, isNote: false, isLocked: false);
    conflicts.addChild(newConflict);
  }

  /// Loads conflict data from the local database.
  void loadConflictData() {
    MyTreeNode conflicts = boxHierachy.get(CONFLICT);
    conflictData = conflicts.children;
  }

  /// Initializes conflict data in the local database.
  void initConflictData() {
    MyTreeNode conflictNode =
        MyTreeNode(id: CONFLICT, title: CONFLICT, isNote: false, isLocked: false);
    boxHierachy.put(CONFLICT, conflictNode);
  }

  MyTreeNode getConflictNode() {
    return boxHierachy.get(CONFLICT);
  }

  void deleteConflictNote(String conflictNoteId) {
    boxNotes.delete(conflictNoteId);
  }

  void saveConflictNode(MyTreeNode node) {
    conflictData = node.children;
    boxHierachy.put(CONFLICT, node);
  }
}
