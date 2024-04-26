import 'package:hive/hive.dart';

part 'my_tree_node.g.dart';

/// A [MyTreeNode] object represents a node within a tree structure,
/// which can be either a directory or a note. This class is designed
/// to be stored in a Hive database with a specific typeId which reperesents the path in the structure.
///
/// Each node contains an identifier, title, flag indicating whether it is a note,
/// and a list of children nodes, allowing for the construction of a hierarchical tree structure.
@HiveType(typeId: 1)
class MyTreeNode {
  /// The unique identifier for this tree node, representing the path of the directory or note.
  @HiveField(0)
  String id;

  /// Name of the directory or note.
  @HiveField(1)
  String title;

  /// A boolean flag indicates if this tree node is note (`true`) or directory (`false`).
  @HiveField(2)
  bool isNote;

  /// A list of [MyTreeNode] objects representing the children of this node.
  @HiveField(3)
  List<MyTreeNode> children;

  /// A boolean flag indicates if the node is locked with password or not
  @HiveField(4)
  bool isLocked;

  /// Password when the file is locked
  @HiveField(5)
  String? password;

  /// Constructs a [MyTreeNode] instance with the given [id], [title], [isNote] status,
  /// and an optional list of [children]. If [children] is not provided, it defaults to an empty list.
  MyTreeNode({
    required this.id,
    required this.title,
    required this.isNote,
    List<MyTreeNode>? children,
    required this.isLocked,
    this.password,
  }) : children = children ?? [];

  /// Adds a [child] node to this node's list of children.
  ///
  /// If the list of children is initially empty, it starts with the given [child].
  /// Otherwise, [child] is appended to the list of existing children.
  void addChild(MyTreeNode child) {
    if (children.isEmpty) {
      children = [child];
    } else {
      children.add(child);
    }
  }

  /// Converts this [MyTreeNode] instance into a map representation, including its
  /// [id], [title], [isNote] status, and recursively converts its [children] to their map representations.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isNote': isNote,
      'children': children.map((child) => child.toMap()).toList(),
      'isLocked': isLocked,
      'password': password,
    };
  }

  /// Factory constructor that creates a [MyTreeNode] instance from a map representation.
  ///
  /// This constructor is used for deserialization, allowing for the reconstruction
  /// of a [MyTreeNode] instance from its map representation, including its children.
  factory MyTreeNode.fromMap(Map<String, dynamic> map) {
    return MyTreeNode(
      id: map['id'],
      title: map['title'],
      isNote: map['isNote'],
      children: List<MyTreeNode>.from(
          map['children']?.map((childMap) => MyTreeNode.fromMap(childMap)) ?? []),
      isLocked: map['isLocked'],
      password: map['password'], // Consider decrypting this value
    );
  }

  /// Returns a string representation of this node, including its title and id of the node.
  @override
  String toString() {
    return "Id: $id, Title: $title";
  }
}
