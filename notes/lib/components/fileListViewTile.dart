import 'package:flutter/material.dart';
import 'package:notes/components/componentUtils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FileListViewTile extends StatelessWidget {
  final bool isNote;
  final String fileName;
  final utils = ComponentUtils();

  FileListViewTile({super.key, required this.isNote, required this.fileName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(isNote ? Icons.article : Icons.folder),
          const SizedBox(width: 10.0),
          Expanded(
            child: Text(
              fileName,
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
                value: 'delete',
                child: Text(AppLocalizations.of(context)!.menuDelete),
              ),
              PopupMenuItem<String>(
                value: 'rename',
                child: Text(AppLocalizations.of(context)!.menuRename),
              ),
              PopupMenuItem<String>(
                value: 'create',
                child: Text(AppLocalizations.of(context)!.menuCreate),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
