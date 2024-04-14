import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notes/components/dialogs/dialogs.dart';

void main() {
  testWidgets('EnterPasswordDialog - dialog have correct content', (WidgetTester tester) async {
    final TextEditingController controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EnterPasswordDialog(
            onConfirm: () {},
            onCancel: () {},
            titleText: 'Enter Password',
            confirmButtonText: 'Confirm',
            controller: controller,
          ),
        ),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );

    expect(find.text('Enter Password'), findsOneWidget);
    expect(find.byKey(const Key('cancelButton')), findsOneWidget);
    expect(find.text('Confirm'), findsOneWidget);

    await tester.tap(find.byKey(const Key('confirmButton')));
    await tester.pump();
  });
}
