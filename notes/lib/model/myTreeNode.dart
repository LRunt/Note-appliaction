class MyNode {
  final String title;
  final List<MyNode> children;

  const MyNode({
    required this.title,
    this.children = const <MyNode>[],
  });

  factory MyNode.fromJson(Map<String, dynamic> json) {
    return MyNode(
      title: json['title'],
      children: (json['children'] as List<dynamic>?)
              ?.map((child) => MyNode.fromJson(child))
              .toList() ??
          [],
    );
  }
}
