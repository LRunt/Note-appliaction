import 'package:flutter/material.dart';
import 'package:notes/components/componentUtils.dart';
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
  State<FileListView> createState() => _FileListViewState();
}

class _FileListViewState extends State<FileListView> {
  List<MyTreeNode> chidren = [];
  final utils = ComponentUtils();
  NodeService service = NodeService();

  @override
  void initState() {
    MyTreeNode? node = service.getNode(widget.nodeId);
    log("$node");
    if (node != null) {
      chidren = node.children;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return chidren.isEmpty
        ? Text(
            "Složka je prázdná",
            style: utils.getBasicTextStyle(),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(7),
            itemCount: chidren.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(1),
                child: FileListViewTile(
                    isNote: chidren[index].isNote,
                    fileName: chidren[index].title),
              );
            });
  }
}
