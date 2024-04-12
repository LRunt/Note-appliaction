import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notes/components/dialogs/aboutAppDialog.dart';

void main() {
  group('AboutAppDialog tests', () {
    testWidgets('AboutAppDialog - dialog have correct content', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: AboutAppDialog(onClose: () {}),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ));

      final alertDialog = tester.widget<AlertDialog>(
        find.byType(AlertDialog),
      );

      expect(find.byKey(const Key('title')), findsOneWidget);
      expect(find.byKey(const Key('content')), findsOneWidget);
      expect(find.byKey(const Key('closeButton')), findsOneWidget);
      expect(alertDialog.shape, isA<RoundedRectangleBorder>());
    });

    testWidgets('AboutAppDialog - CallBack functions', (WidgetTester tester) async {
      bool closePressed = false;
      await tester.pumpWidget(MaterialApp(
        home: AboutAppDialog(onClose: () => closePressed = true),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ));

      await tester.tap(find.byKey(const Key('closeButton')));
      await tester.pump();

      expect(closePressed, isTrue);
    });
  });
}
