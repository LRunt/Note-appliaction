part of screens;

/// A stateless widget that displays a web view for a specified URL.
///
/// The `ManualScreen` widget creates a Scaffold containing an AppBar and a WebView.
/// It is designed to display a user manual or other web content directly within
/// the app. The content is loaded from the URL provided to the `urlAddress` parameter.
///
/// This screen is particularly useful for displaying web-based manuals or help documents
/// without leaving the app context. The `WebView` loads the specified URL and allows
/// unrestricted JavaScript execution to support interactive web pages.
///
/// ## Parameters:
/// - `urlAddress`: The URL that will be loaded in the WebView. It must be a valid
///   web URL and required to ensure the WebView can render content as expected.
///
/// ## Usage Example:
/// ```dart
/// ManualScreen(urlAddress: 'https://www.example.com/manual')
/// ```
class ManualScreen extends StatelessWidget {
  /// The URL to be loaded when the WebView is initialized.
  final String urlAddress;

  /// Constructor of [ManualScreen]
  ///
  /// Requires one positional parameter:
  /// - `urlAddress` is the web URL to load in the WebView.
  const ManualScreen({
    super.key,
    required this.urlAddress,
  });

  /// Builds the page with manual.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.manualTitle),
      ),
      body: WebView(
        initialUrl: urlAddress,
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
