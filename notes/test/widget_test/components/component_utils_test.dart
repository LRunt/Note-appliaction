import 'package:flutter_test/flutter_test.dart';
import 'package:notes/components/components.dart';
import 'package:notes/constants.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('getProgressIndicator displays a modal progress indicator',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) {
          return ElevatedButton(
            onPressed: () {
              ComponentUtils.getProgressIndicator(context);
            },
            child: Text('Show Progress Indicator'),
          );
        },
      ),
    ));

    // Tap the button to trigger the progress indicator
    await tester.tap(find.text('Show Progress Indicator'));
    await tester.pump(); // Start the animation

    // Pump for a short duration rather than using pumpAndSettle
    await tester.pump(Duration(seconds: 1)); // Simulate one second passing

    // Check if the CircularProgressIndicator is showing
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Optionally ensure the dialog is modal by checking if other widgets are not tappable
    // Example: expect(() => tester.tap(find.text('OtherWidget')), throwsAssertionError);
  });

  group('ComponentUtils SnackBars', () {
    testWidgets('shows error snack bar', (WidgetTester tester) async {
      final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          key: scaffoldKey,
          body: Builder(
            builder: (BuildContext context) {
              return ElevatedButton(
                onPressed: () {
                  ComponentUtils.getSnackBarError(context, "Error");
                },
                child: const Text('Show Snackbar'),
              );
            },
          ),
        ),
      ));

      // Tap the button to show the snackbar
      await tester.tap(find.text('Show Snackbar'));
      await tester.pump(); // Rebuild the widget

      // Expect a SnackBar to appear with specific text
      expect(find.text('Error'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);

      // You can also check for color if needed
      final snackBar = tester.firstWidget(find.byType(SnackBar)) as SnackBar;
      expect(
          snackBar.backgroundColor, equals(COLOR_ERROR)); // Ensure you have defined COLOR_SUCCESS
    });

    testWidgets('shows info snack bar', (WidgetTester tester) async {
      final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          key: scaffoldKey,
          body: Builder(
            builder: (BuildContext context) {
              return ElevatedButton(
                onPressed: () {
                  ComponentUtils.getSnackBarInfo(context, "This is information");
                },
                child: const Text('Show Snackbar'),
              );
            },
          ),
        ),
      ));

      // Tap the button to show the snackbar
      await tester.tap(find.text('Show Snackbar'));
      await tester.pump(); // Rebuild the widget

      // Expect a SnackBar to appear with specific text
      expect(find.text('This is information'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);

      // You can also check for color if needed
      final snackBar = tester.firstWidget(find.byType(SnackBar)) as SnackBar;
      expect(snackBar.backgroundColor, equals(COLOR_INFO)); // Ensure you have defined COLOR_SUCCESS
    });

    testWidgets('shows success snack bar', (WidgetTester tester) async {
      final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          key: scaffoldKey,
          body: Builder(
            builder: (BuildContext context) {
              return ElevatedButton(
                onPressed: () {
                  ComponentUtils.getSnackBarSuccess(context, "Operation Successful");
                },
                child: const Text('Show Snackbar'),
              );
            },
          ),
        ),
      ));

      // Tap the button to show the snackbar
      await tester.tap(find.text('Show Snackbar'));
      await tester.pump(); // Rebuild the widget

      // Expect a SnackBar to appear with specific text
      expect(find.text('Operation Successful'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);

      // You can also check for color if needed
      final snackBar = tester.firstWidget(find.byType(SnackBar)) as SnackBar;
      expect(
          snackBar.backgroundColor, equals(COLOR_SUCCESS)); // Ensure you have defined COLOR_SUCCESS
    });
  });
}
