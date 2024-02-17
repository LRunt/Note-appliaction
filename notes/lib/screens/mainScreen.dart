import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:notes/services/loginOrRegister.dart';

class MainScreen extends StatelessWidget {
  static const appTitle = 'Notes';

  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(appTitle),
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: [
            const DrawerHeader(
                decoration: BoxDecoration(color: Colors.blue),
                child: UserAccountsDrawerHeader(
                    accountName: Text('Lukas Runt'),
                    accountEmail: Text('lukas.runt@gmail.com'))),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginOrRegister()),
                );
              },
              child: const Text('Login'),
            ),
            const MyTreeView(),
          ],
        ),
      ),
      body: const Center(
        child: Text(
          'Here will be rich editor',
          style: TextStyle(
            color: Colors.grey, // Set the text color to light grey
            fontSize: 32.0,
          ),
          textAlign: TextAlign.center, // Center the text
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}

class MyNode {
  const MyNode({
    required this.title,
    this.children = const <MyNode>[],
  });

  final String title;
  final List<MyNode> children;
}

class MyTreeView extends StatefulWidget {
  const MyTreeView({super.key});

  @override
  State<MyTreeView> createState() => _MyTreeViewState();
}

class _MyTreeViewState extends State<MyTreeView> {
  static const List<MyNode> roots = <MyNode>[
    MyNode(
      title: 'Root 1',
      children: <MyNode>[
        MyNode(
          title: 'Node 1.1',
          children: <MyNode>[
            MyNode(title: 'Node 1.1.1'),
            MyNode(title: 'Node 1.1.2'),
          ],
        ),
        MyNode(title: 'Node 1.2'),
      ],
    ),
    MyNode(
      title: 'Root 2',
      children: <MyNode>[
        MyNode(
          title: 'Node 2.1',
          children: <MyNode>[
            MyNode(title: 'Node 2.1.1'),
          ],
        ),
        MyNode(title: 'Node 2.2')
      ],
    ),
  ];

  late final TreeController<MyNode> treeController;

  @override
  void initState() {
    super.initState();
    treeController = TreeController<MyNode>(
      roots: roots,
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
