import 'package:flutter_test/flutter_test.dart';
import 'package:notes/model/myTreeNode.dart';

void main() {
  group('MyTreeNode - toMap Tests', () {
    test('ToMap test - without children', () {
      final node = MyTreeNode(id: 'node1', title: 'Node 1', isNote: true, isLocked: false);

      final expectedMap = {
        'id': 'node1',
        'title': 'Node 1',
        'isNote': true,
        'isLocked': false,
        'children': [],
        'password': null,
      };

      expect(node.toMap(), equals(expectedMap));
    });

    test('ToMap test - one child', () {
      final childNode = MyTreeNode(id: 'child1', title: 'Child 1', isNote: false, isLocked: false);

      final parentNode = MyTreeNode(
        id: 'node1',
        title: 'Node 1',
        isNote: true,
        isLocked: false,
        children: [childNode],
      );

      final expectedMap = {
        'id': 'node1',
        'title': 'Node 1',
        'isNote': true,
        'isLocked': false,
        'password': null,
        'children': [
          {
            'id': 'child1',
            'title': 'Child 1',
            'isNote': false,
            'children': [],
            'isLocked': false,
            'password': null,
          },
        ],
      };

      expect(parentNode.toMap(), equals(expectedMap));
    });

    test('ToMap test - multiple children', () {
      final childNode1 = MyTreeNode(
        id: 'child1',
        title: 'Child 1',
        isNote: false,
        isLocked: false,
      );

      final childNode2 = MyTreeNode(
        id: 'child2',
        title: 'Child 2',
        isNote: true,
        isLocked: false,
      );

      final parentNode = MyTreeNode(
        id: 'node1',
        title: 'Node 1',
        isNote: true,
        children: [childNode1, childNode2],
        isLocked: false,
      );

      final expectedMap = {
        'id': 'node1',
        'title': 'Node 1',
        'isNote': true,
        'isLocked': false,
        'password': null,
        'children': [
          {
            'id': 'child1',
            'title': 'Child 1',
            'isNote': false,
            'isLocked': false,
            'children': [],
            'password': null,
          },
          {
            'id': 'child2',
            'title': 'Child 2',
            'isNote': true,
            'isLocked': false,
            'children': [],
            'password': null,
          },
        ],
      };

      expect(parentNode.toMap(), equals(expectedMap));
    });
  });

  group('MyTreeNode - fromMap Tests', () {
    test('fromMap test - without children', () {
      final map = {
        'id': 'node1',
        'title': 'Node 1',
        'isNote': true,
        'isLocked': false,
        'children': [],
      };

      final node = MyTreeNode.fromMap(map);

      expect(node.id, equals('node1'));
      expect(node.title, equals('Node 1'));
      expect(node.isNote, isTrue);
      expect(node.children, isEmpty);
      expect(node.isLocked, false);
    });

    test('fromMap test - one child', () {
      final map = {
        'id': 'node1',
        'title': 'Node 1',
        'isNote': true,
        'isLocked': false,
        'children': [
          {
            'id': 'child1',
            'title': 'Child 1',
            'isNote': false,
            'isLocked': false,
            'children': [],
          },
        ],
      };

      final node = MyTreeNode.fromMap(map);
      final childNode = node.children.first;

      expect(node.id, equals('node1'));
      expect(node.title, equals('Node 1'));
      expect(node.isNote, isTrue);
      expect(node.children.length, equals(1));
      expect(childNode.id, equals('child1'));
      expect(childNode.title, equals('Child 1'));
      expect(childNode.isNote, isFalse);
    });

    test('fromMap test - multiple children', () {
      final map = {
        'id': 'node1',
        'title': 'Node 1',
        'isNote': true,
        'isLocked': false,
        'children': [
          {
            'id': 'child1',
            'title': 'Child 1',
            'isNote': false,
            'isLocked': false,
            'children': [],
          },
          {
            'id': 'child2',
            'title': 'Child 2',
            'isNote': true,
            'isLocked': false,
            'children': [],
          },
        ],
      };

      final node = MyTreeNode.fromMap(map);

      expect(node.id, equals('node1'));
      expect(node.title, equals('Node 1'));
      expect(node.isNote, isTrue);
      expect(node.children.length, equals(2));
      expect(node.children[0].id, equals('child1'));
      expect(node.children[0].title, equals('Child 1'));
      expect(node.children[0].isNote, isFalse);
      expect(node.children[1].id, equals('child2'));
      expect(node.children[1].title, equals('Child 2'));
      expect(node.children[1].isNote, isTrue);
    });
  });
}
