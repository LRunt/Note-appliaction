import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:hive/hive.dart';
import 'package:notes/boxes.dart';
import 'package:notes/data/local_databases.dart';
import 'package:notes/model/myTreeNode.dart';

// Using the mock box instead of the real Hive box
class MockBox extends Mock implements Box {
  @override
  Future<int> clear() => super.noSuchMethod(
        Invocation.method(#clear, []),
        returnValue: Future.value(0),
        returnValueForMissingStub: Future.value(0),
      );
}

void main() {
  late ClearDatabase clearDatabase;
  late MockBox mockBoxHierarchy;
  late MockBox mockBoxNotes;
  late MockBox mockBoxUser;
  late MockBox mockBoxSynchronization;
  group('ClearDatabase Tests', () {
    setUp(() {
      mockBoxHierarchy = MockBox();
      mockBoxNotes = MockBox();
      mockBoxUser = MockBox();
      mockBoxSynchronization = MockBox();
      boxHierachy = mockBoxHierarchy;
      boxNotes = mockBoxNotes;
      boxUser = mockBoxUser;
      boxSynchronization = mockBoxSynchronization;
      clearDatabase = ClearDatabase();

      HierarchyDatabase.noteList = ["note1", "note2", "note3"];
      HierarchyDatabase.rootList = ["root1", "root2", "root3"];
      HierarchyDatabase.roots = [
        MyTreeNode(id: "id", title: "title", isNote: false, isLocked: false)
      ];
      HierarchyDatabase.conflictData = [];
    });

    test('clearAllData calls clear on all relevant boxes', () async {
      // Act
      await clearDatabase.clearAllData();

      // Assert
      verify(mockBoxHierarchy.clear()).called(1);
      verify(mockBoxNotes.clear()).called(1);
      verify(mockBoxUser.clear()).called(1);
      verify(mockBoxSynchronization.clear()).called(1);

      expect(HierarchyDatabase.noteList.isEmpty, isTrue);
      expect(HierarchyDatabase.rootList.isEmpty, isTrue);
      expect(HierarchyDatabase.roots.isEmpty, isTrue);
      expect(HierarchyDatabase.conflictData.isEmpty, isTrue);
    });

    test('clearHierarchyStructure only clears hierarchy box', () async {
      // Act
      await clearDatabase.clearHierarchyStructure();

      // Assert
      verify(mockBoxHierarchy.clear()).called(1);
      verifyNever(mockBoxNotes.clear());
      verifyNever(mockBoxUser.clear());
      verifyNever(mockBoxSynchronization.clear());
    });

    test('clearNoteData only clears notes box', () async {
      // Act
      await clearDatabase.clearNoteData();

      // Assert
      verify(mockBoxNotes.clear()).called(1);
      verifyNever(mockBoxHierarchy.clear());
      verifyNever(mockBoxUser.clear());
      verifyNever(mockBoxSynchronization.clear());
    });

    test('clearUserData only clears user box', () async {
      // Act
      await clearDatabase.clearUserData();

      // Assert
      verify(mockBoxUser.clear()).called(1);
      verifyNever(mockBoxNotes.clear());
      verifyNever(mockBoxHierarchy.clear());
      verifyNever(mockBoxSynchronization.clear());
    });

    test('clearSyncTimes only clears synchronization box', () async {
      // Act
      await clearDatabase.clearSyncTimes();

      // Assert
      verify(mockBoxSynchronization.clear()).called(1);
      verifyNever(mockBoxNotes.clear());
      verifyNever(mockBoxUser.clear());
      verifyNever(mockBoxHierarchy.clear());
    });
  });
}
