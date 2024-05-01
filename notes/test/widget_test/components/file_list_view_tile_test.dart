import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes/components/components.dart';
import 'package:notes/model/my_tree_node.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  testWidgets('FileListViewTile builds correctly and triggers callbacks',
      (WidgetTester tester) async {
    final MyTreeNode mockNode =
        MyTreeNode(id: '1', title: 'Test Node', isNote: false, isLocked: false);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: FileListViewTile(
          key: Key('fileListViewTile_${mockNode.id}'),
          node: mockNode,
          touch: () {},
          delete: () {},
          rename: () {},
          createNote: () {},
          createFile: () {},
          move: () {},
          lock: () {},
          unlock: () {},
        ),
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ));

    // Targeting the InkWell with a specific key
    await tester.tap(find.byKey(const Key('mainInkWell_1')));
    await tester.pump(); // Trigger a frame

    // Additional interactions if necessary
    // For example, to open and interact with a popup menu:
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle(); // Open the menu

    // Now tap on specific menu items by text
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle(); // Perform the action
  });
}
