import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notes/services/authentificationService.dart';

class MockBuildContext extends Mock implements BuildContext {}

class MockAppLocalizations extends Mock implements AppLocalizations {
  @override
  String get invalidEmail => 'Wrong format of email';
}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

void main() {
  late MockBuildContext mockContext;
  late MockAppLocalizations mockLocalizations;
  late MockFirebaseAuth mockAuth;
  late MockFirebaseFirestore mockFirestore;
  late AuthService authService;

  setUp(() {
    mockContext = MockBuildContext();
    mockLocalizations = MockAppLocalizations();
    mockAuth = MockFirebaseAuth();
    mockFirestore = MockFirebaseFirestore();
    authService = AuthService(
      auth: mockAuth,
      firestore: mockFirestore,
      localizationProvider: (_) => mockLocalizations,
    );
  });

  group('Converting error code to human-readable error', () {
    test("Invalid email error message", () {
      // Assuming getErrorMessage uses AppLocalizations.of(context) to retrieve localizations

      expect(authService.getErrorMessage('invalid-email', mockContext),
          'Wrong format of email');
    });
  });
}
