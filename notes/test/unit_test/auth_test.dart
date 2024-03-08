import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:notes/firebase_options.dart';
import 'package:notes/services/authentificationService.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notes/services/firebaseService.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_core/firebase_core.dart';

//class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockFirebaseService extends Mock implements FirebaseService {}

class MockUserCredential extends Mock implements UserCredential {}

class MockAppLocalizations extends Mock implements AppLocalizations {}

class MockBuildContext extends Mock implements BuildContext {}

void main() {
  //final MockFirebaseService mockFirebaseService = MockFirebaseService();
  //final MockFire
  //final MockFirebaseAuth mockFirebaseAuth = MockFirebaseAuth();
  //final AuthentificationService authService = AuthentificationService();
  //final MockUserCredential mockUserCredential = MockUserCredential();
  final MockAppLocalizations mockLocalizations = MockAppLocalizations();
  final MockBuildContext mockBuildContext = MockBuildContext();
  late MockFirebaseAuth mockFirebaseAuth;
  late AuthentificationService authService;
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  });
  // Before every test
  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth(signedIn: true);
    authService = AuthentificationService();
  });
  // After every test
  tearDown(() {});

  /*test("Creating account", () async {
    when(
      mockFirebaseAuth.createUserWithEmailAndPassword(
          email: "test@gmail.com", password: "test123"),
    ).thenAnswer((realInvocation) async => mockUserCredential);

    var result = await authService.register("test@gmail.com", "test123");

    expect(result, isInstanceOf<UserCredential>());
  });

  test("Creating account exception", () async {
    when(
      mockFirebaseAuth.createUserWithEmailAndPassword(
          email: "aaaaa", password: "sejondfnhsif"),
    ).thenAnswer(
        (realInvocation) => throw FirebaseAuthException(code: 'error'));

    expect(await authService.register("aaaaa", "sejondfnhsif"), 'error');
  });*/

  group('Converting to human redable error', () {
    test("Simple password", () {
      when(mockLocalizations.invalidEmail)
          .thenReturn("The email address is invalid.");

      expect(authService.getErrorMessage('invalid-email', mockBuildContext),
          "The email address is invalid.");
    });
  });
}
