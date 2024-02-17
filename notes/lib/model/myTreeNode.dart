class MyNode {
  String title;
  List<MyNode> children;

  MyNode({
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
