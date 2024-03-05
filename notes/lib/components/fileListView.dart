import 'package:flutter/material.dart';
import 'package:notes/components/fileListViewTile.dart';
import 'package:notes/model/myTreeNode.dart';
import 'package:notes/services/nodeService.dart';
import 'dart:developer';

class FileListView extends StatefulWidget {
  final String nodeId;

  const FileListView({
    super.key,
    required this.nodeId,
  });

  @override
  _FileListViewState createState() => _FileListViewState();
}

class _FileListViewState extends State<FileListView> {
  List<MyTreeNode> chidrens = [];

  NodeService service = NodeService();

  @override
  void initState() {
    MyTreeNode? node = service.getNode(widget.nodeId);
    log("$node");
    if (node != null) {
      chidrens = node.children;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: chidrens.length,
        itemBuilder: (context, index) {
          return FileListViewTile(
              isNote: chidrens[index].isNote, fileName: chidrens[index].title);
        });
  }
}
