import 'package:flutter/material.dart';
import 'package:notes/components/componentUtils.dart';
import 'package:notes/components/dialogs/deleteDialog.dart';
import 'package:notes/components/dialogs/textFieldDialog.dart';
import 'package:notes/components/fileListViewTile.dart';
import 'package:notes/model/myTreeNode.dart';
import 'package:notes/services/nodeService.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:developer';

class FileListView extends StatefulWidget {
  final String nodeId;

  final void Function(bool, String) navigateWithParam;

  const FileListView({
    super.key,
    required this.nodeId,
    required this.navigateWithParam,
  });

  @override
  State<FileListView> createState() => _FileListViewState();
}

class _FileListViewState extends State<FileListView> {
  final _textDialogController = TextEditingController();
  List<MyTreeNode> children = [];
  final utils = ComponentUtils();
  NodeService service = NodeService();

  @override
  void initState() {
    MyTreeNode? node = service.getNode(widget.nodeId);
    log("$node");
    if (node != null) {
      children = node.children;
    }
    super.initState();
  }

  @override
  void dispose() {
    _textDialogController.dispose();
    super.dispose();
  }

  void showDeleteDialog(MyTreeNode node) {
    showDialog(
        context: context,
        builder: (context) {
          return DeleteDialog(
            titleText: AppLocalizations.of(context)!.deleteNode(node.title),
            contentText:
                AppLocalizations.of(context)!.deleteContent(node.title),
            onDelete: () => deleteNode(node),
            onCancel: () => Navigator.of(context).pop(),
          );
        });
  }

  void showRenameDialog(MyTreeNode node) {
    showDialog(
        context: context,
        builder: (context) {
          return TextFieldDialog(
              titleText: AppLocalizations.of(context)!.renameNode(node.title),
              confirmButtonText: AppLocalizations.of(context)!.rename,
              controller: _textDialogController,
              onConfirm: () => renameNode(node),
              onCancel: () => closeAndClear());
        });
  }

  void showCreateDialog(MyTreeNode node, bool isNote) {
    showDialog(
        context: context,
        builder: (context) {
          return TextFieldDialog(
              titleText: isNote ? "Nová poznámka" : "Nová složka",
              confirmButtonText: AppLocalizations.of(context)!.create,
              controller: _textDialogController,
              onConfirm: () => createNode(node, isNote),
              onCancel: () => closeAndClear());
        });
  }

  void closeAndClear() {
    Navigator.of(context).pop();
    _textDialogController.clear();
  }

  void deleteNode(MyTreeNode node) {
    Navigator.of(context).pop();
    setState(() {
      service.deleteNode(node, service.getParent(node.id)!);
    });
  }

  void renameNode(MyTreeNode node) {
    setState(() {
      if (service.renameNode(node, _textDialogController.text.trim())) {
        closeAndClear();
      }
    });
  }

  void createNode(MyTreeNode node, bool isNote) {
    setState(() {
      if (service.createNewNode(
          node, _textDialogController.text.trim(), isNote)) {
        closeAndClear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return children.isEmpty
        ? Text(
            "Složka je prázdná",
            style: utils.getBasicTextStyle(),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(7),
            itemCount: children.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(1),
                child: FileListViewTile(
                  node: children[index],
                  touch: () => widget.navigateWithParam(
                    children[index].isNote,
                    children[index].id,
                  ),
                  delete: () => showDeleteDialog(children[index]),
                  rename: () => showRenameDialog(children[index]),
                  createNote: () => showCreateDialog(children[index], true),
                  createFile: () => showCreateDialog(children[index], false),
                ),
              );
            });
  }
}
