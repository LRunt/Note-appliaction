import 'package:hive/hive.dart';

part 'myTreeNode.g.dart';

@HiveType(typeId: 1)
class MyTreeNode {
  /// Path of directory/note
  @HiveField(0)
  String id;

  /// Name of the directory/note
  @HiveField(1)
  String title;

  /// If the tree node is directory or note
  @HiveField(2)
  bool isNote;

  /// Childrens of the note or directory
  @HiveField(3)
  List<MyTreeNode> children;

  ///Constructor of the treenode
  MyTreeNode({
    required this.id,
    required this.title,
    required this.isNote,
    List<MyTreeNode>? children,
  }) : children = children ?? [];

  /// Add a child to the node
  void addChild(MyTreeNode child) {
    if (children.isEmpty) {
      children = [child];
    } else {
      children.add(child);
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isNote': isNote,
      'children': children.map((child) => child.toMap()).toList(),
    };
  }

  factory MyTreeNode.fromMap(Map<String, dynamic> map) {
    return MyTreeNode(
      id: map['id'],
      title: map['title'],
      isNote: map['isNote'],
      children: List<MyTreeNode>.from(
          map['children']?.map((childMap) => MyTreeNode.fromMap(childMap)) ??
              []),
    );
  }

  /// Text representation of the treeNode
  @override
  String toString() {
    return "Title: $title, Childrens: $children";
  }
}
