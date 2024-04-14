import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notes/components/dialogs/dialogs.dart';

void main() {
  // Define test widgets and necessary mock callbacks
  final List<DropdownMenuItem<String>> testItems = [
    const DropdownMenuItem(value: "1", child: Text("Item 1")),
    const DropdownMenuItem(value: "2", child: Text("Item 2")),
  ];

  String? selectedValue;

  group('DropdownMenuDialog Tests', () {
    testWidgets('Confirm button trigers onConfirm callback', (WidgetTester tester) async {
      bool confirmPressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: DropdownMenuDialog(
            onConfirm: () => confirmPressed = true,
            onCancel: () {},
            titleText: 'Select Option',
            confirmButtonText: 'Confirm',
            items: testItems,
            onSelect: (value) {
              selectedValue = value;
            },
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      );

      await tester.tap(find.text('Confirm'));
      await tester.pump();

      expect(confirmPressed, isTrue);
    });

    testWidgets('Confirm button trigers onCancel callback', (WidgetTester tester) async {
      bool cancelPressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: DropdownMenuDialog(
            onConfirm: () {},
            onCancel: () => cancelPressed = true,
            titleText: 'Select Option',
            confirmButtonText: 'Confirm',
            items: testItems,
            onSelect: (value) {
              selectedValue = value;
            },
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      );

      await tester.tap(find.byKey(const Key('cancelButton')));
      await tester.pump();

      expect(cancelPressed, isTrue);
    });

    testWidgets('displays correctly with title and confirm button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DropdownMenuDialog(
            onConfirm: () {},
            onCancel: () {},
            titleText: 'Select Option',
            confirmButtonText: 'Confirm',
            items: testItems,
            onSelect: (value) {
              selectedValue = value;
            },
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      );

      expect(find.text('Select Option'), findsOneWidget);
      expect(find.text('Confirm'), findsOneWidget);
    });

    testWidgets('dropdown selection updates value', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DropdownMenuDialog(
            onConfirm: () {},
            onCancel: () {},
            titleText: 'Select Option',
            confirmButtonText: 'Confirm',
            items: testItems,
            onSelect: (value) {
              selectedValue = value;
            },
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      );

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Item 1').last);
      await tester.pumpAndSettle();

      expect(selectedValue, '1');
    });
  });
}
