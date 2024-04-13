import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mockito/mockito.dart';
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
  dynamic get(key, {dynamic defaultValue}) {
    if (key == LOCAL_SYNC) {
      return 1234567890;
    }
    return super.noSuchMethod(Invocation.method(#get, [key], {#defaultValue: defaultValue}));
  }
}

void main() {
  group('SynchronizationDatabase Tests', () {
    late MockBox mockBox;
    late SynchronizationDatabase syncDatabase;

    setUp(() {
      mockBox = MockBox();
      syncDatabase = SynchronizationDatabase();
      boxSynchronization = mockBox;
    });

    test('saveLastSyncTime - simple test', () {
      // Arrange
      const int syncTime = 987654321;

      // Act
      syncDatabase.saveLastSyncTime(syncTime);

      // Assert
      verify(mockBox.put(LOCAL_SYNC, syncTime)).called(1);
    });

    test('getLastSyncTime - simple test', () {
      // Act
      final result = syncDatabase.getLastSyncTime();

      // Assert
      expect(result, 1234567890);
    });

    test('getLastHierarchyChangeTime - simple test', () {
      // Arrange
      when(mockBox.get(LAST_CHANGE)).thenReturn(1234567890);

      // Act
      final result = syncDatabase.getLastHierarchyChangeTime();

      // Assert
      expect(result, 1234567890);
    });

    test('getLastNoteChangeTime - simple test', () {
      // Arrange
      const String noteId = '123';
      when(mockBox.get(noteId)).thenReturn(987654321);

      // Act
      final result = syncDatabase.getLastNoteChangeTime(noteId);

      // Assert
      expect(result, 987654321);
    });

    test('getLastChange - simple test', () {
      // Arrange
      when(mockBox.get(LAST_CHANGE)).thenReturn(987654321);

      // Act
      final result = syncDatabase.getLastChange();

      // Assert
      expect(result, 987654321);
    });
  });
}
