import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:notes/assets/constants.dart';
import 'package:notes/components/dialogs/dialogs.dart';
import 'package:notes/components/richTextEditor.dart';
import 'package:notes/data/local_databases.dart';
import 'package:notes/model/myTreeNode.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notes/services/services.dart';

class ConflictTree extends StatefulWidget {
  const ConflictTree({Key? key}) : super(key: key);

  @override
  State<ConflictTree> createState() => _ConflictTreeState();
}

class _ConflictTreeState extends State<ConflictTree> {
  /// Controller of the hierarchical tree.
  late final TreeController<MyTreeNode> treeController;

  HierarchyDatabase db = HierarchyDatabase();

  @override
  void initState() {
    if (db.conflictDataNotExist()) {
      db.initConflictData();
    }
    //there are saved data
    else {
      db.loadConflictData();
    }

    treeController = TreeController<MyTreeNode>(
      roots: HierarchyDatabase.conflictData,
      childrenProvider: (MyTreeNode node) => node.children,
    );
    super.initState();
  }

  @override
  void dispose() {
    treeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return treeController.roots.isEmpty
        ? Center(
            child: Text(AppLocalizations.of(context)!.noConflicts),
          )
        : TreeView<MyTreeNode>(
            shrinkWrap: true,
            treeController: treeController,
            nodeBuilder: (BuildContext context, TreeEntry<MyTreeNode> entry) {
              return ConflictTreeTile(
                key: ValueKey(entry.node),
                entry: entry,
                onTap: () => treeController.toggleExpansion(entry.node),
                treeController: treeController,
              );
            },
          );
  }
}

class ConflictTreeTile extends StatelessWidget {
  final TreeEntry<MyTreeNode> entry;
  final VoidCallback onTap;
  final TreeController treeController;
  final NodeService nodeService = NodeService();

  ConflictTreeTile({
    Key? key,
    required this.entry,
    required this.onTap,
    required this.treeController,
  }) : super(key: key);

  void showDeleteDialog(BuildContext context, MyTreeNode node) {
    showDialog(
        context: context,
        builder: (context) {
          return DeleteDialog(
            titleText: AppLocalizations.of(context)!.deleteNode(node.title),
            contentText: AppLocalizations.of(context)!.deleteContent(node.title),
            onDelete: () => deleteConflict(context, node),
            onCancel: () => Navigator.of(context).pop(),
          );
        });
  }

  void deleteConflict(BuildContext context, MyTreeNode node) {
    nodeService.deleteConflict(node);
    Navigator.of(context).pop();
    treeController.rebuild();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (entry.node.isNote) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(
                  title: FittedBox(child: Text(entry.node.title)),
                ),
                body: RichTextEditor(noteId: entry.node.id),
              ),
            ),
          );
        }
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
          child: GestureDetector(
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
                      onTap: () {
                        showDeleteDialog(context, entry.node);
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.delete),
                          const SizedBox(width: ROW_TEXT_GAP),
                          Text(AppLocalizations.of(context)!.menuDelete),
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
}
