import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notes/components/dialogs/createPasswordDialog.dart';
import 'package:notes/components/myTextField.dart';

void main() {
  // Create a testable widget wrapper
  Widget makeTestableWidget({required Widget child}) {
    return MaterialApp(
      home: child,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }

  group('CreatePasswordDialog tests', () {
    testWidgets('CreatePasswordDialog - dialog have correct content', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
          child: CreatePasswordDialog(
        onConfirm: () {},
        onCancel: () {},
        titleText: 'Set Your Password',
        confirmButtonText: 'Confirm',
        controller1: TextEditingController(),
        controller2: TextEditingController(),
      )));

      final alertDialog = tester.widget<AlertDialog>(
        find.byType(AlertDialog),
      );

      expect(find.text('Set Your Password'), findsOneWidget);
      expect(find.byType(MyTextField), findsNWidgets(2));
      expect(find.text('Confirm'), findsOneWidget);
      expect(find.byKey(const Key('cancelButton')), findsOneWidget);
      expect(alertDialog.shape, isA<RoundedRectangleBorder>());
    });

    testWidgets('CreatePasswordDialog - CallBack functions', (WidgetTester tester) async {
      bool confirmPressed = false;
      bool cancelPressed = false;
      await tester.pumpWidget(makeTestableWidget(
          child: CreatePasswordDialog(
        onConfirm: () {
          confirmPressed = true;
        },
        onCancel: () {
          cancelPressed = true;
        },
        titleText: 'Set Your Password',
        confirmButtonText: 'Confirm',
        controller1: TextEditingController(),
        controller2: TextEditingController(),
      )));

      await tester.tap(find.byKey(const Key('confirmButton')));
      await tester.pump();

      expect(confirmPressed, true);

      await tester.tap(find.byKey(const Key('cancelButton')));
      await tester.pump();

      expect(cancelPressed, true);
    });

    testWidgets('CreatePasswordDialog - inputing text', (WidgetTester tester) async {
      final controller1 = TextEditingController();
      final controller2 = TextEditingController();

      await tester.pumpWidget(makeTestableWidget(
          child: CreatePasswordDialog(
        onConfirm: () {},
        onCancel: () {},
        titleText: 'Set Your Password',
        confirmButtonText: 'Confirm',
        controller1: controller1,
        controller2: controller2,
      )));

      // Define the text to enter into the text fields
      const passwordText = 'myPassword123';
      const confirmPasswordText = 'myPassword123';

      // Find the text fields
      final passwordField = find.byType(MyTextField).first;
      final confirmPasswordField = find.byType(MyTextField).last;

      // Enter text into the first password field
      await tester.enterText(passwordField, passwordText);
      await tester.pump();

      // Enter text into the confirmation password field
      await tester.enterText(confirmPasswordField, confirmPasswordText);
      await tester.pump();

      // Verify that the text controllers hold the expected text
      expect(controller1.text, equals(passwordText));
      expect(controller2.text, equals(confirmPasswordText));
    });
  });
}
