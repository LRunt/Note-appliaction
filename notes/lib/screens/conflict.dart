part of screens;

/// A StatelessWidget that displays a screen for managing conflicts.
///
/// This screen is part of the application's screens and includes an AppBar
/// and a body that contains a scrollable view of a tree structure representing conflicts.
/// The tree structure is managed by the `ConflictTree` widget.
///
/// Usage:
/// ```dart
/// Conflict()
/// ```
///
/// This widget relies on `AppLocalizations` to fetch localized content,
/// specifically the title of the conflicts page.
class Conflict extends StatelessWidget {
  /// Constructor of the [Conflict].
  ///
  /// - [key] a widget key for this StatelessWidget.
  const Conflict({super.key});

  /// Builds the UI of the conflict page.
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
