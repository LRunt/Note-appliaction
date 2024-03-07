import 'package:flutter/material.dart';
import 'package:notes/components/componentUtils.dart';
import 'package:notes/components/dialogs/deleteDialog.dart';
import 'package:notes/data/clearDatabase.dart';
import 'package:notes/data/userDatabase.dart';
import 'package:notes/logger.dart';
import 'package:notes/main.dart';
import 'package:notes/model/language.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notes/screens/logs.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  UserDatabase userDB = UserDatabase();
  ClearDatabase clearDB = ClearDatabase();
  ComponentUtils utils = ComponentUtils();

  void clearData() {
    clearDB.clearAllData();
    Navigator.of(context).pop();
    utils.getSnackBarSuccess(context, "Data úspěšně smazána");
  }

  void clearLogs() async {
    await AppLogger.deleteLogFile();
    AppLogger.createLogFileIfNotExist();
    Navigator.of(context).pop();
    utils.getSnackBarSuccess(context, "Logy byly úspěšně smazány");
  }

  Language? actualLanguage() {
    Locale actualLocale = Localizations.localeOf(context);
    return Language.getByLangCode(actualLocale.languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.language,
                      style: utils.getBasicTextStyle(),
                    ),
                  ),
                  DropdownButton<Language>(
                    value: actualLanguage(),
                    items: Language.languageList()
                        .map(
                          (e) => DropdownMenuItem(
                              value: e,
                              child: Row(
                                children: [
                                  Text(
                                    e.flag,
                                    style: const TextStyle(fontSize: 30),
                                  ),
                                  const SizedBox(width: 10.0),
                                  Text(e.name)
                                ],
                              )),
                        )
                        .toList(),
                    onChanged: (Language? language) {
                      if (language != null) {
                        MyApp.setLocale(context, Locale(language.langCode));
                        userDB.saveLocale(language.langCode);
                      }
                    },
                  ),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.deleteApplicationData,
                      style: utils.getBasicTextStyle(),
                    ),
                  ),
                  SizedBox(
                    width: 130,
                    child: FilledButton(
                      style: utils.getButtonStyle(),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return DeleteDialog(
                              titleText: AppLocalizations.of(context)!
                                  .deleteAppDataDialogTitle,
                              contentText: AppLocalizations.of(context)!
                                  .deleteAppDataDialogContent,
                              onDelete: () {
                                clearData();
                              },
                              onCancel: () {
                                Navigator.of(context).pop();
                              },
                            );
                          },
                        );
                      },
                      child: Text(AppLocalizations.of(context)!.delete),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.logs,
                      style: utils.getBasicTextStyle(),
                    ),
                  ),
                  SizedBox(
                    width: 130,
                    child: FilledButton(
                      style: utils.getButtonStyle(),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LogScreen()));
                      },
                      child: Text(AppLocalizations.of(context)!.showLogs),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Clear logs",
                      style: utils.getBasicTextStyle(),
                    ),
                  ),
                  SizedBox(
                    width: 130,
                    child: FilledButton(
                      style: utils.getButtonStyle(),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return DeleteDialog(
                              titleText: "Smazání logů",
                              contentText:
                                  "Chystáte se smazat všechny logy aplikace",
                              onDelete: () {
                                clearLogs();
                              },
                              onCancel: () {
                                Navigator.of(context).pop();
                              },
                            );
                          },
                        );
                      },
                      child: const Text("Clear"),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
