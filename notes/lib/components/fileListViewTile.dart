import 'package:flutter/material.dart';
import 'package:notes/components/componentUtils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notes/model/myTreeNode.dart';

class FileListViewTile extends StatelessWidget {
  final MyTreeNode node;
  final utils = ComponentUtils();
  final VoidCallback touch;
  final VoidCallback delete;

  FileListViewTile(
      {super.key,
      required this.node,
      required this.touch,
      required this.delete});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => touch(),
      child: Ink(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(node.isNote ? Icons.article : Icons.folder),
            const SizedBox(width: 10.0),
            Expanded(
              child: Text(
                node.title,
                style: utils.getBasicTextStyle(),
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'delete':
                    break;
                  case 'rename':
                    break;
                  case 'create':
                    break;
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  onTap: () => delete(),
                  value: 'delete',
                  child: Row(children: [
                    const Icon(Icons.delete),
                    const SizedBox(width: 4),
                    Text(AppLocalizations.of(context)!.menuDelete)
                  ]),
                ),
                PopupMenuItem<String>(
                  value: 'rename',
                  child: Row(children: [
                    const Icon(Icons.edit),
                    const SizedBox(width: 4),
                    Text(AppLocalizations.of(context)!.menuRename)
                  ]),
                ),
                PopupMenuItem<String>(
                  value: 'create',
                  child: Row(children: [
                    const Icon(Icons.add),
                    const SizedBox(width: 4),
                    Text(AppLocalizations.of(context)!.menuCreate)
                  ]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
