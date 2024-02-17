import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:notes/model/myTreeNode.dart';
import 'dart:convert';

class MyTreeView extends StatefulWidget {
  const MyTreeView({super.key});

  @override
  State<MyTreeView> createState() => _MyTreeViewState();
}

class _MyTreeViewState extends State<MyTreeView> {
  late final TreeController<MyNode> treeController;

  List<MyNode> _parseJsonTree(dynamic json) {
    List<MyNode> nodes = [];

    for (var rootNode in json) {
      MyNode node = MyNode.fromJson(rootNode);
      nodes.add(node);
    }

    return nodes;
  }

  @override
  void initState() {
    super.initState();
    String jsonData = '''
      {
        "roots": [
          {
            "title": "Root 1",
            "children": [
              {
                "title": "Node 1.1",
                "children": [
                  {"title": "Node 1.1.1"},
                  {"title": "Node 1.1.2"}
                ]
              },
              {"title": "Node 1.2"}
            ]
          },
          {
            "title": "Root 2",
            "children": [
              {
                "title": "Node 2.1",
                "children": [
                  {"title": "Node 2.1.1"}
                ]
              },
              {"title": "Node 2.2"}
            ]
          },
          {"title": "Nova slozka"}
        ]
      }
    ''';

    dynamic json = jsonDecode(jsonData);

    treeController = TreeController<MyNode>(
      roots: _parseJsonTree(json['roots']),
      childrenProvider: (MyNode node) => node.children,
    );
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
          TreeView<MyNode>(
            shrinkWrap: true,
            treeController: treeController,
            nodeBuilder: (BuildContext context, TreeEntry<MyNode> entry) {
              return MyTreeTile(
                key: ValueKey(entry.node),
                entry: entry,
                onTap: () => treeController.toggleExpansion(entry.node),
              );
            },
          ),
        ],
      ),
    );
  }
}

class MyTreeTile extends StatelessWidget {
  const MyTreeTile({
    super.key,
    required this.entry,
    required this.onTap,
  });

  final TreeEntry<MyNode> entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        //entry.node.title = "Hehe";
        print(entry.node.title);
        onTap();
      },
      child: TreeIndentation(
        entry: entry,
        guide: const IndentGuide.connectingLines(indent: 10),
        child: GestureDetector(
          onLongPressStart: (LongPressStartDetails details) {
            _showPopupMenu(context, details.globalPosition);
          },
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
      ),
    );
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
        const PopupMenuItem(
          value: 'delete',
          child: Text('Delete'),
        ),
        const PopupMenuItem(
          value: 'rename',
          child: Text('Rename'),
        ),
        const PopupMenuItem(
          value: 'addChildren',
          child: Text('add Children'),
        ),
        const PopupMenuItem(
          value: 'addSibling',
          child: Text('add Sibling'),
        )
        // Add more menu items as needed
      ],
    ).then((value) {
      if (value != null) {
        print('Selected: $value');
      }
    });
  }
}
