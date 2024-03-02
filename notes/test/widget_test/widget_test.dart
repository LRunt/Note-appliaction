import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes/assets/constants.dart';
import 'package:notes/components/myButton.dart';
import 'package:notes/components/myTextField.dart';

void main() {
  group('MyButton Tests', () {
    testWidgets("MyButton displays correct text and react on tap",
        (WidgetTester tester) async {
      bool isTapped = false;

      //Define the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MyButton(
              text: "Tap Me",
              onTap: () {
                isTapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(MyButton));
      await tester.pump();

      expect(find.text('Tap Me'), findsOneWidget);
      expect(isTapped, true);
    });

    testWidgets('MyButton has the correct styles', (WidgetTester tester) async {
      //Define the widget
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MyButton(
            text: "Styled Button",
            onTap: () {},
          ),
        ),
      ));

      final textWidget = tester.widget<Text>(find.text('Styled Button'));
      expect(textWidget.style?.color, Colors.white);
      expect(textWidget.style?.fontWeight, FontWeight.bold);
      expect(textWidget.style?.fontSize, DEFAULT_TEXT_SIZE);
      final containerWidget = tester.widget<Container>(find.byType(Container));
      final decoration = containerWidget.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(BORDER_RADIUS));
    });
  });

  group('MyTextField Tests', () {
    testWidgets('textfield displays correct with given parameters',
        (WidgetTester tester) async {
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
    testWidgets('changes password visibility functionality',
        (WidgetTester tester) async {
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
