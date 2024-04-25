import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes/constants.dart';
import 'package:notes/components/myButton.dart';

void main() {
  group('MyButton Tests', () {
    testWidgets("MyButton displays correct text and react on tap", (WidgetTester tester) async {
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
      expect(textWidget.style?.fontWeight, FontWeight.bold);
      expect(textWidget.style?.fontSize, DEFAULT_TEXT_SIZE);
      final containerWidget = tester.widget<Ink>(find.byType(Ink));
      final decoration = containerWidget.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(BORDER_RADIUS));
    });
  });
}
