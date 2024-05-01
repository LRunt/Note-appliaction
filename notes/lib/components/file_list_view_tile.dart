part of components;

/// A custom list tile widget used in a file management system to represent and interact with file or directory nodes.
///
/// This widget encapsulates functionalities like touch (open), delete, rename, create note, create file,
/// move, lock, and unlock. It uses `MyTreeNode` to represent the data structure of each node, handling
/// files or directories and providing specific actions based on the node type.
///
/// ## Attributes:
/// - `node`: The data node (`MyTreeNode`) associated with this tile. Can be `null` to represent moving to a parent node.
/// - `touch`: Callback for when the tile is tapped (e.g., to open or select the node).
/// - `delete`: Callback for deleting the node.
/// - `rename`: Callback for renaming the node.
/// - `createNote`: Callback for creating a new note under the current directory node.
/// - `createFile`: Callback for creating a new file or directory under the current directory node.
/// - `move`: Callback for moving the node to another location.
/// - `lock`: Callback for locking the node, if it supports locking (applicable to notes).
/// - `unlock`: Callback for unlocking the node, if it is currently locked.
///
/// ## Usage Example:
/// ```dart
/// FileListViewTile(
///   node: someNode,
///   touch: () => navigateToNode(someNode),
///   delete: () => deleteNode(someNode),
///   rename: () => renameNode(someNode),
///   createNote: () => createNoteUnderNode(someNode),
///   createFile: () => createFileUnderNode(someNode),
///   move: () => moveNode(someNode),
///   lock: () => lockNode(someNode),
///   unlock: () => unlockNode(someNode),
/// )
/// ```
class FileListViewTile extends StatelessWidget {
  /// The tree node representing a file, directory, or note, or `null` for a parent directory action.
  final MyTreeNode? node;

  /// Callback executed when the tile is tapped, typically to open or view the node.
  final VoidCallback touch;

  /// Callback for deleting the node, involving confirmation and execution of deletion.
  final VoidCallback delete;

  /// Callback for renaming the node, typically invoking a dialog for user input.
  final VoidCallback rename;

  /// Callback for creating a new note under the current node if it's a directory.
  final VoidCallback createNote;

  /// Callback for creating a new file or directory under the current node.
  final VoidCallback createFile;

  /// Callback for moving the node to another location within the tree structure.
  final VoidCallback move;

  /// Callback for locking the node, applicable if the node supports locking mechanisms.
  final VoidCallback lock;

  /// Callback for unlocking the node, applicable if the node is currently locked.
  final VoidCallback unlock;

  /// Constructor of the [FileListViewFile].
  ///
  /// Requires nine positional arguments:
  /// - `node` a data node (`MyTreeNode`) associated with this tile. Can be `null` to represent moving to a parent node.
  /// - `touch`a callback for when the tile is tapped (e.g., to open or select the node).
  /// - `delete` a callback for deleting the node.
  /// - `rename` a callback for renaming the node.
  /// - `createNote` a callback for creating a new note under the current directory node.
  /// - `createFile` a callback for creating a new file or directory under the current directory node.
  /// - `move` a callback for moving the node to another location.
  /// - `lock` a callback for locking the node, if it supports locking (applicable to notes).
  /// - `unlock` a callback for unlocking the node, if it is currently locked.
  const FileListViewTile({
    super.key,
    required this.node,
    required this.touch,
    required this.delete,
    required this.rename,
    required this.createNote,
    required this.createFile,
    required this.move,
    required this.lock,
    required this.unlock,
  });

  // Builds the UI of the tile of the fileListView.
  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: Key('mainInkWell_${node?.id}'),
      onTap: () => touch(),
      child: Ink(
        padding: const EdgeInsets.all(DEFAULT_PADDING),
        decoration: BoxDecoration(
          color: Theme.of(context).dialogBackgroundColor,
          borderRadius: BorderRadius.circular(BORDER_RADIUS),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: node != null
            ? Row(
                children: [
                  Icon(node!.isNote ? Icons.article : Icons.folder),
                  const SizedBox(width: MENU_SIZE_BOX),
                  Expanded(
                    child: Text(
                      node!.title,
                      style: DEFAULT_TEXT_STYLE,
                    ),
                  ),
                  PopupMenuButton<String>(
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        onTap: () => delete(),
                        value: 'delete',
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
                        onTap: () => rename(),
                        child: Row(
                          children: [
                            const Icon(Icons.border_color_sharp),
                            const SizedBox(width: ROW_TEXT_GAP),
                            Text(AppLocalizations.of(context)!.menuRename),
                          ],
                        ),
                      ),
                      if (!node!.isNote)
                        PopupMenuItem<String>(
                          value: 'create_node',
                          onTap: () => createNote(),
                          child: Row(
                            children: [
                              const Icon(Icons.article),
                              const SizedBox(width: ROW_TEXT_GAP),
                              Text(AppLocalizations.of(context)!.createNote),
                            ],
                          ),
                        ),
                      if (!node!.isNote)
                        PopupMenuItem<String>(
                          value: 'create_file',
                          onTap: () => createFile(),
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
                        onTap: () => move(),
                        child: Row(
                          children: [
                            const Icon(Icons.move_down),
                            const SizedBox(width: ROW_TEXT_GAP),
                            Text(AppLocalizations.of(context)!.menuMove),
                          ],
                        ),
                      ),
                      if (node!.isNote && !node!.isLocked)
                        PopupMenuItem<String>(
                          value: 'lock',
                          onTap: () => lock(),
                          child: Row(
                            children: [
                              const Icon(Icons.lock_outline),
                              const SizedBox(width: ROW_TEXT_GAP),
                              Text(AppLocalizations.of(context)!.lockButton),
                            ],
                          ),
                        ),
                      if (node!.isNote && node!.isLocked)
                        PopupMenuItem<String>(
                          value: 'unlock',
                          onTap: () => unlock(),
                          child: Row(
                            children: [
                              const Icon(Icons.lock_open_rounded),
                              const SizedBox(width: ROW_TEXT_GAP),
                              Text(AppLocalizations.of(context)!.unlockMenu),
                            ],
                          ),
                        )
                    ],
                  ),
                ],
              )
            : Row(
                children: [
                  const Icon(Icons.drive_folder_upload_rounded),
                  const SizedBox(width: MENU_SIZE_BOX),
                  Text(AppLocalizations.of(context)!.toParentNode),
                ],
              ),
      ),
    );
  }
}
