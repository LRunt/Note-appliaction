//import 'package:flutter_quill/flutter_quill.dart';
//import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:notes/data/local_databases.dart';
//import 'package:notes/components/richTextEditor.dart';
//import 'package:flutter/material.dart';

class MockNotesDatabase extends Mock implements NotesDatabase {}

void main() {
  //MockNotesDatabase mockNotesDb = MockNotesDatabase();

  /*testWidgets('FloatingActionButton toggles controls visibility', (WidgetTester tester) async {
    when(mockNotesDb.getNote('noteId')).thenReturn('{"insert": "Test Note"}');
    // Build our app and trigger a frame
    await tester.pumpWidget(const MaterialApp(home: RichTextEditor(noteId: 'testNoteId')));

    // Verify that controls are visible initially
    expect(find.byType(QuillToolbar), findsOneWidget);

    // Tap the FloatingActionButton
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Verify that controls are now hidden
    expect(find.byType(QuillToolbar), findsNothing);
  });*/
}
