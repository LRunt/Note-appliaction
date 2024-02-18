class MyNode {
  /// Path of directory/note
  String id;

  /// Name of the directory/note
  String title;

  /// If the tree node is directory or note
  bool isNote;

  /// Childrens of the note or directory
  List<MyNode> children;

  ///Constructor of the treenode
  MyNode({
    required this.id,
    required this.title,
    required this.isNote,
    List<MyNode>? children,
  }) : children = children ?? [];

  /// Add a child to the node
  void addChild(MyNode child) {
    if (children == null) {
      children = [child];
    } else {
      children.add(child);
    }
  }

  @override
  String toString() {
    return "Title: $title, Childrens: $children";
  }
}
