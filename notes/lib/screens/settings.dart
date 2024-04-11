import 'package:flutter/material.dart';
import 'package:notes/components/componentUtils.dart';
import 'package:notes/components/dialogs/aboutAppDialog.dart';
import 'package:notes/components/dialogs/deleteDialog.dart';
import 'package:notes/data/clearDatabase.dart';
import 'package:notes/data/userDatabase.dart';
import 'package:notes/logger.dart';
import 'package:notes/main.dart';
import 'package:notes/model/language.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notes/screens/conflict.dart';
import 'package:notes/screens/logs.dart';

/// A [SettingsPage] widget that provides an interface for application settings.
///
/// This page allows users to configure various settings for the application, including
/// language selection, data management, and log viewing or deletion. It leverages
/// the [UserDatabase] and [ClearDatabase] for data-related operations and uses
/// [ComponentUtils] for consistent styling across its UI components.
///
/// Features:
/// - Language Selection: Lets the user change the application's language using a
///   dropdown menu populated with available [Language] options.
/// - Delete Application Data: Provides an option to delete all user data stored by
///   the application.
/// - View Logs: Navigates to a screen where the user can view application logs.
/// - Delete Logs: Offers an option to delete all application logs.
///
/// Usage:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(builder: (context) => const SettingsPage()),
/// );
/// ```
///
/// The settings are presented in a list, with each option followed by an action, such as
/// a button to trigger the corresponding functionality. Confirmation dialogs are used for
/// actions that may result in data loss, ensuring that the user has a chance to cancel
/// the action if it was selected by mistake.
class SettingsPage extends StatefulWidget {
  final VoidCallback onCleanDataAction;

  const SettingsPage({super.key, required this.onCleanDataAction});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  UserDatabase userDB = UserDatabase();
  ClearDatabase clearDB = ClearDatabase();
  ComponentUtils utils = ComponentUtils();
  bool isSwitched = false;

  void clearData() {
    clearDB.clearAllData();
    Navigator.of(context).pop();
    widget.onCleanDataAction();
    utils.getSnackBarSuccess(context, AppLocalizations.of(context)!.deleteDataSuccess);
  }

  void clearLogs() async {
    await AppLogger.deleteLogFile();
    AppLogger.createLogFileIfNotExist();
    Navigator.of(context).pop();
    utils.getSnackBarSuccess(context, AppLocalizations.of(context)!.clearLogsSuccess);
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
                              titleText: AppLocalizations.of(context)!.deleteAppDataDialogTitle,
                              contentText: AppLocalizations.of(context)!.deleteAppDataDialogContent,
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
                      AppLocalizations.of(context)!.showConflicts,
                      style: utils.getBasicTextStyle(),
                    ),
                  ),
                  SizedBox(
                    width: 130,
                    child: FilledButton(
                      style: utils.getButtonStyle(),
                      onPressed: () {
                        Navigator.push(
                            context, MaterialPageRoute(builder: (context) => const Conflict()));
                      },
                      child: Text(AppLocalizations.of(context)!.show),
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
                            context, MaterialPageRoute(builder: (context) => const LogScreen()));
                      },
                      child: Text(AppLocalizations.of(context)!.show),
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
                      AppLocalizations.of(context)!.deleteLogs,
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
                              titleText: AppLocalizations.of(context)!.deleteLogs,
                              contentText: AppLocalizations.of(context)!.deleteLogsContent,
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
                      AppLocalizations.of(context)!.darkMode,
                      style: utils.getBasicTextStyle(),
                    ),
                  ),
                  Switch(
                    value: isSwitched,
                    onChanged: (value) {
                      // This is called when the user toggles the switch.
                      setState(() {
                        // Update the state of the switch.
                        isSwitched = value;
                      });
                    },
                    // Colors for the Switch when it's on and off.
                    activeColor: Theme.of(context).primaryColor,
                    inactiveThumbColor: Theme.of(context).primaryColor,
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
                      AppLocalizations.of(context)!.aboutApp,
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
                            return AboutAppDialog(
                              onClose: () {
                                Navigator.of(context).pop();
                              },
                            );
                          },
                        );
                      },
                      child: Text(AppLocalizations.of(context)!.show),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
