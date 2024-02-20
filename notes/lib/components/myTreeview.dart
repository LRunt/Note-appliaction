import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:notes/components/dialogs/deleteNodeDialog.dart';
import 'package:notes/components/dialogs/renameNodeDialog.dart';
import 'dart:developer';
import 'package:notes/data/notes_database.dart';
import 'package:notes/model/myTreeNode.dart';
import 'package:notes/boxes.dart';
import 'package:notes/assets/constants.dart';

class MyTreeView extends StatefulWidget {
  const MyTreeView({super.key});

  @override
  State<MyTreeView> createState() => _MyTreeViewState();
}

class _MyTreeViewState extends State<MyTreeView> {
  late final TreeController<MyTreeNode> treeController;

  NotesDatabase db = NotesDatabase();

  @override
  void initState() {
    //there is no initial state, first time the application runs
    if (!boxHierachy.containsKey(TREE_STORAGE) ||
        boxHierachy.get(TREE_STORAGE) == null) {
      log("Creating new data!");
      db.createDefaultData();
    }
    //there are saved data
    else {
      log("Loading data!");
      db.loadData();
    }

    treeController = TreeController<MyTreeNode>(
      roots: db.roots,
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
    return SingleChildScrollView(
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
                  treeController: treeController,
                  db: db);
            },
          ),
        ],
      ),
    );
  }
}

class MyTreeTile extends StatelessWidget {
  MyTreeTile(
      {super.key,
      required this.entry,
      required this.onTap,
      required this.treeController,
      required this.db});

  final TreeEntry<MyTreeNode> entry;
  final VoidCallback onTap;
  final TreeController treeController;
  final NotesDatabase db;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        log(entry.node.title);
        onTap();
      },
      child: TreeIndentation(
        entry: entry,
        guide: const IndentGuide.connectingLines(indent: 10),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 8, 8),
          child: GestureDetector(
            onLongPressStart: (LongPressStartDetails details) {
              _showPopupMenu(context, details.globalPosition);
            },
            child: Row(
              children: [
                FolderButton(
                  isOpen: entry.hasChildren ? entry.isExpanded : null,
                  onPressed: entry.hasChildren ? onTap : null,
                ),
                Text(entry.node.title),
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
          return DeleteNodeDialog(
            nodeName: node.title,
            onDelete: () => deleteNode(context, node),
            onCancel: () => closeAndClear(context),
          );
        });
  }

  final _textDialogController = TextEditingController();
  void showRenameDialog(BuildContext context, MyTreeNode node) {
    showDialog(
        context: context,
        builder: (context) {
          return RenameNodeDialog(
              nodeName: node.title,
              controller: _textDialogController,
              onRename: () => renameNode(context, node),
              onCancel: () => closeAndClear(context));
        });
  }

  void renameNode(BuildContext context, MyTreeNode node) {
    log("Renaming node");
    node.title = _textDialogController.text;
    closeAndClear(context);
    treeController.rebuild();
    db.updateDatabase();
  }

  /// Deleting the node
  void deleteNode(BuildContext context, MyTreeNode node) {
    log("deleting node");
    Navigator.of(context).pop();
    log("${entry.parent?.node}");
    MyTreeNode? parent = entry.parent?.node;
    if (parent == null) {
      log("root");
    } else {
      parent.children.remove(node);
    }
    treeController.rebuild();
    log("${treeController.roots.first}");
    db.updateDatabase();
  }

  /// Closes dialogs and clears controllers
  void closeAndClear(BuildContext context) {
    _textDialogController.clear();
    Navigator.of(context).pop();
  }

  void addChildren(MyTreeNode node) {
    log("Adding children");
    MyTreeNode newChild = MyTreeNode(
        id: node.id + '/Newchild', title: "New child", isNote: false);
    node.addChild(newChild);
    treeController.expand(node);
    treeController.rebuild();
    log("${treeController.roots}");
    db.updateDatabase();
  }

  void _showPopupMenu(BuildContext context, Offset tapPosition) async {
    final RenderBox overlay =
        Overlay.of(context)!.context.findRenderObject() as RenderBox;

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
          child: const Text('Delete'),
        ),
        PopupMenuItem(
          onTap: () => showRenameDialog(context, entry.node),
          value: 'rename',
          child: const Text('Rename'),
        ),
        PopupMenuItem(
          onTap: () => addChildren(entry.node),
          value: 'addChildren',
          child: const Text('add Children'),
        )
      ],
    );
  }
}
