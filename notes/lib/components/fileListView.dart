import 'package:flutter/material.dart';
import 'package:notes/components/componentUtils.dart';
import 'package:notes/components/fileListViewTile.dart';
import 'package:notes/model/myTreeNode.dart';
import 'package:notes/services/nodeService.dart';
import 'dart:developer';

class FileListView extends StatefulWidget {
  final String nodeId;

  final void Function(bool, String) navigateWithParam;

  const FileListView({
    super.key,
    required this.nodeId,
    required this.navigateWithParam,
  });

  @override
  State<FileListView> createState() => _FileListViewState();
}

class _FileListViewState extends State<FileListView> {
  List<MyTreeNode> children = [];
  final utils = ComponentUtils();
  NodeService service = NodeService();

  @override
  void initState() {
    MyTreeNode? node = service.getNode(widget.nodeId);
    log("$node");
    if (node != null) {
      children = node.children;
    }
    super.initState();
  }

  void deleteNode(MyTreeNode node) {
    setState(() {
      service.deleteNode(node, service.getParent(node.id)!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return children.isEmpty
        ? Text(
            "Složka je prázdná",
            style: utils.getBasicTextStyle(),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(7),
            itemCount: children.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(1),
                child: FileListViewTile(
                    node: children[index],
                    touch: () => widget.navigateWithParam(
                          children[index].isNote,
                          children[index].id,
                        ),
                    delete: () => deleteNode(children[index])),
              );
            });
  }
}
