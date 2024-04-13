import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:hive/hive.dart';
import 'package:notes/assets/constants.dart';
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
  });
}
