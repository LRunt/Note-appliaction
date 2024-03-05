import 'package:notes/assets/constants.dart';
import 'package:notes/data/hierarchyDatabase.dart';
import 'package:notes/model/myTreeNode.dart';
import 'dart:developer';

class NodeService {
  HierarchyDatabase db = HierarchyDatabase();

  MyTreeNode? getNode(String nodeId) {
    List<String> path = nodeId.split(DELIMITER);
    log("$path");
    int level = 1;
    db.loadData();
    List<MyTreeNode> nodeList = db.roots;
    log("Starting serching, nodeList: $nodeList");
    return searchChildren(level, nodeList, path);
  }

  MyTreeNode? searchChildren(
      int level, List<MyTreeNode> nodeList, List<String> path) {
    log("Search children ${path.elementAt(level)}");
    for (MyTreeNode node in nodeList) {
      if (level == path.length - 1 && node.title == path[level]) {
        return node;
      }
      if (node.title == path[level]) {
        return searchChildren(level + 1, node.children, path);
      }
    }
    return null;
  }
}
