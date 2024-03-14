import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:notes/data/hierarchyDatabase.dart';
import 'package:notes/model/myTreeNode.dart';
import 'package:notes/services/nodeService.dart';

class MockHierarchyDatabase extends Mock implements HierarchyDatabase {}

void main() {
  MockHierarchyDatabase mockDb = MockHierarchyDatabase();
  NodeService nodeService = NodeService(hierarchyDb: mockDb);

  group('Cointains disallowed chars', () {
    test('Without disallowed chars', () {
      String name = "NameOfTheNote";
      expect(nodeService.containsDisabledChars(name), false);
    });

    test('With disallowed chars', () {
      String name = "Home/name";
      expect(nodeService.containsDisabledChars(name), true);
    });
  });

  group('Changing file name id', () {
    test('Change file name in the path - simple test', () {
      String newFileName = 'newName';
      String nodeId = "|home|slozka1|slozka2|oldName";
      expect(nodeService.changeNameInId(nodeId, newFileName),
          "|home|slozka1|slozka2|newName");
    });
  });

  group('Changing path in id', () {
    test('Change path in id - simple test', () {
      String path = "|home|slozka1|slozka2|poznamka";
      String newPath = "|home|slozka1|newName";
      expect(nodeService.changePathInId(path, newPath),
          "|home|slozka1|newName|poznamka");
    });
  });

  group('Getting parent path', () {
    test('Get parent path - simple test', () {
      String path = "|home|slozka1|slozka2|parent|child";
      expect(nodeService.getParentPath(path), "|home|slozka1|slozka2|parent");
    });
  });

  group('Getting folders', () {
    setUp(() {
      MyTreeNode root = MyTreeNode(id: '|Home', title: "Home", isNote: false);
      MyTreeNode child1 =
          MyTreeNode(id: '|Home|file1', title: "file1", isNote: false);
      MyTreeNode child2 =
          MyTreeNode(id: '|Home|child2', title: "child2", isNote: true);
      MyTreeNode child3 =
          MyTreeNode(id: '|Home|file2', title: "file2", isNote: false);
      root.addChild(child1);
      root.addChild(child2);
      root.addChild(child3);
      HierarchyDatabase.roots = [root];
    });

    test('Getting folders - simple test', () {
      MyTreeNode root = MyTreeNode(id: '|Home', title: "Home", isNote: false);
      MyTreeNode child1 =
          MyTreeNode(id: '|Home|child1', title: "child1", isNote: false);
      MyTreeNode child2 =
          MyTreeNode(id: '|Home|child2', title: "child2", isNote: true);
      root.addChild(child1);
      root.addChild(child2);
      List<String> folders = [];
      nodeService.getFolders(folders, root);
      expect(folders.length, 2);
      expect(folders[0], root.id);
    });

    test('Getting all folders - simple test', () {
      List<String> folders = nodeService.getAllFolders();
      expect(folders.length, 3);
      expect(folders[0], "|Home");
    });

    test('Getting folders without actual position and node - simple test', () {
      MyTreeNode root = MyTreeNode(id: '|Home', title: "Home", isNote: false);
      MyTreeNode child1 =
          MyTreeNode(id: '|Home|file1', title: "file1", isNote: false);
      MyTreeNode child2 =
          MyTreeNode(id: '|Home|child2', title: "child2", isNote: true);
      MyTreeNode child3 =
          MyTreeNode(id: '|Home|file2', title: "file2", isNote: false);
      root.addChild(child1);
      root.addChild(child2);
      root.addChild(child3);
      List<String> folders = nodeService.getFoldersToMove(child1);
      expect(folders.length, 1);
      expect(folders[0], child3.id);
    });
  });

  group('Testing if file is root', () {
    setUp(() {
      MyTreeNode root = MyTreeNode(id: '|Home', title: "Home", isNote: false);
      HierarchyDatabase.roots = [root];
    });

    test('Is root - simple text', () {
      MyTreeNode root = MyTreeNode(id: '|Home', title: "Home", isNote: false);
      MyTreeNode child1 =
          MyTreeNode(id: '|Home|child1', title: "child1", isNote: false);
      MyTreeNode child2 =
          MyTreeNode(id: '|Home|child2', title: "child2", isNote: true);
      root.addChild(child1);
      root.addChild(child2);
      expect(nodeService.isRoot(root.id), true);
      expect(nodeService.isRoot(child1.id), false);
      expect(nodeService.isRoot(child2.id), false);
    });
  });
}
