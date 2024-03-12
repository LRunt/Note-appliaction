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

  group('Getting all forders', () {
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
  });
}
