import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:hive/hive.dart';
import 'package:notes/constants.dart';
import 'package:notes/boxes.dart';
import 'package:notes/data/local_databases.dart';
import 'package:notes/model/myTreeNode.dart';

class MockBox extends Mock implements Box {
  @override
  Future<void> put(key, value) => super.noSuchMethod(
        Invocation.method(#put, [key, value]),
        returnValue: Future.value(),
        returnValueForMissingStub: Future.value(),
      );

  @override
  Future<void> delete(key) => super.noSuchMethod(
        Invocation.method(#delete, [key]),
        returnValue: Future.value(),
        returnValueForMissingStub: Future.value(),
      );

  @override
  dynamic get(key, {dynamic defaultValue}) => super.noSuchMethod(
        Invocation.method(#get, [key], {#defaultValue: defaultValue}),
        returnValue: null,
        returnValueForMissingStub: null,
      );
}

void main() {
  group('HierarchyDatabase Tests', () {
    late MockBox mockBoxSynchronization;
    late MockBox mockBoxHierarchy;
    late HierarchyDatabase hierarchyDatabase;

    setUp(() {
      mockBoxSynchronization = MockBox();
      mockBoxHierarchy = MockBox();
      hierarchyDatabase = HierarchyDatabase();
      boxSynchronization = mockBoxSynchronization;
      boxHierachy = mockBoxHierarchy;
    });

    test('createDefaultData - simple test', () {
      // Act
      hierarchyDatabase.createDefaultData();

      // Assert
      verify(mockBoxSynchronization.put(ROOT_LIST, <String>[])).called(1);
      verify(mockBoxSynchronization.put(NOTE_LIST, [])).called(1);
    });

    test('loadData - simple test', () {
      // Arrange
      when(mockBoxSynchronization.get(ROOT_LIST)).thenReturn(['root1', 'root2']);
      when(mockBoxHierarchy.get('root1'))
          .thenReturn(MyTreeNode(id: "root1", title: "root1", isNote: false, isLocked: false));
      when(mockBoxHierarchy.get('root2'))
          .thenReturn(MyTreeNode(id: "root2", title: "root2", isNote: false, isLocked: false));
      // Act
      hierarchyDatabase.loadData();

      // Assert
      expect(HierarchyDatabase.roots.length, 2);
    });

    test('getRoot - simple test', () {
      // Arrange
      String rootId = 'root1';
      MyTreeNode expectedNode = MyTreeNode(
        id: 'root1',
        title: 'Root Node',
        isNote: false,
        isLocked: false,
      );
      when(mockBoxHierarchy.get(rootId)).thenReturn(expectedNode);

      // Act
      final result = hierarchyDatabase.getRoot(rootId);

      // Assert
      expect(result, expectedNode);
    });

    test('getRootLastChangeTime - simple test', () {
      // Arrange
      String rootId = 'root1';
      int expectedLastChangeTime = 1618296000000;
      when(mockBoxSynchronization.get(rootId)).thenReturn(expectedLastChangeTime);

      // Act
      final result = hierarchyDatabase.getRootLastChangeTime(rootId);

      // Assert
      expect(result, expectedLastChangeTime);
    });

    test('getNoteList - simple test', () {
      // Arrange
      final List<String> expectedNoteList = ['note1', 'note2'];
      when(mockBoxSynchronization.get(NOTE_LIST)).thenReturn(expectedNoteList);

      // Act
      final result = hierarchyDatabase.getNoteList();

      // Assert
      expect(result, expectedNoteList);
    });

    test('getRootList - simple test', () {
      // Arrange
      final List<String> expectedRootList = ['root1', 'root2'];
      when(mockBoxSynchronization.get(ROOT_LIST)).thenReturn(expectedRootList);

      // Act
      final result = hierarchyDatabase.getRootList();

      // Assert
      expect(result, expectedRootList);
    });

    test('saveNoteList - simple test', () {
      // Arrange
      final List<String> notes = ['note1', 'note2'];

      // Act
      hierarchyDatabase.saveNoteList(notes);

      // Assert
      verify(mockBoxSynchronization.put(NOTE_LIST, notes)).called(1);
    });
  });
}
