import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:hive/hive.dart';
import 'package:notes/constants.dart';
import 'package:notes/boxes.dart';
import 'package:notes/data/local_databases.dart';
import 'package:notes/model/my_tree_node.dart';

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

  @override
  bool containsKey(key) => super.noSuchMethod(
        Invocation.method(#containsKey, [key]),
        returnValue: true,
        returnValueForMissingStub: false,
      );
}

void main() {
  group(
    'HierarchyDatabase Tests',
    () {
      late MockBox mockBoxSynchronization;
      late MockBox mockBoxHierarchy;
      late MockBox mockBoxNotes;
      late HierarchyDatabase hierarchyDatabase;

      setUp(
        () {
          mockBoxSynchronization = MockBox();
          mockBoxHierarchy = MockBox();
          mockBoxNotes = MockBox();
          hierarchyDatabase = HierarchyDatabase();
          boxSynchronization = mockBoxSynchronization;
          boxHierachy = mockBoxHierarchy;
          boxNotes = mockBoxNotes;
        },
      );

      tearDown(
        () {
          HierarchyDatabase.rootList = [];
          HierarchyDatabase.roots = [];
        },
      );

      test(
        'rootList data exists',
        () {
          when(mockBoxHierarchy.containsKey(ROOT_LIST)).thenReturn(true);
          when(mockBoxHierarchy.get(ROOT_LIST)).thenReturn(["root1", "root2"]);
          // Act
          final result = hierarchyDatabase.rootDataNotExist();

          // Assert
          expect(result, true);
        },
      );

      test(
        'createDefaultData - simple test',
        () {
          // Act
          hierarchyDatabase.createDefaultData();

          // Assert
          verify(mockBoxSynchronization.put(ROOT_LIST, <String>[])).called(1);
          verify(mockBoxSynchronization.put(NOTE_LIST, [])).called(1);
        },
      );

      test(
        'loadData - simple test',
        () {
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
        },
      );

      test(
        'saveRoot should add root to roots list and synchronize data',
        () {
          // Arrange
          final MyTreeNode testRoot =
              MyTreeNode(id: "id", title: "title", isNote: false, isLocked: false);
          when(mockBoxSynchronization.put(any, any)).thenAnswer((_) async {});

          // Act
          hierarchyDatabase.saveRoot(testRoot);

          // Assert
          expect(HierarchyDatabase.roots.contains(testRoot), isTrue);
          expect(HierarchyDatabase.rootList.contains('id'), isTrue);
          verify(mockBoxSynchronization.put(ROOT_LIST, any)).called(1);
          verify(mockBoxHierarchy.put("id", any)).called(1);
        },
      );

      test(
        'saveRootList should save list of root IDs',
        () {
          // Arrange
          final List<String> testRootList = ['root1', 'root2'];
          when(mockBoxSynchronization.get(ROOT_LIST)).thenReturn(['root1', 'root2']);

          // Act
          hierarchyDatabase.saveRootList(testRootList);

          // Assert
          verify(mockBoxSynchronization.put(ROOT_LIST, testRootList)).called(1);
        },
      );

      test(
        'downloadRoot should save downloaded root node and its last change time',
        () {
          // Arrange
          final MyTreeNode testRoot =
              MyTreeNode(id: "root1", title: "title", isNote: false, isLocked: false);
          const int lastChangeTime = 1618296000000;
          when(mockBoxSynchronization.put(any, any)).thenAnswer((_) async {});
          when(mockBoxHierarchy.put(any, any)).thenAnswer((_) async {});

          // Act
          hierarchyDatabase.downloadRoot(testRoot, lastChangeTime);

          // Assert
          verify(mockBoxSynchronization.put('root1', lastChangeTime)).called(1);
          verify(mockBoxHierarchy.put('root1', testRoot)).called(1);
        },
      );

      test(
        'deleteRoot should remove root from roots list and database',
        () {
          // Arrange
          final MyTreeNode testRoot =
              MyTreeNode(id: "root1", title: "title", isNote: false, isLocked: false);
          HierarchyDatabase.roots.add(testRoot);
          HierarchyDatabase.rootList.add('root1');
          when(mockBoxSynchronization.put(any, any)).thenAnswer((_) async {});
          when(mockBoxSynchronization.delete(any)).thenAnswer((_) async {});
          when(mockBoxHierarchy.delete(any)).thenAnswer((_) async {});

          // Act
          hierarchyDatabase.deleteRoot(testRoot);

          // Assert
          expect(HierarchyDatabase.roots.contains(testRoot), isFalse);
          expect(HierarchyDatabase.rootList.contains('root1'), isFalse);
          verify(mockBoxSynchronization.delete('root1')).called(1);
          verify(mockBoxHierarchy.delete('root1')).called(1);
        },
      );

      test(
        'updateRoot should update root ID and synchronize changes',
        () {
          // Arrange
          const String oldRootId = 'oldRoot';
          const String newRootId = 'newRoot';
          HierarchyDatabase.rootList = ['oldRoot', 'someOtherRoot'];
          when(mockBoxSynchronization.get(ROOT_LIST)).thenReturn(['oldRoot', 'someOtherRoot']);
          when(mockBoxSynchronization.put(any, any)).thenAnswer((_) async {});
          when(mockBoxSynchronization.delete(any)).thenAnswer((_) async {});

          // Act
          hierarchyDatabase.updateRoot(oldRootId, newRootId);

          // Assert
          expect(HierarchyDatabase.rootList.contains('newRoot'), isTrue);
          expect(HierarchyDatabase.rootList.contains('oldRoot'), isFalse);
          verify(mockBoxSynchronization.delete('oldRoot')).called(1);
          verify(mockBoxSynchronization.put('newRoot', any)).called(1);
        },
      );

      test(
        'updateRootLastChangeTime should update the last change time for a root node',
        () {
          // Arrange
          const String rootId = 'root1';
          when(mockBoxSynchronization.put(any, any)).thenAnswer((_) async {});

          // Act
          hierarchyDatabase.updateRootLastChangeTime(rootId);

          // Assert
          verify(mockBoxSynchronization.put(rootId, any)).called(1);
          verify(mockBoxSynchronization.put(LAST_CHANGE, any)).called(1);
        },
      );

      test(
        'updateDatabase should update all root nodes and last change time in the database',
        () {
          // Arrange
          final MyTreeNode rootNode =
              MyTreeNode(id: "root1", title: "title", isNote: false, isLocked: false);
          HierarchyDatabase.roots = [rootNode];
          HierarchyDatabase.rootList = ['root1'];
          when(mockBoxSynchronization.put(any, any)).thenAnswer((_) async {});
          when(mockBoxHierarchy.put(any, any)).thenAnswer((_) async {});

          // Act
          hierarchyDatabase.updateDatabase();

          // Assert
          verify(mockBoxHierarchy.put('root1', rootNode)).called(1);
          verify(mockBoxSynchronization.put(ROOT_LIST, any)).called(1);
          verify(mockBoxSynchronization.put(LAST_CHANGE, any)).called(1);
        },
      );

      test(
        'addNote should add a note ID to the note list and update it in the database',
        () {
          // Arrange
          const String noteId = 'note1';
          when(mockBoxSynchronization.get(NOTE_LIST)).thenReturn(['note0']);
          when(mockBoxSynchronization.put(any, any)).thenAnswer((_) async {});

          // Act
          hierarchyDatabase.addNote(noteId);

          // Assert
          verify(mockBoxSynchronization.get(NOTE_LIST)).called(1);
          verify(mockBoxSynchronization.put(NOTE_LIST, ['note0', 'note1'])).called(1);
        },
      );

      test(
        'deleteNote should remove a note ID from the note list and update it in the database',
        () {
          // Arrange
          const String noteId = 'note1';
          when(mockBoxSynchronization.get(NOTE_LIST)).thenReturn(['note1', 'note2']);
          when(mockBoxSynchronization.put(any, any)).thenAnswer((_) async {});

          // Act
          hierarchyDatabase.deleteNote(noteId);

          // Assert
          verify(mockBoxSynchronization.get(NOTE_LIST)).called(1);
          verify(mockBoxSynchronization.put(NOTE_LIST, ['note2'])).called(1);
        },
      );

      test(
        'updateNote should update the note ID in the note list and update it in the database',
        () {
          // Arrange
          const String oldNoteId = 'oldNote';
          const String newNoteId = 'newNote';
          List<String> initialList = ['oldNote', 'note2']; // Ensure this is mutable if needed
          when(mockBoxSynchronization.get(NOTE_LIST)).thenReturn(initialList);
          when(mockBoxSynchronization.put(any, any)).thenAnswer((_) async {});

          // Act
          hierarchyDatabase.updateNote(oldNoteId, newNoteId);

          // Assert
          verify(mockBoxSynchronization.get(NOTE_LIST)).called(1);
        },
      );

      test(
        'getRoot - simple test',
        () {
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
        },
      );

      test(
        'getRootLastChangeTime - simple test',
        () {
          // Arrange
          String rootId = 'root1';
          int expectedLastChangeTime = 1618296000000;
          when(mockBoxSynchronization.get(rootId)).thenReturn(expectedLastChangeTime);

          // Act
          final result = hierarchyDatabase.getRootLastChangeTime(rootId);

          // Assert
          expect(result, expectedLastChangeTime);
        },
      );

      test(
        'getNoteList - simple test',
        () {
          // Arrange
          final List<String> expectedNoteList = ['note1', 'note2'];
          when(mockBoxSynchronization.get(NOTE_LIST)).thenReturn(expectedNoteList);

          // Act
          final result = hierarchyDatabase.getNoteList();

          // Assert
          expect(result, expectedNoteList);
        },
      );

      test(
        'getRootList - simple test',
        () {
          // Arrange
          final List<String> expectedRootList = ['root1', 'root2'];
          when(mockBoxSynchronization.get(ROOT_LIST)).thenReturn(expectedRootList);

          // Act
          final result = hierarchyDatabase.getRootList();

          // Assert
          expect(result, expectedRootList);
        },
      );

      test(
        'saveNoteList - simple test',
        () {
          // Arrange
          final List<String> notes = ['note1', 'note2'];

          // Act
          hierarchyDatabase.saveNoteList(notes);

          // Assert
          verify(mockBoxSynchronization.put(NOTE_LIST, notes)).called(1);
        },
      );

      test(
        'conflict data exists',
        () {
          when(mockBoxHierarchy.containsKey(CONFLICT)).thenReturn(true);
          when(mockBoxHierarchy.get(CONFLICT)).thenReturn(MyTreeNode(
            id: CONFLICT,
            title: 'Root Node',
            isNote: false,
            isLocked: false,
          ));
          // Act
          final result = hierarchyDatabase.conflictDataNotExist();

          // Assert
          expect(result, false);
        },
      );

      test('saveConflictData should initialize and save new conflict data', () {
        // Arrange
        HierarchyDatabase.roots = [
          MyTreeNode(
            id: CONFLICT,
            title: 'Root Node',
            isNote: false,
            isLocked: false,
          )
        ];
        when(boxHierachy.get(CONFLICT)).thenReturn(MyTreeNode(
          id: CONFLICT,
          title: 'Root Node',
          isNote: false,
          isLocked: false,
        ));
        when(boxHierachy.put(any, any)).thenAnswer((_) async {});
        when(mockBoxHierarchy.containsKey(CONFLICT)).thenReturn(true);
        // Act
        hierarchyDatabase.saveConflictData();

        // Assert
        verify(boxHierachy.get(CONFLICT)).called(2);
        verify(boxHierachy.put(any, any)).called(1);
      });

      test('saveConflict should add a node to conflict data', () {
        // Arrange
        final MyTreeNode node = MyTreeNode(
          id: 'node1',
          title: 'node1',
          isNote: false,
          isLocked: false,
        );
        final MyTreeNode conflictRoot = MyTreeNode(
          id: CONFLICT,
          title: 'Root Node',
          isNote: false,
          isLocked: false,
        );
        when(boxHierachy.get(CONFLICT)).thenReturn(conflictRoot);
        when(boxHierachy.put(CONFLICT, any)).thenAnswer((_) async {});
        when(mockBoxHierarchy.containsKey(CONFLICT)).thenReturn(true);

        // Act
        hierarchyDatabase.saveConflict(node);

        // Assert
        verify(boxHierachy.get(CONFLICT)).called(2);
        verify(boxHierachy.put(CONFLICT, any)).called(1);
      });

      test('saveConflictNote should save note as conflict and copy its content', () {
        // Arrange
        final MyTreeNode note = MyTreeNode(
          id: 'note1',
          title: 'note1',
          isNote: false,
          isLocked: false,
        );
        when(boxHierachy.get(CONFLICT)).thenReturn(MyTreeNode(
          id: CONFLICT,
          title: 'Root Node',
          isNote: false,
          isLocked: false,
        ));
        when(mockBoxNotes.get('note1')).thenReturn('content');
        when(mockBoxNotes.put(any, any)).thenAnswer((_) async {});
        when(boxHierachy.put(any, any)).thenAnswer((_) async {});
        when(mockBoxHierarchy.containsKey(CONFLICT)).thenReturn(true);

        // Act
        hierarchyDatabase.saveConflictNote(note, 'note1');

        // Assert
        verify(mockBoxNotes.get('note1')).called(1);
        verify(mockBoxNotes.put('note1', 'content')).called(1);
        verify(boxHierachy.put(CONFLICT, any)).called(1);
      });

      test('loadConflictData should load conflict data', () {
        // Arrange
        final MyTreeNode conflictNode = MyTreeNode(
          id: CONFLICT,
          title: 'Root Node',
          isNote: false,
          isLocked: false,
        );
        when(boxHierachy.get(CONFLICT)).thenReturn(conflictNode);

        // Act
        hierarchyDatabase.loadConflictData();

        // Assert
        verify(boxHierachy.get(CONFLICT)).called(1);
      });

      test('initConflictData should create initial conflict node', () {
        // Arrange
        when(boxHierachy.put(CONFLICT, any)).thenAnswer((_) async {});

        // Act
        hierarchyDatabase.initConflictData();

        // Assert
        verify(boxHierachy.put(CONFLICT, any)).called(1);
      });

      test('getConflictNode should return the conflict node', () {
        // Arrange
        final MyTreeNode expectedNode = MyTreeNode(
          id: CONFLICT,
          title: 'Root Node',
          isNote: false,
          isLocked: false,
        );
        when(boxHierachy.get(CONFLICT)).thenReturn(expectedNode);

        // Act
        final result = hierarchyDatabase.getConflictNode();

        // Assert
        expect(result, equals(expectedNode));
        verify(boxHierachy.get(CONFLICT)).called(1);
      });

      test('deleteConflictNote should remove a conflict note from the database', () {
        // Arrange
        when(boxNotes.delete(any)).thenAnswer((_) async {});

        // Act
        hierarchyDatabase.deleteConflictNote('noteId');

        // Assert
        verify(boxNotes.delete('noteId')).called(1);
      });

      test('saveConflictNode should save conflict node changes', () {
        // Arrange
        final MyTreeNode node = MyTreeNode(
          id: 'conflict',
          title: 'Root Node',
          isNote: false,
          isLocked: false,
        );
        when(boxHierachy.put(CONFLICT, any)).thenAnswer((_) async {});

        // Act
        hierarchyDatabase.saveConflictNode(node);

        // Assert
        verify(boxHierachy.put(CONFLICT, node)).called(1);
      });
    },
  );
}
