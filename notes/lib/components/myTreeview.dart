import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:notes/components/componentUtils.dart';
import 'package:notes/components/dialogs/deleteDialog.dart';
import 'package:notes/components/dialogs/dropdownMenuDialog.dart';
import 'package:notes/components/dialogs/textFieldDialog.dart';
import 'package:notes/data/hierarchyDatabase.dart';
import 'package:notes/model/myTreeNode.dart';
import 'package:notes/boxes.dart';
import 'package:notes/assets/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notes/services/nodeService.dart';

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
/// Usage:
/// ```dart
/// MyTreeView(navigateWithParam: (int param, String id) {
///   // Implementation for navigation
/// });
/// ```
class MyTreeView extends StatefulWidget {
  /// A callback function used for navigating with a specified parameter.
  /// The function takes an type of the page as integer and a noteId as string as parameters.
  final void Function(bool, String) navigateWithParam;

  final VoidCallback onChange;

  /// Constructor of the [MyTreeView] class.
  const MyTreeView({
    super.key,
    required this.navigateWithParam,
    required this.onChange,
  });

  @override
  State<MyTreeView> createState() => _MyTreeViewState();
}

class _MyTreeViewState extends State<MyTreeView> {
  /// Controller of the hierarchical tree.
  late final TreeController<MyTreeNode> treeController;

  /// The database instance for managing note data.
  HierarchyDatabase hierarchyDb = HierarchyDatabase();
  final _textDialogController = TextEditingController();
  NodeService nodeService = NodeService();

  @override
  void initState() {
    //there is no initial state, first time the application runs
    if (!boxSynchronization.containsKey(ROOT_LIST) || boxSynchronization.get(ROOT_LIST) == null) {
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

  @override
  void dispose() {
    // Remember to dispose your tree controller to release resources.
    treeController.dispose();
    super.dispose();
  }

  /// Showing dialog to create new dorectory or node
  void showCreateDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return TextFieldDialog(
              titleText: AppLocalizations.of(context)!.createFile,
              confirmButtonText: AppLocalizations.of(context)!.create,
              controller: _textDialogController,
              onConfirm: () {
                if (nodeService.createNewRoot(_textDialogController.text.trim(), context)) {
                  Navigator.of(context).pop();
                  treeController.rebuild();
                  _textDialogController.clear();
                }
              },
              onCancel: () {
                _textDialogController.clear();
                Navigator.of(context).pop();
              });
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
        ElevatedButton(
            onPressed: () {
              showCreateDialog(context);
            },
            child: Text(AppLocalizations.of(context)!.createFile)),
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

  final NodeService nodeService = NodeService();

  final utils = ComponentUtils();

  /// Constructor of the class [MyTreeTile].
  MyTreeTile(
      {super.key,
      required this.entry,
      required this.onTap,
      required this.navigate,
      required this.onChange,
      required this.treeController,
      required this.db});

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
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
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
                        const SizedBox(width: 4),
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
                        const SizedBox(width: 4),
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
                          const SizedBox(width: 4),
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
                          const SizedBox(width: 4),
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
                        const SizedBox(width: 4),
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
                          const SizedBox(width: 4),
                          Text(AppLocalizations.of(context)!.lock)
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
                          const SizedBox(width: 4),
                          Text(AppLocalizations.of(context)!.unlock)
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

  /*bool checkPassword() {

  }*/

  /// Showing dialog with asking the user if he is sure to delete the node
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

  /// Showing dialog to rename the node
  final _textDialogController = TextEditingController();
  void showRenameDialog(BuildContext context, MyTreeNode node) {
    showDialog(
        context: context,
        builder: (context) {
          return TextFieldDialog(
              titleText: AppLocalizations.of(context)!.renameNode(node.title),
              confirmButtonText: AppLocalizations.of(context)!.rename,
              controller: _textDialogController,
              onConfirm: () => renameNode(context, node),
              onCancel: () => closeAndClear(context));
        });
  }

  /// Showing dialog to create new dorectory or node
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
              onCancel: () => closeAndClear(context));
        });
  }

  void showLockDialog(BuildContext context, MyTreeNode node) {
    showDialog(
        context: context,
        builder: (context) {
          return TextFieldDialog(
              titleText: AppLocalizations.of(context)!.renameNode(node.title),
              confirmButtonText: AppLocalizations.of(context)!.rename,
              controller: _textDialogController,
              onConfirm: () => lockNode(context, node),
              onCancel: () => closeAndClear(context));
        });
  }

  void showUnlockDialog(BuildContext context, MyTreeNode node) {
    showDialog(
        context: context,
        builder: (context) {
          return TextFieldDialog(
              titleText: AppLocalizations.of(context)!.renameNode(node.title),
              confirmButtonText: AppLocalizations.of(context)!.rename,
              controller: _textDialogController,
              onConfirm: () => unlockNode(context, node),
              onCancel: () => closeAndClear(context));
        });
  }

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

  /// Creating new node as children of [node]
  void createNode(BuildContext context, MyTreeNode node, bool isNote) {
    if (nodeService.createNewNode(node, _textDialogController.text.trim(), isNote, context)) {
      treeController.expand(node);
      treeController.rebuild();
      closeAndClear(context);
      onChange();
    }
    //log("${treeController.roots}");
  }

  /// Renaming the [node]
  void renameNode(BuildContext context, MyTreeNode node) {
    if (nodeService.renameNode(node, _textDialogController.text.trim(), context)) {
      closeAndClear(context);
      treeController.rebuild();
      onChange();
    }
  }

  void unlockNode(BuildContext context, MyTreeNode node) {
    if (nodeService.unlockNode(_textDialogController.text.trim(), node)) {
      closeAndClear(context);
      treeController.rebuild();
      onChange();
    }
  }

  void lockNode(BuildContext context, MyTreeNode node) {
    if (nodeService.lockNode(_textDialogController.text.trim(), node)) {
      closeAndClear(context);
      treeController.rebuild();
      onChange();
    }
  }

  /// Deleting the node
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

  /// Closes dialogs and clears controllers
  void closeAndClear(BuildContext context) {
    _textDialogController.clear();
    Navigator.of(context).pop();
  }
}
