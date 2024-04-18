part of screens;

/// A StatefulWidget that facilitates password reset functionality for users.
///
/// This page utilizes Firebase Authentication and Firestore to reset a user's password.
/// It provides a form where users can enter their email address to receive a password reset link.
///
/// Attributes:
/// - `auth`: An instance of [FirebaseAuth] used for authentication processes.
/// - `firestore`: An instance of [FirebaseFirestore] used for database interactions (not directly used here but included for potential extensions).
///
/// Usage:
/// This widget should be used in scenarios where the user needs to reset their forgotten password.
/// It is typically pushed onto the navigator stack when the user selects a "Forgot Password?" option.
///
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(builder: (context) => ResetPasswordPage(auth: FirebaseAuth.instance, firestore: FirebaseFirestore.instance)),
/// );
/// ```
class ResetPasswordPage extends StatefulWidget {
  /// Instance of [FirebaseAuth] for handling user authentication processes.
  final FirebaseAuth auth;

  /// Constructor of the [ResetPasswordPage] widget.
  ///
  /// Requires one positional argument:
  /// - [FirebaseAuth] - for handling user authentication processes.
  const ResetPasswordPage({
    super.key,
    required this.auth,
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordState();
}

/// State class for [ResetPasswordPage] handling the password reset logic.
class _ResetPasswordState extends State<ResetPasswordPage> {
  /// Service responsible for authentication operations.
  late final AuthService _authService;

  /// Controller for the email input field.
  final emailController = TextEditingController();

  /// Initiates the password reset process.
  ///
  /// This method attempts to reset the user's password via the authentication service
  /// using the email provided in the [emailController]. If successful, it navigates
  /// back and shows a success toast. In case of an error, it displays an error message
  /// using a SnackBar.
  void resetPassword() async {
    try {
      await _authService.resetPassword(emailController.text.trim());
      Navigator.pop(context);
      ComponentUtils.showDefaultToast(AppLocalizations.of(context)!.emailSentToast);
    } catch (errorCode) {
      String errorMessage = _authService.getErrorMessage(errorCode.toString(), context);
      ComponentUtils.getSnackBarError(context, errorMessage.toString());
    }
  }

  // Initializing the page
  @override
  void initState() {
    super.initState();
    _authService = AuthService(
      auth: widget.auth,
      localizationProvider: (BuildContext context) => AppLocalizations.of(context)!,
    );
  }

  // Dispose after closing
  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  // UI of the page.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.resetPasswordTitle),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: DEFAULT_PAGE_PADDING),
            child: Column(
              children: [
                const Icon(
                  Icons.lock_outline,
                  size: 80,
                ),
                Text(
                  AppLocalizations.of(context)!.forgotPassword,
                  style: const TextStyle(
                    fontSize: DEFAULT_TEXT_SIZE,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(AppLocalizations.of(context)!.resetInstructions),
                const SizedBox(
                  height: DEFAULT_GAP_SIZE,
                ),
                SizedBox(
                  width: MAX_WIDGET_WIDTH,
                  child: MyTextField(
                    isPasswordField: false,
                    hint: AppLocalizations.of(context)!.email,
                    controller: emailController,
                    pefIcon: const Icon(Icons.email),
                  ),
                ),
                const SizedBox(
                  height: DEFAULT_GAP_SIZE,
                ),
                SizedBox(
                  width: MAX_WIDGET_WIDTH,
                  child: MyButton(
                    onTap: () => resetPassword(),
                    text: AppLocalizations.of(context)!.sendResetEmail,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
