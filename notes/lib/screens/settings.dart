part of screens;

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
  /// Callback function to be executed after data is cleared.
  final VoidCallback onCleanDataAction;

  /// Constructor of the [SettingsPage] widget.
  ///
  /// Requires a [VoidCallback] parameter [onCleanDataAction] which is invoked
  /// after user data is cleared from the application.
  const SettingsPage({super.key, required this.onCleanDataAction});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

/// The State class for [SettingsPage] handling the logic and state of the settings UI.
class _SettingsPageState extends State<SettingsPage> {
  /// Database handler for user-related data operations.
  UserDatabase userDB = UserDatabase();

  /// Database handler for clearing all application data.
  ClearDatabase clearDB = ClearDatabase();

  /// Clears all user data from the application, notifies success, and invokes a callback.
  ///
  /// This method clears the application's data, returns to the previous screen, executes
  /// a callback to handle additional cleanup, and displays a success message via a SnackBar.
  void clearData() {
    clearDB.clearAllData();
    Navigator.of(context).pop();
    widget.onCleanDataAction();
    ComponentUtils.getSnackBarSuccess(context, AppLocalizations.of(context)!.deleteDataSuccess);
  }

  /// Returns the [Language] corresponding to the current locale's language code.
  ///
  /// Extracts the language code from the context's locale and retrieves the matching
  /// [Language] object. If no match is found, returns `null`.
  Language? actualLanguage() {
    Locale actualLocale = Localizations.localeOf(context);
    return Language.getByLangCode(actualLocale.languageCode);
  }

  // Builds the UI elements for the settings page including theme mode switcher and
  // data/log management options.
  @override
  Widget build(BuildContext context) {
    // Get the current theme mode from the provider
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isSwitched = themeProvider.themeMode == ThemeMode.dark ||
        (themeProvider.themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    void toggleTheme(bool isOn) {
      themeProvider.setThemeMode(isOn ? ThemeMode.dark : ThemeMode.light);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Divider(),
            //Language
            Padding(
              padding: const EdgeInsets.all(DEFAULT_PADDING),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.language,
                      style: defaultTextStyle,
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
            // Dark mode
            Padding(
              padding: const EdgeInsets.all(DEFAULT_PADDING),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.darkMode,
                      style: defaultTextStyle,
                    ),
                  ),
                  Switch(
                    value: isSwitched,
                    onChanged: (value) {
                      setState(() {
                        toggleTheme(value);
                      });
                    },
                  ),
                ],
              ),
            ),
            const Divider(),
            // Conflicts
            Padding(
              padding: const EdgeInsets.all(DEFAULT_PADDING),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.showConflicts,
                      style: defaultTextStyle,
                    ),
                  ),
                  SizedBox(
                    width: SETTINGS_BUTTON_SIZE,
                    child: FilledButton(
                      style: defaultButtonStyle,
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
              padding: const EdgeInsets.all(DEFAULT_PADDING),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.deleteApplicationData,
                      style: defaultTextStyle,
                    ),
                  ),
                  SizedBox(
                    width: SETTINGS_BUTTON_SIZE,
                    child: FilledButton(
                      style: defaultButtonStyle,
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
              padding: const EdgeInsets.all(DEFAULT_PADDING),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.aboutApp,
                      style: defaultTextStyle,
                    ),
                  ),
                  SizedBox(
                    width: SETTINGS_BUTTON_SIZE,
                    child: FilledButton(
                      style: defaultButtonStyle,
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
            const Divider(),
          ],
        ),
      ),
    );
  }
}
