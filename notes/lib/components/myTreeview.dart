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
    // Replace this with your actual JSON data
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
          // Your other widgets can go here
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
        print(entry.node.title);
        onTap();
      },
      child: TreeIndentation(
        entry: entry,
        guide: const IndentGuide.connectingLines(indent: 10),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 8, 8),
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
    );
  }
}
