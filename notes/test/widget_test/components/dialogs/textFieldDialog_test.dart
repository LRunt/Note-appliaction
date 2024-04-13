import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes/components/dialogs/textFieldDialog.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  group('TextFieldDialog Tests', () {
    testWidgets('TextFieldDialog - onConfirm callback', (WidgetTester tester) async {
      bool confirmPressed = false;
      await tester.pumpWidget(MaterialApp(
        home: TextFieldDialog(
          onConfirm: () => confirmPressed = true,
          onCancel: () {},
          titleText: 'Test Title',
          confirmButtonText: 'Confirm',
          controller: TextEditingController(),
          hint: "hint",
        ),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ));

      await tester.tap(find.text('Confirm'));
      await tester.pump();

      expect(confirmPressed, isTrue);
    });

    testWidgets('TextFieldDialog - onCancel callback', (WidgetTester tester) async {
      bool cancelPressed = false;
      await tester.pumpWidget(MaterialApp(
        home: TextFieldDialog(
          onConfirm: () {},
          onCancel: () => cancelPressed = true,
          titleText: 'Test Title',
          confirmButtonText: 'Confirm',
          controller: TextEditingController(),
          hint: "hint",
        ),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ));

      await tester.tap(find.byKey(const Key('cancelButton')));
      await tester.pump();

      expect(cancelPressed, isTrue);
    });
  });
}
