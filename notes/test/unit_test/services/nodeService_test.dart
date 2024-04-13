import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:notes/data/local_databases.dart';
import 'package:notes/model/myTreeNode.dart';
import 'package:notes/services/services.dart';

class MockHierarchyDatabase extends Mock implements HierarchyDatabase {}

void main() {
  MockHierarchyDatabase mockDb = MockHierarchyDatabase();
  NodeService nodeService = NodeService(hierarchyDb: mockDb);

  group('nodeServoce tests', () {
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
        expect(nodeService.changeNameInId(nodeId, newFileName), "|home|slozka1|slozka2|newName");
      });
    });

    group('Changing path in id', () {
      test('Change path in id - simple test', () {
        String path = "|home|slozka1|slozka2|poznamka";
        String newPath = "|home|slozka1|newName";
        expect(nodeService.changePathInId(path, newPath), "|home|slozka1|newName|poznamka");
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
        MyTreeNode root = MyTreeNode(
          id: '|Home',
          title: "Home",
          isNote: false,
          isLocked: false,
        );
        MyTreeNode child1 = MyTreeNode(
          id: '|Home|file1',
          title: "file1",
          isNote: false,
          isLocked: false,
        );
        MyTreeNode child2 = MyTreeNode(
          id: '|Home|child2',
          title: "child2",
          isNote: true,
          isLocked: false,
        );
        MyTreeNode child3 = MyTreeNode(
          id: '|Home|file2',
          title: "file2",
          isNote: false,
          isLocked: false,
        );
        root.addChild(child1);
        root.addChild(child2);
        root.addChild(child3);
        HierarchyDatabase.roots = [root];
      });

      test('Getting folders - simple test', () {
        MyTreeNode root = MyTreeNode(
          id: '|Home',
          title: "Home",
          isNote: false,
          isLocked: false,
        );
        MyTreeNode child1 = MyTreeNode(
          id: '|Home|child1',
          title: "child1",
          isNote: false,
          isLocked: false,
        );
        MyTreeNode child2 = MyTreeNode(
          id: '|Home|child2',
          title: "child2",
          isNote: true,
          isLocked: false,
        );
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
        MyTreeNode root = MyTreeNode(
          id: '|Home',
          title: "Home",
          isNote: false,
          isLocked: false,
        );
        MyTreeNode child1 = MyTreeNode(
          id: '|Home|file1',
          title: "file1",
          isNote: false,
          isLocked: false,
        );
        MyTreeNode child2 = MyTreeNode(
          id: '|Home|child2',
          title: "child2",
          isNote: true,
          isLocked: false,
        );
        MyTreeNode child3 = MyTreeNode(
          id: '|Home|file2',
          title: "file2",
          isNote: false,
          isLocked: false,
        );
        root.addChild(child1);
        root.addChild(child2);
        root.addChild(child3);
        List<String> folders = nodeService.getFoldersToMove(child1);
        expect(folders.length, 1);
        expect(folders[0], child3.id);
      });
    });

    group('Testing if file is root', () {
      test('Is root - simple text', () {
        MyTreeNode root = MyTreeNode(
          id: '|Home',
          title: "Home",
          isNote: false,
          isLocked: false,
        );
        MyTreeNode child1 = MyTreeNode(
          id: '|Home|child1',
          title: "child1",
          isNote: false,
          isLocked: false,
        );
        MyTreeNode child2 =
            MyTreeNode(id: '|Home|child2', title: "child2", isNote: true, isLocked: false);
        root.addChild(child1);
        root.addChild(child2);
        HierarchyDatabase.rootList.add(root.id);
        expect(nodeService.isRoot(root.id), true);
        expect(nodeService.isRoot(child1.id), false);
        expect(nodeService.isRoot(child2.id), false);
      });
    });

    group('generateHash', () {
      test('should generate a valid hash for the password', () {
        // Test data
        String password = 'password123';

        // Expected result
        String expectedHash = sha256.convert(utf8.encode(password)).toString();

        // Test
        String result = nodeService.generateHash(password);
        expect(result, equals(expectedHash));
      });
    });

    group('comparePassword', () {
      test('should return true if the input password matches the stored hash', () {
        // Test data
        String password = 'password123';
        String hash = nodeService.generateHash(password);

        // Test
        bool result = nodeService.comparePassword(password, hash);
        expect(result, isTrue);
      });

      test('should return false if the input password does not match the stored hash', () {
        // Test data
        String password = 'password123';
        String storedHash = nodeService.generateHash('differentPassword');

        // Test
        bool result = nodeService.comparePassword(password, storedHash);
        expect(result, isFalse);
      });
    });
  });
}
