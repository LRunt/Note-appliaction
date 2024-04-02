import 'package:flutter/material.dart';
import 'package:notes/components/conflictTree.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Conflict extends StatelessWidget {
  const Conflict({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.conflicts),
        ),
        body: const SingleChildScrollView(
          child: ConflictTree(),
        ));
  }
}
