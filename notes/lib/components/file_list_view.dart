part of components;

/// Represents a list view for managing file system nodes such as directories and files in a Flutter application.
///
/// This widget provides interactive functionality for navigating directories, and manipulating files
/// and folders, such as creating, deleting, renaming, locking, and unlocking. It leverages the [MyTreeNode] class
/// to manage the state and representation of each node within the file system.
///
/// ## Parameters:
/// - `nodeId`: The ID of the initial node to display in the list view.
/// - `navigateWithParam`: A callback function that handles navigation and parameter passing when interacting
///   with nodes.
///
/// ## Usage Example:
/// ```dart
/// FileListView(
///   nodeId: 'root',  // Assuming 'root' is the ID of the root directory in your file system
///   navigateWithParam: (bool isNote, String nodeId) {
///     if (isNote) {
///       // Logic to open a note
///       Navigator.push(context, MaterialPageRoute(builder: (context) => NoteViewer(nodeId: nodeId)));
///     } else {
///       // Logic to navigate to a different directory
///       Navigator.push(context, MaterialPageRoute(builder: (context) => FileListView(nodeId: nodeId)));
///     }
///   },
/// )
/// ```
///
/// This widget maintains a dynamic view of file system nodes and responds to user interactions to
/// manipulate these nodes.
class FileListView extends StatefulWidget {
  /// The unique identifier of the initial file system node (e.g., a directory or file) to display.
  final String nodeId;

  /// A callback that handles navigation based on the node type (file/note) and its ID.
  final void Function(bool, String) navigateWithParam;

  /// Constructor of [FileListView]
  ///
  /// Requires two positional arguments:
  ///
  const FileListView({
    super.key,
    required this.nodeId,
    required this.navigateWithParam,
  });

  @override
  State<FileListView> createState() => _FileListViewState();
}

/// Manages the state for [FileListView], handling interactions and UI updates for a file system node list.
///
/// This state class manages operations like node creation, deletion, renaming, and moving within a tree-like
/// structure. It also handles UI interactions such as displaying dialogs for these operations.
class _FileListViewState extends State<FileListView> {
  /// Controller for text input in dialogs that require user text input.
  final _textDialogController = TextEditingController();

  /// Second controller for text input, used in scenarios requiring confirmation (e.g., password verification).
  final _textDialogController2 = TextEditingController();

  /// List of child nodes under the current node, used to build the dynamic list view.
  List<MyTreeNode> children = [];

  /// Service class for node operations like getting, adding, or removing nodes.
  NodeService service = NodeService();

  /// Flag to control the visibility of floating action buttons related to node operations.
  late bool _visibleButtons;

  // Initializes state, loads the current node and its children, and sets up initial UI states.
  @override
  void initState() {
    _visibleButtons = false;
    MyTreeNode? node = service.getNode(widget.nodeId);
    log("$node");
    if (node != null) {
      children = node.children;
    }
    log("Reolading: $node");
    super.initState();
  }

  // Cleans up controllers when the state object is removed from the tree permanently.
  @override
  void dispose() {
    _textDialogController.dispose();
    super.dispose();
  }

  /// Toggles the visibility of action buttons on the UI.
  void _toggleButtons() {
    setState(() {
      _visibleButtons = !_visibleButtons;
    });
  }

  /// Displays a dialog for confirming the deletion of a specified node.
  ///
  /// This method uses a custom [DeleteDialog] to prompt the user for confirmation before deleting a node.
  /// If confirmed, it triggers the `deleteNode` method; otherwise, it dismisses the dialog.
  ///
  /// - `node`: The [MyTreeNode] instance representing the node to be deleted.
  void showDeleteDialog(MyTreeNode node) {
    showDialog(
      context: context,
      builder: (context) {
        return DeleteDialog(
          titleText: AppLocalizations.of(context)!.deleteNode(node.title),
          contentText: AppLocalizations.of(context)!.deleteContent(node.title),
          onDelete: () => deleteNode(node),
          onCancel: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  /// Displays a dialog for renaming a specified node.
  ///
  /// This method provides a text field within a [TextFieldDialog] for the user to enter a new name for the node.
  /// The renaming is processed upon confirmation; the dialog is dismissed if canceled.
  ///
  /// - `node`: The [MyTreeNode] instance representing the node to be renamed.
  void showRenameDialog(MyTreeNode node) {
    showDialog(
      context: context,
      builder: (context) {
        return TextFieldDialog(
          titleText: AppLocalizations.of(context)!.renameNode(node.title),
          confirmButtonText: AppLocalizations.of(context)!.rename,
          controller: _textDialogController,
          onConfirm: () => renameNode(node),
          onCancel: () => closeAndClear(),
          hint: AppLocalizations.of(context)!.renameHint,
        );
      },
    );
  }

  /// Displays a dialog for creating a new node under a specified parent node.
  ///
  /// Depending on whether the new node is a note or a directory, this method adjusts the dialog contents
  /// accordingly. Upon confirmation, it triggers `createNode` to add the new node; the dialog is dismissed if canceled.
  ///
  /// - `node`: The [MyTreeNode] instance representing the parent node under which the new node will be created.
  /// - `isNote`: A boolean indicating if the new node is a note (`true`) or a directory (`false`).
  void showCreateDialog(MyTreeNode node, bool isNote) {
    showDialog(
      context: context,
      builder: (context) {
        return TextFieldDialog(
            titleText: isNote
                ? AppLocalizations.of(context)!.createNote
                : AppLocalizations.of(context)!.createFile,
            confirmButtonText: AppLocalizations.of(context)!.create,
            controller: _textDialogController,
            onConfirm: () => createNode(node, isNote),
            onCancel: () => closeAndClear(),
            hint: isNote
                ? AppLocalizations.of(context)!.newNoteHint
                : AppLocalizations.of(context)!.newDirectoryHint);
      },
    );
  }

  /// Displays a dialog that allows the user to move a node to a different location within the file system hierarchy.
  ///
  /// This dialog presents a list of potential new parent directories in a dropdown menu format. Upon confirmation,
  /// it executes the move operation via `moveNode`.
  ///
  /// - `node`: The [MyTreeNode] instance representing the node to be moved.
  void showMoveDialog(MyTreeNode node) {
    String? selectedValue;
    List<String> files = service.getFoldersToMove(node);
    List<DropdownMenuItem<String>> dropdownItems = files.map(
      (String option) {
        return DropdownMenuItem<String>(
          value: option,
          child: Text(option),
        );
      },
    ).toList();
    showDialog(
      context: context,
      builder: (context) {
        return DropdownMenuDialog(
          onConfirm: () => moveNode(node, selectedValue),
          onCancel: () => Navigator.of(context).pop(),
          titleText: AppLocalizations.of(context)!.menuMove,
          confirmButtonText: AppLocalizations.of(context)!.move,
          items: dropdownItems,
          selectedValue: selectedValue,
          onSelect: (value) {
            selectedValue = value;
          },
        );
      },
    );
  }

  /// Displays a dialog for unlocking a node that has been previously locked with a password.
  ///
  /// This method prompts the user to enter the correct password to unlock the node. If the user provides
  /// the correct password, the `unlockNode` method is called to unlock the node. The dialog will close
  /// either on a successful unlock or cancellation.
  ///
  /// - `node`: The [MyTreeNode] instance that is locked and needs to be unlocked.
  void showUnlockDialog(MyTreeNode node) {
    showDialog(
        context: context,
        builder: (context) {
          return EnterPasswordDialog(
              titleText: AppLocalizations.of(context)!.unlockNode(node.title),
              confirmButtonText: AppLocalizations.of(context)!.unlock,
              controller: _textDialogController,
              onConfirm: () => unlockNode(node),
              onCancel: () => closeAndClear());
        });
  }

  /// Displays a dialog for setting a password to lock a node, preventing unauthorized access.
  ///
  /// The user is required to enter and confirm a password. If the password entries match and the user confirms,
  /// the `lockNode` method is invoked to lock the node with the specified password. The dialog will close on
  /// confirmation or cancellation.
  ///
  /// - `node`: The [MyTreeNode] instance to be locked.
  void showLockDialog(MyTreeNode node) {
    showDialog(
        context: context,
        builder: (context) {
          return CreatePasswordDialog(
            titleText: AppLocalizations.of(context)!.lockNode(node.title),
            confirmButtonText: AppLocalizations.of(context)!.lock,
            controller1: _textDialogController,
            controller2: _textDialogController2,
            onConfirm: () => lockNode(node),
            onCancel: () => closeAndClear(),
          );
        });
  }

  /// Closes any open dialog and clears the text input controllers.
  void closeAndClear() {
    Navigator.of(context).pop();
    _textDialogController.clear();
  }

  /// Deletes a node from the file system and updates the UI.
  ///
  /// - `node`: The [MyTreeNode] instance to be deleted.
  void deleteNode(MyTreeNode node) {
    Navigator.of(context).pop();
    setState(() {
      service.deleteNode(node, service.getParent(node.id)!);
    });
  }

  /// Renames a node based on user input and updates the UI.
  ///
  /// - `node`: The [MyTreeNode] instance to be renamed.
  void renameNode(MyTreeNode node) {
    setState(
      () {
        if (service.renameNode(node, _textDialogController.text.trim(), context)) {
          closeAndClear();
        }
      },
    );
  }

  /// Creates a new node under a specific parent node and updates the UI.
  ///
  /// - `node`: The parent [MyTreeNode] under which the new node will be created.
  /// - `isNote`: Specifies whether the new node is a note (true) or a directory (false).
  void createNode(MyTreeNode node, bool isNote) {
    setState(
      () {
        if (service.createNewNode(node, _textDialogController.text.trim(), isNote, context)) {
          closeAndClear();
          log("Creating node: $node");
          MyTreeNode? widgetNode = service.getNode(widget.nodeId);
          log("$widgetNode");
          if (widgetNode != null) {
            children = node.children;
          }
        }
      },
    );
  }

  /// Moves a node to a new parent within the file hierarchy and updates the UI.
  ///
  /// - `node`: The [MyTreeNode] to be moved.
  /// - `newParent`: The ID of the new parent directory to move the node into.
  void moveNode(MyTreeNode node, String? newParent) {
    setState(
      () {
        if (newParent != null) {
          service.moveNode(node, newParent, context);
          Navigator.of(context).pop();
        }
      },
    );
  }

  /// Unlocks a locked node using a provided password.
  ///
  /// - `node`: The locked [MyTreeNode] to be unlocked.
  void unlockNode(MyTreeNode node) {
    setState(() {
      if (service.unlockNode(_textDialogController.text.trim(), node)) {
        closeAndClear();
      }
    });
  }

  /// Locks a node by setting a password as provided by the user.
  ///
  /// - `node`: The [MyTreeNode] to be locked.
  void lockNode(MyTreeNode node) {
    setState(() {
      if (service.lockNode(_textDialogController.text.trim(), node)) {
        closeAndClear();
      }
    });
  }

  // Builds the UI of the FileListView.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: children.isEmpty
          ? Column(
              children: [
                if (!service.isRoot(widget.nodeId))
                  Padding(
                    padding: const EdgeInsets.all(7),
                    child: FileListViewTile(
                      node: null,
                      touch: () => widget.navigateWithParam(
                        false,
                        service.getParentPath(widget.nodeId),
                      ),
                      delete: () {},
                      rename: () {},
                      createNote: () {},
                      createFile: () {},
                      move: () {},
                      lock: () {},
                      unlock: () {},
                    ),
                  ),
                Center(
                  child: Text(
                    AppLocalizations.of(context)!.emptyFile,
                    style: DEFAULT_TEXT_STYLE,
                  ),
                ),
              ],
            )
          : Padding(
              padding: const EdgeInsets.all(7),
              child: Align(
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!service.isRoot(widget.nodeId))
                        FileListViewTile(
                          node: null,
                          touch: () => widget.navigateWithParam(
                            false,
                            service.getParentPath(widget.nodeId),
                          ),
                          delete: () {},
                          rename: () {},
                          createNote: () {},
                          createFile: () {},
                          move: () {},
                          lock: () {},
                          unlock: () {},
                        ),
                      ListView.builder(
                        itemCount: children.length,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(1),
                            child: FileListViewTile(
                              node: children[index],
                              touch: () => widget.navigateWithParam(
                                children[index].isNote,
                                children[index].id,
                              ),
                              delete: () => showDeleteDialog(children[index]),
                              rename: () => showRenameDialog(children[index]),
                              createNote: () => showCreateDialog(children[index], true),
                              createFile: () => showCreateDialog(children[index], false),
                              move: () => showMoveDialog(children[index]),
                              lock: () => showLockDialog(children[index]),
                              unlock: () => showUnlockDialog(children[index]),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (!_visibleButtons)
            FloatingActionButton(
              onPressed: () {
                _toggleButtons();
              },
              child: const Icon(Icons.add),
            ),
          if (_visibleButtons)
            FloatingActionButton(
              onPressed: () {
                showCreateDialog(service.getNode(widget.nodeId)!, true);
              },
              tooltip: AppLocalizations.of(context)!.createNote,
              child: const Icon(Icons.article),
            ),
          if (_visibleButtons) const SizedBox(height: 16.0),
          if (_visibleButtons)
            FloatingActionButton(
              onPressed: () {
                showCreateDialog(service.getNode(widget.nodeId)!, false);
              },
              tooltip: AppLocalizations.of(context)!.createFile,
              child: const Icon(Icons.create_new_folder),
            ),
          if (_visibleButtons) const SizedBox(height: 16.0),
          if (_visibleButtons)
            FloatingActionButton(
              onPressed: () {
                _toggleButtons();
              },
              backgroundColor: Colors.red[300],
              child: const Icon(
                Icons.close,
                color: Color.fromARGB(255, 183, 28, 28),
              ),
            ),
        ],
      ),
    );
  }
}
