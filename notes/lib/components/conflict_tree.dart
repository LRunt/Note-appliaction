part of components;

/// A StatefulWidget that manages and displays a tree view of conflicts.
///
/// This widget is responsible for presenting hierarchical conflict data, typically retrieved
/// from a `HierarchyDatabase`. It dynamically creates and manages a tree structure through
/// the use of a `TreeController`, allowing users to interact with and visualize different levels
/// of conflict details.
///
/// Parameters:
/// - [key]: The widget key, used to control how one widget replaces another widget in the tree.
///
/// Usage Example:
/// ```dart
/// ConflictTree()
/// ```
class ConflictTree extends StatefulWidget {
  /// Constructor of the [ConflictTree]
  ///
  /// - [key] a key associated with this widget.
  const ConflictTree({super.key});

  @override
  State<ConflictTree> createState() => _ConflictTreeState();
}

class _ConflictTreeState extends State<ConflictTree> {
  /// Manages the state and interaction of the tree nodes.
  late final TreeController<MyTreeNode> treeController;

  /// Database for accessing and manipulating conflict data.
  HierarchyDatabase db = HierarchyDatabase();

  //Initializing the widget
  @override
  void initState() {
    super.initState();
    initializeData();
  }

  /// Initializes conflict data and sets up the tree controller for node management.
  void initializeData() {
    if (db.conflictDataNotExist()) {
      db.initConflictData();
    } else {
      db.loadConflictData();
    }
    treeController = TreeController<MyTreeNode>(
      roots: HierarchyDatabase.conflictData,
      childrenProvider: (MyTreeNode node) => node.children,
    );
  }

  // Disposing the widget
  @override
  void dispose() {
    treeController.dispose();
    super.dispose();
  }

  // Builds the UI of the conflict tree.
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

/// A StatelessWidget that represents a single node within a `ConflictTree`.
///
/// This widget handles user interactions and displays contextual actions
/// for each node, such as deleting or expanding a node.
///
/// Parameters:
/// - [key]: The widget key.
/// - [entry]: Provides the details about the tree node.
/// - [onTap]: Callback for when the node is interacted with.
/// - [treeController]: Controller to manage tree state.
///
/// Usage Example:
/// ```dart
/// ConflictTreeTile(
///   entry: entryNode,
///   onTap: () {},
///   treeController: treeController,
/// )
/// ```
class ConflictTreeTile extends StatelessWidget {
  /// The details about the tree node.
  final TreeEntry<MyTreeNode> entry;

  /// Callback for when the node is interacted with.
  final VoidCallback onTap;

  /// Controller to manage tree state and interactions with tree.
  final TreeController treeController;

  /// Instance of [NodeService] used for performing node-specific operations.
  final NodeService nodeService = NodeService();

  /// Constructor of the [ConflictTreeTile]
  ///
  /// - [key] a key associated with this widget.
  /// - [entry] is a data and state of the node this tile represents.
  /// - [onTap] is function to call when the tile is tapped.
  /// - [treeController] is controller for managing tree updates.
  ConflictTreeTile({
    Key? key,
    required this.entry,
    required this.onTap,
    required this.treeController,
  }) : super(key: key);

  /// Displays a deletion confirmation dialog for the node.
  ///
  /// - [context]: The build context from which this method is invoked.
  /// - [node]: The node to potentially delete.
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

  /// Deletes the specified node and refreshes the tree view.
  ///
  /// - [context]: The build context from which this method is invoked.
  /// - [node]: The node to delete.
  void deleteConflict(BuildContext context, MyTreeNode node) {
    nodeService.deleteConflict(node);
    Navigator.of(context).pop();
    treeController.rebuild();
  }

  // Builds the UI of the conflict tree tile.
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
