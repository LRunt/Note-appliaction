import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:hive/hive.dart';
import 'package:notes/assets/constants.dart';
import 'package:notes/boxes.dart';
import 'package:notes/data/local_databases.dart';

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
  group('NotesDatabase Tests', () {
    late MockBox mockBoxNotes;
    late MockBox mockBoxSynchronization;
    late NotesDatabase notesDatabase;

    setUp(() {
      mockBoxNotes = MockBox();
      mockBoxSynchronization = MockBox();
      notesDatabase = NotesDatabase();
      boxNotes = mockBoxNotes;
      boxSynchronization = mockBoxSynchronization;
    });

    test('saveAllNotes - simple test', () async {
      // Arrange
      final notes = [
        {NOTE_ID: 'note1', CONTENT: 'Content 1', NOTE_TIMESTAMP: 123456789},
        {NOTE_ID: 'note2', CONTENT: 'Content 2', NOTE_TIMESTAMP: 987654321},
      ];

      // Act
      await notesDatabase.saveAllNotes(notes);

      // Assert
      verify(mockBoxNotes.put('note1', 'Content 1')).called(1);
      verify(mockBoxSynchronization.put('note1', 123456789)).called(1);
      verify(mockBoxNotes.put('note2', 'Content 2')).called(1);
      verify(mockBoxSynchronization.put('note2', 987654321)).called(1);
    });

    test('saveNote - simple test', () {
      // Arrange
      const String noteId = '123';
      const String content = 'Sample content';
      const int updateTime = 987654321;

      // Act
      notesDatabase.saveNote(noteId, content, updateTime);

      // Assert
      verify(mockBoxNotes.put(noteId, content)).called(1);
      verify(mockBoxSynchronization.put(noteId, updateTime)).called(1);
    });

    test('changeNoteId - simple test', () async {
      // Arrange
      when(mockBoxNotes.get('oldId')).thenReturn('Old Content');

      // Act
      await notesDatabase.changeNoteId('oldId', 'newId');

      // Assert
      verify(mockBoxNotes.put('newId', 'Old Content')).called(1);
      verify(mockBoxNotes.delete('oldId')).called(1);
    });

    test('deleteNote - simple test', () async {
      // Act
      notesDatabase.deleteNote('noteId');

      // Assert
      verify(mockBoxNotes.delete('noteId')).called(1);
      verify(mockBoxSynchronization.delete('noteId')).called(1);
    });

    test('getNote - simple test', () {
      // Arrange
      when(mockBoxNotes.get('noteId')).thenReturn('Note Content');

      // Act
      final content = notesDatabase.getNote('noteId');

      // Assert
      expect(content, 'Note Content');
    });

    test('getNote - return null (note not found)', () {
      // Arrange
      when(mockBoxNotes.get('noteId')).thenReturn(null);

      // Act
      final content = notesDatabase.getNote('noteId');

      // Assert
      expect(content, isNull);
    });

    test('updateNote updates note content and timestamp', () {
      // Act
      notesDatabase.updateNote('noteId', 'New Content');

      // Assert
      verify(mockBoxNotes.put('noteId', 'New Content')).called(1);
      verify(mockBoxSynchronization.put('noteId', any)).called(1);
    });

    test('createNote creates a new note with timestamp', () async {
      // Act
      notesDatabase.createNote('newNoteId');

      // Assert
      verify(mockBoxNotes.put('newNoteId', null)).called(1);
    });
  });
}
