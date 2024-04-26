part of screens;

/// A StatefulWidget that provides a user interface for logging in.
///
/// This page allows users to enter their email and password to log in to their account.
/// It utilizes Firebase Authentication for secure login functionality and provides
/// feedback in case of errors such as incorrect email or password. This widget can be
/// used in any part of the application where user authentication is required.
///
/// ## Parameters:
/// - `auth`: An instance of [FirebaseAuth] used for handling user authentication processes.
///   This is required to facilitate the login operations.
/// - `firestore`: An instance of [FirebaseFirestore], included here for potential future use,
///   such as logging audit data or reading user settings post-login.
/// - `onTap`: A callback that is triggered when the user taps on the 'Create Account' text.
///   This should typically be used to navigate the user to a registration or sign-up page.
/// - `loginSuccess`: A callback that is executed when the user successfully logs in.
///   This can be used to navigate the user to a different part of the application, such as the homepage or dashboard.
///
/// ## Example Usage:
/// ```dart
/// LoginPage(
///   auth: FirebaseAuth.instance,
///   firestore: FirebaseFirestore.instance,
///   onTap: () {
///     Navigator.push(context, MaterialPageRoute(builder: (context) => RegistrationPage()));
///   },
///   loginSuccess: () {
///     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
///   },
/// )
/// ```
class LoginPage extends StatefulWidget {
  /// Instance of [FirebaseAuth] for handling user authentication processes.
  final FirebaseAuth auth;

  /// Instance of [FirebaseFirestore] for database interactions, included for potential future use.
  final FirebaseFirestore firestore;

  /// A callback function that is triggered when the user taps on the 'Create Account' text.
  ///
  /// This function can be used to navigate the user to the registration page.
  final void Function()? onTap;

  /// Callback function that is called when the login process succeeds.
  final VoidCallback loginSuccess;

  /// Constructor of a [LoginPage].
  ///
  /// - `auth`: The [FirebaseAuth] instance for managing authentication.
  /// - `firestore`: The [FirebaseFirestore] instance for handling database operations.
  /// - `onTap`: A callback for when the user chooses to navigate to the registration page.
  /// - `loginSuccess`: A callback for when the login process successfully completes.
  const LoginPage({
    super.key,
    required this.auth,
    required this.firestore,
    required this.onTap,
    required this.loginSuccess,
  });

  @override
  State<LoginPage> createState() => _LoginFormState();
}

/// Manages the state and interactions for [LoginPage].
///
/// This state class handles user authentication, leveraging Firebase Authentication services,
/// and manages text input for user credentials. It also communicates with a Firestore service
/// for additional user data management post-login.
class _LoginFormState extends State<LoginPage> {
  /// Instance of [FirebaseAuth] for handling user authentication processes.
  late final AuthService _authService;

  /// Instance of [FirebaseFirestore] for database interactions, included for potential future use.
  late final FirestoreService _firebaseService;

  /// Controller for the email input field.
  final emailController = TextEditingController();

  /// Controller for the password input field.
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _authService = AuthService(
      auth: widget.auth,
      localizationProvider: (BuildContext context) => AppLocalizations.of(context)!,
    );
    _firebaseService = FirestoreService(auth: widget.auth, fireStore: widget.firestore);
  }

  /// Cleans up the controllers when the widget is removed from the widget tree.
  ///
  /// This method prevents memory leaks by disposing of the TextEditingController
  /// instances when the LoginPage widget is disposed.
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  /// Attempts to log in the user using Firebase Authentication.
  ///
  /// This method is called when the user presses the login button. It uses the
  /// email and password from the text controllers to attempt a login via Firebase.
  /// If the login is successful, the user is navigated back to the main screen.
  /// Errors during the login process are logged for debugging purposes.
  void login() async {
    log('Loging user: ${emailController.text}, password: ${passwordController.text}');
    ComponentUtils.getProgressIndicator(context);
    try {
      await _authService.login(emailController.text.trim(), passwordController.text.trim());
      await _firebaseService.synchronize(context);
      widget.loginSuccess();
      // Pop the CircularProgressIndicator
      Navigator.pop(context);
      // Go back to the main screen
      Navigator.pop(context);
    } catch (errorCode) {
      String errorMessage = _authService.getErrorMessage(errorCode.toString(), context);
      // Pop the CircularProgressIndicator
      Navigator.pop(context);
      log(errorMessage.toString());
      ComponentUtils.getSnackBarError(context, errorMessage.toString());
    }
  }

  /// Initiates a Google sign-in process using Firebase Authentication.
  ///
  /// This method attempts to log in the user via their Google account. It displays a progress indicator while
  /// the sign-in process is ongoing. Upon successful authentication, it synchronizes data with Firestore and
  /// navigates the user back to the main screen. If an error occurs, it provides feedback to the user via a snack bar.
  ///
  /// The method handles errors by logging them and displaying an error message, ensuring the user is informed of any
  /// issues during the login process.
  void loginWithGoogle() async {
    ComponentUtils.getProgressIndicator(context);
    try {
      await _authService.signInWithGoogle();
      // Pop the CircularProgressIndicator
      await _firebaseService.synchronize(context);
      widget.loginSuccess;
      Navigator.pop(context);
      // Go back to the main screen
      Navigator.pop(context);
    } catch (errorCode) {
      String errorMessage = _authService.getErrorMessage(errorCode.toString(), context);
      // Pop the CircularProgressIndicator
      Navigator.pop(context);
      log(errorMessage.toString());
      ComponentUtils.getSnackBarError(context, errorMessage.toString());
    }
  }

  /// Builds the registration page UI.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.login,
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              children: [
                const Icon(
                  Icons.person,
                  size: 80,
                ),
                Text(
                  AppLocalizations.of(context)!.loginText,
                  style: const TextStyle(
                    fontSize: DEFAULT_TEXT_SIZE,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(
                  height: DEFAULT_GAP_SIZE,
                ),
                SizedBox(
                  width: MAX_WIDGET_WIDTH,
                  child: StyledTextField(
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
                  child: StyledTextField(
                    isPasswordField: true,
                    hint: AppLocalizations.of(context)!.password,
                    controller: passwordController,
                    pefIcon: const Icon(Icons.key),
                  ),
                ),
                const SizedBox(
                  height: SMALL_GAP,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.forgotPassword,
                      style: const TextStyle(
                        fontSize: DEFAULT_TEXT_SIZE,
                      ),
                    ),
                    const SizedBox(width: ROW_TEXT_GAP),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ResetPasswordPage(
                              auth: widget.auth,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        AppLocalizations.of(context)!.resetPassword,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          fontSize: DEFAULT_TEXT_SIZE,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: SMALL_GAP,
                ),
                SizedBox(
                  width: MAX_WIDGET_WIDTH,
                  child: StyledButton(
                    onTap: () {
                      login();
                    },
                    text: AppLocalizations.of(context)!.login,
                  ),
                ),
                const SizedBox(
                  height: SMALL_GAP,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.doNotHaveAccount,
                      style: const TextStyle(
                        fontSize: DEFAULT_TEXT_SIZE,
                      ),
                    ),
                    const SizedBox(width: ROW_TEXT_GAP),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text(
                        AppLocalizations.of(context)!.createAccount,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          fontSize: DEFAULT_TEXT_SIZE,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: SMALL_GAP,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: SizedBox(
                    width: MAX_WIDGET_WIDTH,
                    child: Row(
                      children: [
                        Expanded(
                          child: Divider(
                            thickness: 0.5,
                            color: Colors.grey[400],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(
                            AppLocalizations.of(context)!.googleSignDivider,
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            thickness: 0.5,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: DEFAULT_GAP_SIZE),
                Center(
                  child: SquareTile(
                    onTap: () => loginWithGoogle(),
                    imagePath: GOOGLE_AUTH_IMG,
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
