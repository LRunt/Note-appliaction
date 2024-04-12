import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes/assets/constants.dart';
import 'package:notes/components/componentUtils.dart';
import 'package:notes/components/myButton.dart';
import 'package:notes/components/myTextField.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notes/services/authService.dart';

class ResetPasswordPage extends StatefulWidget {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  const ResetPasswordPage({
    super.key,
    required this.auth,
    required this.firestore,
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPasswordPage> {
  late final AuthService _authService;
  final ComponentUtils utils = ComponentUtils();

  final emailController = TextEditingController();

  void resetPassword() async {
    try {
      await _authService.resetPassword(emailController.text.trim());
      Navigator.pop(context);
      utils.showDefaultToast(AppLocalizations.of(context)!.emailSentToast);
    } catch (errorCode) {
      String errorMessage = _authService.getErrorMessage(errorCode.toString(), context);
      utils.getSnackBarError(context, errorMessage.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    _authService = AuthService(
      auth: widget.auth,
      localizationProvider: (BuildContext context) => AppLocalizations.of(context)!,
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.resetPasswordTitle),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
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
                MyTextField(
                    isPasswordField: false,
                    hint: AppLocalizations.of(context)!.email,
                    controller: emailController,
                    pefIcon: const Icon(Icons.email)),
                const SizedBox(
                  height: DEFAULT_GAP_SIZE,
                ),
                MyButton(
                  onTap: () => resetPassword(),
                  text: AppLocalizations.of(context)!.sendResetEmail,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
