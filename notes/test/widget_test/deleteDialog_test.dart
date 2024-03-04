import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notes/components/dialogs/deleteDialog.dart';

void main() {
  testWidgets('DeleteDialog Test', (WidgetTester tester) async {
    // Define the callbacks to test their invocation
    bool onDeleteCalled = false;
    bool onCancelCalled = false;

    // Create a MaterialApp to properly load localizations
    await tester.pumpWidget(MaterialApp(
      home: DeleteDialog(
        titleText: 'Delete Node',
        contentText: 'Are you sure you want to delete this node?',
        onDelete: () {
          onDeleteCalled = true;
        },
        onCancel: () {
          onCancelCalled = true;
        },
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ));

    // Wait for all animations and futures to complete
    await tester.pumpAndSettle();

    // Use AppLocalizations to get the correct localized text
    final AppLocalizations loc =
        AppLocalizations.of(tester.element(find.byType(DeleteDialog)))!;

    // Verify the title and content texts are displayed
    expect(find.text('Delete Node'), findsOneWidget);
    expect(find.text('Are you sure you want to delete this node?'),
        findsOneWidget);

    // Tap the delete button and verify onDelete is called
    await tester.tap(find.text(loc.delete));
    expect(onDeleteCalled, true);

    // Tap the cancel button and verify onCancel is called
    await tester.tap(find.text(loc.cancel));
    expect(onCancelCalled, true);
  });
}
