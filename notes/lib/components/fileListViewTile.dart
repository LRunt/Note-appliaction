import 'package:flutter/material.dart';
import 'package:notes/components/componentUtils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notes/model/myTreeNode.dart';

class FileListViewTile extends StatelessWidget {
  final MyTreeNode? node;
  final utils = ComponentUtils();
  final VoidCallback touch;
  final VoidCallback delete;
  final VoidCallback rename;
  final VoidCallback createNote;
  final VoidCallback createFile;
  final VoidCallback move;

  FileListViewTile({
    super.key,
    required this.node,
    required this.touch,
    required this.delete,
    required this.rename,
    required this.createNote,
    required this.createFile,
    required this.move,
  });

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
        child: node != null
            ? Row(
                children: [
                  Icon(node!.isNote ? Icons.article : Icons.folder),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Text(
                      node!.title,
                      style: utils.getBasicTextStyle(),
                    ),
                  ),
                  PopupMenuButton<String>(
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        onTap: () => delete(),
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(Icons.delete),
                            const SizedBox(width: 4),
                            Text(AppLocalizations.of(context)!.menuDelete),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'rename',
                        onTap: () => rename(),
                        child: Row(
                          children: [
                            const Icon(Icons.border_color_sharp),
                            const SizedBox(width: 4),
                            Text(AppLocalizations.of(context)!.menuRename),
                          ],
                        ),
                      ),
                      if (!node!.isNote)
                        PopupMenuItem<String>(
                          value: 'create_node',
                          onTap: () => createNote(),
                          child: Row(
                            children: [
                              const Icon(Icons.article),
                              const SizedBox(width: 4),
                              Text(AppLocalizations.of(context)!.createFile),
                            ],
                          ),
                        ),
                      if (!node!.isNote)
                        PopupMenuItem<String>(
                          value: 'create_file',
                          onTap: () => createFile(),
                          child: Row(
                            children: [
                              const Icon(Icons.create_new_folder),
                              const SizedBox(width: 4),
                              Text(AppLocalizations.of(context)!.createNote),
                            ],
                          ),
                        ),
                      PopupMenuItem<String>(
                          value: 'move',
                          onTap: () => move(),
                          child: const Row(
                            children: [
                              Icon(Icons.move_down),
                              SizedBox(width: 4),
                              Text("Move"),
                            ],
                          ))
                    ],
                  ),
                ],
              )
            : Row(
                children: [
                  const Icon(Icons.drive_folder_upload_rounded),
                  const SizedBox(width: 10.0),
                  Text(AppLocalizations.of(context)!.toParentNode)
                ],
              ),
      ),
    );
  }
}
