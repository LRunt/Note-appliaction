import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:notes/components/components.dart';
import 'package:notes/constants.dart';
import 'package:notes/components/dialogs/dialogs.dart';
import 'package:notes/data/local_databases.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notes/model/my_tree_node.dart';
import 'package:notes/services/services.dart';

/// A custom implementation of a tree view for displaying hierarchical structures.
///
/// This widget is designed to display a tree of nodes, where each node can represent
/// a note or a folder in the context of a note-taking application. It utilizes the
/// `flutter_fancy_tree_view` package to manage and display the tree structure. Users
/// can interact with the tree by tapping on nodes to navigate, or by long-pressing
/// to access additional options such as rename, delete, or create a new node.
///
/// The tree view is dynamic, allowing for the tree structure to be modified through
/// user interaction, reflecting changes in real-time. This includes operations like
/// adding, renaming, and deleting nodes.
///
/// The widget requires a navigation callback function, `navigateWithParam`, which
/// should be implemented to handle navigation actions triggered by tapping on a node.
///
/// ## Parameters:
/// - `navigateWithParam`: A callback function that is triggered when an item in the tree is selected. This function
///   facilitates navigation by taking a boolean, which indicates if the selected item is a note, and a string,
///   which represents the ID of the selected item.
/// - `onChange`: A callback function that is triggered when any change occurs in the tree view, such as selection,
///   expansion, or data modification.
///
/// ## Usage:
/// ```dart
/// MyTreeView(navigateWithParam: (int param, String id) {
///   // Implementation for navigation
/// });
/// ```
class MyTreeView extends StatefulWidget {
  /// A callback function used for navigating with a specified parameter.
  /// The function takes an type of the page as integer and a noteId as string as parameters.
  final void Function(bool, String) navigateWithParam;

  /// A callback function that is called when any change happens within the tree view.
  final VoidCallback onChange;

  /// Constructor of the [MyTreeView] class.
  ///
  /// - `navigateWithParam`: The navigation function which takes parameters for type and ID of the item selected.
  /// - `onChange`: The function that triggers when the tree view has changed in any form.
  const MyTreeView({
    super.key,
    required this.navigateWithParam,
    required this.onChange,
  });

  @override
  State<MyTreeView> createState() => _MyTreeViewState();
}

/// Manages the state of the [MyTreeView] widget, handling the tree data structure, interactions, and database connections.
///
/// This class is responsible for initializing the state of the tree view, loading data, managing tree interactions,
/// and ensuring resources are properly disposed of when no longer needed.
class _MyTreeViewState extends State<MyTreeView> {
  /// Controls the tree structure, providing functionality to manage the hierarchical arrangement of nodes.
  late final TreeController<MyTreeNode> treeController;

  /// The database instance for managing and persisting tree node data.
  HierarchyDatabase hierarchyDb = HierarchyDatabase();

  /// Text editing controller for dialog inputs, used for creating new directories or nodes.
  final _textDialogController = TextEditingController();

  /// Service for node-specific operations such as creation and management.
  NodeService nodeService = NodeService();

  // Initializes the tree view, either by loading existing data from the database or creating default data if none exists.
  @override
  void initState() {
    log("reloading tree");
    //there is no initial state, first time the application runs
    if (hierarchyDb.rootDataNotExist()) {
      log("Creating new data!");
      hierarchyDb.createDefaultData();
    }
    //there are saved data
    else {
      log("Loading data!");
      hierarchyDb.loadData();
    }

    treeController = TreeController<MyTreeNode>(
      roots: HierarchyDatabase.roots,
      childrenProvider: (MyTreeNode node) => node.children,
    );
    super.initState();
  }

  // Disposes of the tree controller and text controller to free up resources and prevent memory leaks.
  @override
  void dispose() {
    // Remember to dispose your tree controller to release resources.
    treeController.dispose();
    super.dispose();
  }

  /// Displays a dialog allowing the user to create a new directory or node.
  ///
  /// This method prompts the user with a text input to enter the name of the new directory or node.
  /// Upon confirmation, it attempts to create the new node and rebuilds the tree view to reflect the changes.
  ///
  /// - `context`: The BuildContext for locating the Scaffold used to show dialogs.
  void showCreateDialog(bool isNote, BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return TextFieldDialog(
            titleText: isNote
                ? AppLocalizations.of(context)!.createNote
                : AppLocalizations.of(context)!.createFile,
            confirmButtonText: AppLocalizations.of(context)!.create,
            controller: _textDialogController,
            onConfirm: () {
              if (nodeService.createNewRoot(_textDialogController.text.trim(), isNote, context)) {
                Navigator.of(context).pop();
                treeController.rebuild();
                _textDialogController.clear();
              }
            },
            onCancel: () {
              _textDialogController.clear();
              Navigator.of(context).pop();
            },
            hint: isNote
                ? AppLocalizations.of(context)!.newNoteHint
                : AppLocalizations.of(context)!.newDirectoryHint,
          );
        });
  }

  // Builds the UI of hierarchical structure.
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TreeView<MyTreeNode>(
          shrinkWrap: true,
          treeController: treeController,
          nodeBuilder: (BuildContext context, TreeEntry<MyTreeNode> entry) {
            return MyTreeTile(
                key: ValueKey(entry.node),
                entry: entry,
                onTap: () => treeController.toggleExpansion(entry.node),
                navigate: () => widget.navigateWithParam(
                      entry.node.isNote,
                      entry.node.id,
                    ),
                onChange: () => widget.onChange(),
                treeController: treeController,
                db: hierarchyDb);
          },
        ),
        SizedBox(
          width: DRAWER_BUTTON_SIZE,
          child: FilledButton.icon(
            icon: const Icon(Icons.create_new_folder_rounded),
            label: Text(AppLocalizations.of(context)!.createFile),
            onPressed: () {
              showCreateDialog(false, context);
            },
          ),
        ),
        SizedBox(
          width: DRAWER_BUTTON_SIZE,
          child: FilledButton.icon(
            icon: const Icon(Icons.article),
            label: Text(AppLocalizations.of(context)!.createNote),
            onPressed: () {
              showCreateDialog(true, context);
            },
          ),
        ),
      ],
    );
  }
}

/// A custom widget representing a single node (or tile) within the tree view.
///
/// This widget is designed to display the content of a node, including the node's
/// title and an optional folder icon indicating whether the node has children. It
/// supports interactions such as tapping to navigate or perform actions, and
/// long-pressing to open a menu with additional options (rename, delete, create).
///
/// The widget utilizes dialogs for user interactions like renaming or deleting nodes,
/// ensuring a consistent and user-friendly experience.
class MyTreeTile extends StatelessWidget {
  /// The one entry of the tree.
  final TreeEntry<MyTreeNode> entry;

  /// Reaction on the tap on the icon of the directory.
  final VoidCallback onTap;

  /// Reaction on the tap on the node.
  final VoidCallback navigate;

  /// Reaction on the change of the hieararchy.
  final VoidCallback onChange;

  /// Controller of the hierarchy.
  final TreeController treeController;

  /// Database where are the data localy stored.
  final HierarchyDatabase db;

  /// Service for managing node-specific operations such as creation, deletion, and updates.
  final NodeService nodeService = NodeService();

  /// Controller for text input in dialogs that require user text input.
  final _textDialogController = TextEditingController();

  /// Second controller for text input, used in scenarios requiring confirmation (e.g., password verification).
  final _textDialogController2 = TextEditingController();

  /// Constructor of the class [MyTreeTile].
  ///
  /// - `entry`: The tree node data this tile represents.
  /// - `onTap`: The function to call when the folder icon is tapped.
  /// - `navigate`: The function to call when the tile is tapped.
  /// - `onChange`: The function to call when there are changes in the tree hierarchy.
  /// - `treeController`: The controller for managing tree interactions.
  /// - db: The database handling local storage of node data.
  MyTreeTile(
      {super.key,
      required this.entry,
      required this.onTap,
      required this.navigate,
      required this.onChange,
      required this.treeController,
      required this.db});

  /// Displays a confirmation dialog asking if the user is sure about deleting the specified node.
  ///
  /// The dialog provides options to either confirm the deletion or cancel the operation. If confirmed,
  /// the node is deleted via the `deleteNode` method. If cancelled, the dialog is closed without any changes.
  ///
  /// - `context`: The BuildContext used to show the dialog.
  /// - `node`: The [MyTreeNode] instance that might be deleted.
  void showDeleteDialog(BuildContext context, MyTreeNode node) {
    showDialog(
        context: context,
        builder: (context) {
          return DeleteDialog(
            titleText: AppLocalizations.of(context)!.deleteNode(node.title),
            contentText: AppLocalizations.of(context)!.deleteContent(node.title),
            onDelete: () => deleteNode(context, node),
            onCancel: () => closeAndClear(context),
          );
        });
  }

  /// Displays a dialog for renaming a specified node.
  ///
  /// This dialog prompts the user to enter a new name for the node in a text field. The renaming is committed if the
  /// user confirms; otherwise, the dialog is closed and no changes are made.
  ///
  /// - `context`: The BuildContext used to show the dialog.
  /// - `node`: The [MyTreeNode] instance to be renamed.
  void showRenameDialog(BuildContext context, MyTreeNode node) {
    showDialog(
        context: context,
        builder: (context) {
          return TextFieldDialog(
            titleText: AppLocalizations.of(context)!.renameNode(node.title),
            confirmButtonText: AppLocalizations.of(context)!.rename,
            controller: _textDialogController,
            onConfirm: () => renameNode(context, node),
            onCancel: () => closeAndClear(context),
            hint: AppLocalizations.of(context)!.renameHint,
          );
        });
  }

  /// Displays a dialog for creating a new directory or note under the specified parent node.
  ///
  /// The dialog allows the user to specify the type of node (note or directory) and enter the name for the new node.
  /// The node creation is executed if the user confirms; otherwise, the dialog is closed and no changes are made.
  ///
  /// - `context`: The BuildContext used to show the dialog.
  /// - `node`: The [MyTreeNode] parent under which the new node will be created.
  /// - `isNote`: A boolean indicating whether the new node should be a note (`true`) or a directory (`false`).
  void showCreateDialog(BuildContext context, MyTreeNode node, bool isNote) {
    showDialog(
        context: context,
        builder: (context) {
          return TextFieldDialog(
            titleText: isNote
                ? AppLocalizations.of(context)!.createNote
                : AppLocalizations.of(context)!.createFile,
            confirmButtonText: AppLocalizations.of(context)!.create,
            controller: _textDialogController,
            onConfirm: () => createNode(context, node, isNote),
            onCancel: () => closeAndClear(context),
            hint: isNote
                ? AppLocalizations.of(context)!.newNoteHint
                : AppLocalizations.of(context)!.newDirectoryHint,
          );
        });
  }

  /// Displays a dialog for setting a password to lock a specified node.
  ///
  /// This dialog prompts the user to enter and confirm a password to lock the node, providing security
  /// for sensitive content. The node is locked if the user confirms and the passwords match.
  ///
  /// - `context`: The BuildContext used to show the dialog.
  /// - `node`: The [MyTreeNode] instance to be locked.
  void showLockDialog(BuildContext context, MyTreeNode node) {
    showDialog(
        context: context,
        builder: (context) {
          return CreatePasswordDialog(
              titleText: AppLocalizations.of(context)!.lockNode(node.title),
              confirmButtonText: AppLocalizations.of(context)!.lock,
              controller1: _textDialogController,
              controller2: _textDialogController2,
              onConfirm: () => lockNode(context, node),
              onCancel: () => closeAndClear(context));
        });
  }

  /// Displays a dialog for unlocking a node by entering a password.
  ///
  /// This dialog prompts the user to enter the password set for the node. If the correct password
  /// is entered, the node is unlocked, allowing access to the content.
  ///
  /// - `context`: The BuildContext used to show the dialog.
  /// - `node`: The [MyTreeNode] instance that is locked and needs to be unlocked.
  void showUnlockDialog(BuildContext context, MyTreeNode node) {
    showDialog(
        context: context,
        builder: (context) {
          return EnterPasswordDialog(
              titleText: AppLocalizations.of(context)!.unlockNode(node.title),
              confirmButtonText: AppLocalizations.of(context)!.unlock,
              controller: _textDialogController,
              onConfirm: () => unlockNode(context, node),
              onCancel: () => closeAndClear(context));
        });
  }

  /// Displays a dialog to select a new parent directory for moving a node within the tree structure.
  ///
  /// This dialog shows a dropdown menu of available directories to which the node can be moved.
  /// The node is moved to the selected directory if the user confirms the action.
  ///
  /// - `context`: The BuildContext used to show the dialog.
  /// - `node`: The [MyTreeNode] instance to be moved.
  void showMoveDialog(BuildContext context, MyTreeNode node) {
    String? selectedValue;
    List<String> files = nodeService.getFoldersToMove(node);
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
          onConfirm: () => moveNode(node, selectedValue, context),
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

  /// Moves a node to a new parent within the tree structure and updates the tree view.
  ///
  /// - `node`: The node to be moved.
  /// - `newParent`: The ID of the new parent node to which the node should be moved.
  /// - `context`: The current BuildContext, used for navigating and displaying information.
  void moveNode(MyTreeNode node, String? newParent, BuildContext context) {
    log("Moving node ${node.id}");
    MyTreeNode? oldParent = nodeService.getParent(node.id);
    if (newParent != null) {
      nodeService.moveNode(node, newParent, context);
      Navigator.of(context).pop();
      if (oldParent == null) {
        treeController.roots = HierarchyDatabase.roots;
      }
      treeController.rebuild();
      onChange();
    }
  }

  /// Creates a new node as a child of the specified parent node.
  ///
  /// - `context`: The current BuildContext for UI updates.
  /// - `node`: The parent node under which the new node will be created.
  /// - `isNote`: Indicates whether the new node should be a note or a directory.
  void createNode(BuildContext context, MyTreeNode node, bool isNote) {
    if (nodeService.createNewNode(node, _textDialogController.text.trim(), isNote, context)) {
      treeController.expand(node);
      treeController.rebuild();
      closeAndClear(context);
      onChange();
    }
    //log("${treeController.roots}");
  }

  /// Renames an existing node and updates the tree view accordingly.
  ///
  /// - `context`: The current BuildContext for UI interactions.
  /// - `node`: The node to be renamed.
  void renameNode(BuildContext context, MyTreeNode node) {
    if (nodeService.renameNode(node, _textDialogController.text.trim(), context)) {
      closeAndClear(context);
      treeController.rebuild();
      onChange();
    }
  }

  /// Unlocks a node that has been locked with a password.
  ///
  /// - `context`: The BuildContext for UI operations.
  /// - `node`: The node to be unlocked.
  void unlockNode(BuildContext context, MyTreeNode node) {
    if (nodeService.unlockNode(_textDialogController.text.trim(), node)) {
      closeAndClear(context);
      treeController.rebuild();
      onChange();
    }
  }

  /// Locks a node by setting a password, ensuring the entered passwords match.
  ///
  /// - `context`: The BuildContext for UI operations.
  /// - `node`: The node to be locked.
  void lockNode(BuildContext context, MyTreeNode node) {
    if (_textDialogController.text == _textDialogController2.text) {
      if (nodeService.lockNode(_textDialogController.text.trim(), node)) {
        closeAndClear(context);
        treeController.rebuild();
        onChange();
      }
    } else {
      ComponentUtils.showErrorToast(AppLocalizations.of(context)!.differentPasswords);
    }
  }

  /// Deletes a specified node from the tree structure and updates the tree view.
  ///
  /// This method removes a node and its children from the hierarchy database. It then updates
  /// the UI to reflect these changes. If the deleted node has no parent, it updates the root nodes directly.
  ///
  /// - `context`: The BuildContext used for UI operations.
  /// - `node`: The [MyTreeNode] instance to be deleted.
  void deleteNode(BuildContext context, MyTreeNode node) {
    log("deleting node ${node.title}");
    MyTreeNode? parent = nodeService.getParent(node.id);
    nodeService.deleteNode(node, parent);
    Navigator.of(context).pop();
    if (parent == null) {
      treeController.roots = HierarchyDatabase.roots;
    }
    for (var root in treeController.roots) {
      log("Root $root");
    }
    treeController.rebuild();
    //log("${treeController.roots.first}");
  }

  /// Closes any open dialogs and clears all text input controllers.
  ///
  /// This method is typically called to reset the state of dialog inputs and close dialogs
  /// upon cancellation of actions or after operations that require dialogs.
  ///
  /// - `context`: The BuildContext used to find and dismiss the current dialog.
  void closeAndClear(BuildContext context) {
    _textDialogController.clear();
    _textDialogController2.clear();
    Navigator.of(context).pop();
  }

  // Builds the UI of one node in treeView.
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        log(entry.node.title);
        navigate();
      },
      child: TreeIndentation(
        entry: entry,
        guide: const IndentGuide.connectingLines(indent: 10),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            TREE_VIEW_PADDING,
            TREE_VIEW_PADDING,
            TREE_VIEW_PADDING,
            TREE_VIEW_PADDING,
          ),
          child: Row(
            children: [
              FolderButton(
                isOpen: !entry.node.isNote ? entry.isExpanded : null,
                onPressed: !entry.node.isNote ? onTap : null,
              ),
              Expanded(child: Text(entry.node.title)),
              PopupMenuButton<String>(
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'delete',
                    onTap: () => showDeleteDialog(context, entry.node),
                    child: Row(
                      children: [
                        const Icon(Icons.delete),
                        const SizedBox(width: ROW_TEXT_GAP),
                        Text(AppLocalizations.of(context)!.menuDelete),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'rename',
                    onTap: () => showRenameDialog(context, entry.node),
                    child: Row(
                      children: [
                        const Icon(Icons.border_color_sharp),
                        const SizedBox(width: ROW_TEXT_GAP),
                        Text(AppLocalizations.of(context)!.menuRename),
                      ],
                    ),
                  ),
                  if (!entry.node.isNote)
                    PopupMenuItem<String>(
                      value: 'create_note',
                      onTap: () => showCreateDialog(context, entry.node, true),
                      child: Row(
                        children: [
                          const Icon(Icons.article),
                          const SizedBox(width: ROW_TEXT_GAP),
                          Text(AppLocalizations.of(context)!.createNote),
                        ],
                      ),
                    ),
                  if (!entry.node.isNote)
                    PopupMenuItem<String>(
                      value: 'create_file',
                      onTap: () => showCreateDialog(context, entry.node, false),
                      child: Row(
                        children: [
                          const Icon(Icons.create_new_folder),
                          const SizedBox(width: ROW_TEXT_GAP),
                          Text(AppLocalizations.of(context)!.createFile),
                        ],
                      ),
                    ),
                  PopupMenuItem<String>(
                    value: 'move',
                    onTap: () => showMoveDialog(context, entry.node),
                    child: Row(
                      children: [
                        const Icon(Icons.move_down),
                        const SizedBox(width: ROW_TEXT_GAP),
                        Text(AppLocalizations.of(context)!.menuMove),
                      ],
                    ),
                  ),
                  if (!entry.node.isLocked && entry.node.isNote)
                    PopupMenuItem<String>(
                      value: 'lock',
                      onTap: () => showLockDialog(context, entry.node),
                      child: Row(
                        children: [
                          const Icon(Icons.lock_outline),
                          const SizedBox(width: ROW_TEXT_GAP),
                          Text(AppLocalizations.of(context)!.lockButton)
                        ],
                      ),
                    ),
                  if (entry.node.isLocked && entry.node.isNote)
                    PopupMenuItem<String>(
                      value: 'unlock',
                      onTap: () => showUnlockDialog(context, entry.node),
                      child: Row(
                        children: [
                          const Icon(Icons.lock_open_rounded),
                          const SizedBox(width: ROW_TEXT_GAP),
                          Text(AppLocalizations.of(context)!.unlockMenu)
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
