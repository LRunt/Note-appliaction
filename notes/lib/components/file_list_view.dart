part of components;

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
  final _textDialogController2 = TextEditingController();
  List<MyTreeNode> children = [];
  final utils = ComponentUtils();
  NodeService service = NodeService();
  late bool _visibleButtons;

  @override
  void initState() {
    _visibleButtons = false;
    MyTreeNode? node = service.getNode(widget.nodeId);
    log("$node");
    if (node != null) {
      children = node.children;
    }
    log("Reolading: $node");
    super.initState();
  }

  @override
  void dispose() {
    _textDialogController.dispose();
    super.dispose();
  }

  void _toggleButtons() {
    setState(() {
      _visibleButtons = !_visibleButtons;
    });
  }

  void showDeleteDialog(MyTreeNode node) {
    showDialog(
      context: context,
      builder: (context) {
        return DeleteDialog(
          titleText: AppLocalizations.of(context)!.deleteNode(node.title),
          contentText: AppLocalizations.of(context)!.deleteContent(node.title),
          onDelete: () => deleteNode(node),
          onCancel: () => Navigator.of(context).pop(),
        );
      },
    );
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
          onCancel: () => closeAndClear(),
          hint: AppLocalizations.of(context)!.renameHint,
        );
      },
    );
  }

  void showCreateDialog(MyTreeNode node, bool isNote) {
    showDialog(
      context: context,
      builder: (context) {
        return TextFieldDialog(
            titleText: isNote
                ? AppLocalizations.of(context)!.createNote
                : AppLocalizations.of(context)!.createFile,
            confirmButtonText: AppLocalizations.of(context)!.create,
            controller: _textDialogController,
            onConfirm: () => createNode(node, isNote),
            onCancel: () => closeAndClear(),
            hint: isNote
                ? AppLocalizations.of(context)!.newNoteHint
                : AppLocalizations.of(context)!.newDirectoryHint);
      },
    );
  }

  void showMoveDialog(MyTreeNode node) {
    String? selectedValue;
    List<String> files = service.getFoldersToMove(node);
    List<DropdownMenuItem<String>> dropdownItems = files.map(
      (String option) {
        return DropdownMenuItem<String>(
          value: option,
          child: Text(option),
        );
      },
    ).toList();
    showDialog(
      context: context,
      builder: (context) {
        return DropdownMenuDialog(
          onConfirm: () => moveNode(node, selectedValue),
          onCancel: () => Navigator.of(context).pop(),
          titleText: AppLocalizations.of(context)!.menuMove,
          confirmButtonText: AppLocalizations.of(context)!.move,
          items: dropdownItems,
          selectedValue: selectedValue,
          onSelect: (value) {
            selectedValue = value;
          },
        );
      },
    );
  }

  void showUnlockDialog(MyTreeNode node) {
    showDialog(
        context: context,
        builder: (context) {
          return EnterPasswordDialog(
              titleText: AppLocalizations.of(context)!.unlockNode(node.title),
              confirmButtonText: AppLocalizations.of(context)!.unlock,
              controller: _textDialogController,
              onConfirm: () => unlockNode(node),
              onCancel: () => closeAndClear());
        });
  }

  void showLockDialog(MyTreeNode node) {
    showDialog(
        context: context,
        builder: (context) {
          return CreatePasswordDialog(
            titleText: AppLocalizations.of(context)!.lockNode(node.title),
            confirmButtonText: AppLocalizations.of(context)!.lock,
            controller1: _textDialogController,
            controller2: _textDialogController2,
            onConfirm: () => lockNode(node),
            onCancel: () => closeAndClear(),
          );
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
    setState(
      () {
        if (service.renameNode(node, _textDialogController.text.trim(), context)) {
          closeAndClear();
        }
      },
    );
  }

  void createNode(MyTreeNode node, bool isNote) {
    setState(
      () {
        if (service.createNewNode(node, _textDialogController.text.trim(), isNote, context)) {
          closeAndClear();
          log("Creating node: $node");
          MyTreeNode? widgetNode = service.getNode(widget.nodeId);
          log("$widgetNode");
          if (widgetNode != null) {
            children = node.children;
          }
        }
      },
    );
  }

  void moveNode(MyTreeNode node, String? newParent) {
    setState(
      () {
        if (newParent != null) {
          service.moveNode(node, newParent, context);
          Navigator.of(context).pop();
        }
      },
    );
  }

  void unlockNode(MyTreeNode node) {
    setState(() {
      if (service.unlockNode(_textDialogController.text.trim(), node)) {
        closeAndClear();
      }
    });
  }

  void lockNode(MyTreeNode node) {
    setState(() {
      if (service.lockNode(_textDialogController.text.trim(), node)) {
        closeAndClear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: children.isEmpty
          ? Column(
              children: [
                if (!service.isRoot(widget.nodeId))
                  Padding(
                    padding: const EdgeInsets.all(7),
                    child: FileListViewTile(
                      node: null,
                      touch: () => widget.navigateWithParam(
                        false,
                        service.getParentPath(widget.nodeId),
                      ),
                      delete: () {},
                      rename: () {},
                      createNote: () {},
                      createFile: () {},
                      move: () {},
                      lock: () {},
                      unlock: () {},
                    ),
                  ),
                Center(
                  child: Text(
                    AppLocalizations.of(context)!.emptyFile,
                    style: utils.getBasicTextStyle(),
                  ),
                ),
              ],
            )
          : Padding(
              padding: const EdgeInsets.all(7),
              child: Align(
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!service.isRoot(widget.nodeId))
                        FileListViewTile(
                          node: null,
                          touch: () => widget.navigateWithParam(
                            false,
                            service.getParentPath(widget.nodeId),
                          ),
                          delete: () {},
                          rename: () {},
                          createNote: () {},
                          createFile: () {},
                          move: () {},
                          lock: () {},
                          unlock: () {},
                        ),
                      ListView.builder(
                        itemCount: children.length,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
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
                              move: () => showMoveDialog(children[index]),
                              lock: () => showLockDialog(children[index]),
                              unlock: () => showUnlockDialog(children[index]),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (!_visibleButtons)
            FloatingActionButton(
              onPressed: () {
                _toggleButtons();
              },
              child: const Icon(Icons.add),
            ),
          if (_visibleButtons)
            FloatingActionButton(
              onPressed: () {
                showCreateDialog(service.getNode(widget.nodeId)!, true);
              },
              tooltip: AppLocalizations.of(context)!.createNote,
              child: const Icon(Icons.article),
            ),
          if (_visibleButtons) const SizedBox(height: 16.0),
          if (_visibleButtons)
            FloatingActionButton(
              onPressed: () {
                showCreateDialog(service.getNode(widget.nodeId)!, false);
              },
              tooltip: AppLocalizations.of(context)!.createFile,
              child: const Icon(Icons.create_new_folder),
            ),
          if (_visibleButtons) const SizedBox(height: 16.0),
          if (_visibleButtons)
            FloatingActionButton(
              onPressed: () {
                _toggleButtons();
              },
              backgroundColor: Colors.red[300],
              child: const Icon(
                Icons.close,
                color: Color.fromARGB(255, 183, 28, 28),
              ),
            ),
        ],
      ),
    );
  }
}
