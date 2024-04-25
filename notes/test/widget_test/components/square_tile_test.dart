import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes/components/components.dart';

void main() {
  testWidgets('SquareTile widget test', (WidgetTester tester) async {
    const String testImagePath = 'assets/google.png';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SquareTile(
            imagePath: testImagePath,
            onTap: () {},
          ),
        ),
      ),
    );

    // Verify that the SquareTile widget renders correctly
    expect(find.byType(Container), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });
}
