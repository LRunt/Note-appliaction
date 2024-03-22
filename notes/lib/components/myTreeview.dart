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

  /// Constructor of the [MyTreeView] class.
  const MyTreeView({
    super.key,
    required this.navigateWithParam,
  });

  @override
  State<MyTreeView> createState() => _MyTreeViewState();
}

class _MyTreeViewState extends State<MyTreeView> {
  /// Controller of the hierarchical tree.
  late final TreeController<MyTreeNode> treeController;

  /// The database instance for managing note data.
  HierarchyDatabase db = HierarchyDatabase();

  @override
  void initState() {
    //there is no initial state, first time the application runs
    if (!boxHierachy.containsKey(TREE_STORAGE) || boxHierachy.get(TREE_STORAGE) == null) {
      log("Creating new data!");
      db.createDefaultData();
    }
    //there are saved data
    else {
      log("Loading data!");
      db.loadData();
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

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: SingleChildScrollView(
        child: Column(
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
                    treeController: treeController,
                    db: db);
              },
            ),
          ],
        ),
      ),
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
          child: GestureDetector(
            onLongPressStart: (LongPressStartDetails details) {
              _showPopupMenu(context, details.globalPosition);
            },
            child: Row(
              children: [
                FolderButton(
                  isOpen: !entry.node.isNote ? entry.isExpanded : null,
                  onPressed: !entry.node.isNote ? onTap : null,
                ),
                Expanded(child: Text(entry.node.title)),
                PopupMenuButton<String>(
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    if (!nodeService.isRoot(entry.node.id))
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
                    if (!nodeService.isRoot(entry.node.id))
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
                    if (!nodeService.isRoot(entry.node.id))
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
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
              titleText: AppLocalizations.of(context)!.newNode,
              confirmButtonText: AppLocalizations.of(context)!.create,
              controller: _textDialogController,
              onConfirm: () => createNode(context, node, isNote),
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
    if (newParent != null) {
      nodeService.moveNode(node, newParent);
      Navigator.of(context).pop();
      treeController.rebuild();
    }
  }

  /// Creating new node as children of [node]
  void createNode(BuildContext context, MyTreeNode node, bool isNote) {
    if (nodeService.createNewNode(node, _textDialogController.text.trim(), isNote)) {
      treeController.expand(node);
      treeController.rebuild();
      closeAndClear(context);
    }
    //log("${treeController.roots}");
  }

  /// Renaming the [node]
  void renameNode(BuildContext context, MyTreeNode node) {
    if (nodeService.renameNode(node, _textDialogController.text.trim())) {
      closeAndClear(context);
      treeController.rebuild();
    }
  }

  /// Deleting the node
  void deleteNode(BuildContext context, MyTreeNode node) {
    log("deleting node ${node.title}");
    nodeService.deleteNode(node, entry.parent!.node);
    Navigator.of(context).pop();
    treeController.rebuild();
    //log("${treeController.roots.first}");
  }

  /// Closes dialogs and clears controllers
  void closeAndClear(BuildContext context) {
    _textDialogController.clear();
    Navigator.of(context).pop();
  }

  ///Showing the menu with items rename, delete and create
  void _showPopupMenu(BuildContext context, Offset tapPosition) async {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    //showing the menu
    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        tapPosition & const Size(1.0, 1.0),
        Offset.zero & overlay.size,
      ),
      items: <PopupMenuEntry>[
        PopupMenuItem(
          onTap: () => showDeleteDialog(context, entry.node),
          value: 'delete',
          child: Text(AppLocalizations.of(context)!.menuDelete),
        ),
        PopupMenuItem(
          onTap: () => showRenameDialog(context, entry.node),
          value: 'rename',
          child: Text(AppLocalizations.of(context)!.menuRename),
        ),
        PopupMenuItem(
          onTap: () => showCreateDialog(context, entry.node, true),
          value: 'create',
          child: Text(AppLocalizations.of(context)!.createNote),
        ),
        PopupMenuItem(
          onTap: () => showCreateDialog(context, entry.node, false),
          value: 'create_directory',
          child: Text(AppLocalizations.of(context)!.createFile),
        ),
        PopupMenuItem(
          onTap: () => showCreateDialog(context, entry.node, false),
          value: 'move',
          child: const Text("Move"),
        ),
      ],
    );
  }
}
