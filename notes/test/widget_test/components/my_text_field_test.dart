import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes/components/myTextField.dart';

void main() {
  group('MyTextField Tests', () {
    testWidgets('textfield displays correct with given parameters', (WidgetTester tester) async {
      final controller = TextEditingController();

      //Define the widget
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MyTextField(
            isPasswordField: false,
            hint: 'Enter text',
            controller: controller,
            pefIcon: const Icon(Icons.email),
          ),
        ),
      ));

      // Check if MyTextField renders with the correct hint text and icon
      expect(find.text('Enter text'), findsOneWidget);
      expect(find.byIcon(Icons.email), findsOneWidget);
    });

    // Test for password visibility toggle functionality
    testWidgets('changes password visibility functionality', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MyTextField(
            isPasswordField: true,
            hint: 'Password',
            controller: controller,
            pefIcon: const Icon(Icons.key),
          ),
        ),
      ));

      // password is no visible
      expect(find.byIcon(Icons.visibility), findsOneWidget);
      // changing password visibility
      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pump();
      // password is visible
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });
  });
}
