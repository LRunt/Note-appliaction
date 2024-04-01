import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:notes/assets/constants.dart';
import 'package:notes/boxes.dart';
import 'package:notes/data/hierarchyDatabase.dart';
import 'package:notes/model/myTreeNode.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ConflictTree extends StatefulWidget {
  const ConflictTree({Key? key}) : super(key: key);

  @override
  _ConflictTreeState createState() => _ConflictTreeState();
}

class _ConflictTreeState extends State<ConflictTree> {
  /// Controller of the hierarchical tree.
  late final TreeController<MyTreeNode> treeController;

  HierarchyDatabase db = HierarchyDatabase();

  @override
  void initState() {
    if (!boxHierachy.containsKey(CONFLICT) || boxHierachy.get(CONFLICT) == null) {
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
    return TreeView<MyTreeNode>(
      shrinkWrap: true,
      treeController: treeController,
      nodeBuilder: (BuildContext context, TreeEntry<MyTreeNode> entry) {
        return ConflictTreeTile(
          key: ValueKey(entry.node),
          entry: entry,
        );
      },
    );
  }
}

class ConflictTreeTile extends StatelessWidget {
  final TreeEntry<MyTreeNode> entry;

  const ConflictTreeTile({Key? key, required this.entry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: TreeIndentation(
        entry: entry,
        guide: const IndentGuide.connectingLines(indent: 10),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
          child: GestureDetector(
            child: Row(
              children: [
                FolderButton(
                  isOpen: !entry.node.isNote ? entry.isExpanded : null,
                ),
                Expanded(child: Text(entry.node.title)),
                PopupMenuButton<String>(
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'replace',
                      onTap: () {},
                      child: Row(
                        children: [
                          const Icon(Icons.border_color_sharp),
                          const SizedBox(width: 4),
                          Text(AppLocalizations.of(context)!.menuRename),
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
