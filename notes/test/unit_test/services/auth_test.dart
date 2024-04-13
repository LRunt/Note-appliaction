import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notes/assets/constants.dart';
import 'package:notes/services/services.dart';

class MockBuildContext extends Mock implements BuildContext {}

class MockUserCredential extends Mock implements UserCredential {}

class MockAppLocalizations extends Mock implements AppLocalizations {
  @override
  String get invalidEmail => 'Wrong format of email';
  @override
  String get fieldsAreNotFilled => "One or more fields are not filled!";
  @override
  String get userNotFound => "No user found with that email";
  @override
  String get weakPassword => 'Password is too short. Password must have at least 6 chars.';
  @override
  String get wrongPassword => "Wrong password";
  @override
  String get invalidCreditial => "Wrong email or password";
  @override
  String get networkRequestFailed => "No internet connection";
  @override
  String get accountWithEmailExists => "An account already exists for that email";
  @override
  String get googleSignFailed => "Google sign in failed";
}

class MockFirebaseAuth extends Mock implements FirebaseAuth {
  @override
  Future<void> signOut() =>
      super.noSuchMethod(Invocation.method(#signOut, []), returnValue: Future<void>.value());

  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String? email,
    required String? password,
  }) =>
      super.noSuchMethod(Invocation.method(#createUserWithEmailAndPassword, [email, password]),
          returnValue: Future.value(MockUserCredential()));

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String? email,
    required String? password,
  }) =>
      super.noSuchMethod(Invocation.method(#signInWithEmailAndPassword, [email, password]),
          returnValue: Future.value(MockUserCredential()));

  @override
  Future<void> sendPasswordResetEmail({String? email, ActionCodeSettings? actionCodeSettings}) =>
      super.noSuchMethod(Invocation.method(#sendPasswordResetEmail, [email, actionCodeSettings]),
          returnValue: Future<void>.value());
}

class MockGoogleSignIn extends Mock implements GoogleSignIn {
  @override
  Future<GoogleSignInAccount?> signIn() => super.noSuchMethod(Invocation.method(#signIn, []),
      returnValue: Future.value(MockGoogleSignInAccount()));

  @override
  Future<GoogleSignInAccount?> signOut() =>
      super.noSuchMethod(Invocation.method(#signOut, []), returnValue: Future.value(null));

  @override
  Future<GoogleSignInAccount?> signInSilently(
          {bool suppressErrors = false, bool reAuthenticate = false}) =>
      super.noSuchMethod(
          Invocation.method(#signInSilently, [],
              {#suppressErrors: suppressErrors, #reAuthenticate: reAuthenticate}),
          returnValue: Future.value(MockGoogleSignInAccount()));

  @override
  dynamic noSuchMethod(Invocation invocation,
          {Object? returnValue, Object? returnValueForMissingStub}) =>
      super.noSuchMethod(invocation,
          returnValue: returnValue ?? Future.value(null),
          returnValueForMissingStub: returnValueForMissingStub);
}

// ignore: must_be_immutable
class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockGoogleSignInAuthentication extends Mock implements GoogleSignInAuthentication {
  @override
  String? get idToken => 'fakeId';

  @override
  String? get accessToken => 'fakeToken';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockBuildContext mockContext;
  late MockAppLocalizations mockLocalizations;
  late MockFirebaseAuth mockAuth;
  late MockUserCredential mockUserCreditial;
  late AuthService authService;
  late MockGoogleSignIn mockGoogleSignIn;

  setUp(() {
    mockContext = MockBuildContext();
    mockLocalizations = MockAppLocalizations();
    mockAuth = MockFirebaseAuth();
    mockUserCreditial = MockUserCredential();
    mockGoogleSignIn = MockGoogleSignIn();
    authService = AuthService(
      auth: mockAuth,
      localizationProvider: (_) => mockLocalizations,
    );

    when(mockGoogleSignIn.signInSilently(suppressErrors: true))
        .thenAnswer((_) => Future.value(null));

    // Create a new MethodChannel with the same name used by GoogleSignIn.
    const MethodChannel channel = MethodChannel('plugins.flutter.io/google_sign_in');

    // Set up a mock method call handler.
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'init') {
        return null;
      }
      if (methodCall.method == 'signIn') {
        return {
          'displayName': 'Mock User',
          'email': 'mockuser@example.com',
          'id': '12345',
          'photoUrl': 'mockphoto.jpg',
          'idToken': 'mock_id_token',
          'accessToken': 'mock_access_token',
        };
      }
      if (methodCall.method == 'signInSilently') {
        return null;
      }
      if (methodCall.method == 'signOut') {
        return null;
      }
      return null;
    });
  });

  group('AuthService tests', () {
    group('register tests', () {
      test('Registration - simple test (succesfull)', () async {
        const String email = "test@gmail.com";
        const String password = "password123";
        when(mockAuth.createUserWithEmailAndPassword(email: email, password: password))
            .thenAnswer((realInvocation) => Future.value(mockUserCreditial));

        final result = await authService.register(email, password);
        expect(result, mockUserCreditial);
      });

      test('Registration - registration failed', () async {
        const String email = "test@gmail.com";
        const String password = "paswrod123";
        final FirebaseAuthException exception = FirebaseAuthException(code: "auth-error");

        when(mockAuth.createUserWithEmailAndPassword(email: email, password: password))
            .thenThrow(exception);

        expect(() async => await authService.register(email, password), throwsA(isA<String>()));
      });
    });

    group('login tests', () {
      test('Login - simple test (succesfull)', () async {
        const String email = "test@gmail.com";
        const String password = "password123";
        when(mockAuth.signInWithEmailAndPassword(email: email, password: password))
            .thenAnswer((realInvocation) => Future.value(mockUserCreditial));

        final result = await authService.login(email, password);
        expect(result, mockUserCreditial);
      });

      test('Login - login failed', () async {
        const String email = "test@gmail.com";
        const String password = "paswrod123";
        final FirebaseAuthException exception = FirebaseAuthException(code: "auth-error");

        when(mockAuth.signInWithEmailAndPassword(email: email, password: password))
            .thenThrow(exception);

        expect(() async => await authService.login(email, password), throwsA(isA<String>()));
      });
    });

    group('logout tests', () {
      test('logout - simple test', () async {
        when(mockGoogleSignIn.signOut())
            .thenAnswer((_) => Future<GoogleSignInAccount?>.value(null));
        when(mockAuth.signOut()).thenAnswer((_) => Future<void>.value());

        expect(await authService.logout(), SUCCESS);
      });

      test('logout - FirebaseAuthException', () async {
        when(mockGoogleSignIn.signOut())
            .thenAnswer((_) => Future<GoogleSignInAccount?>.value(null));
        when(mockAuth.signOut())
            .thenThrow(FirebaseAuthException(code: "auth-error", message: "Sign out failed"));

        expect(await authService.logout(), equals("auth-error"));
      });
    });

    group('password reset', () {
      test('Password reset - simple test', () async {
        // Arrange
        when(mockAuth.sendPasswordResetEmail(email: "test@gmail.com"))
            .thenAnswer((_) => Future<void>.value());

        // Act & Assert
        expect(await authService.resetPassword("test@gmail.com"), isTrue);
      });
    });

    group('getErrorMessage tests', () {
      test('invalid-email error message', () {
        expect(authService.getErrorMessage('invalid-email', mockContext), 'Wrong format of email');
      });
      test('channel-error error message', () {
        expect(authService.getErrorMessage('channel-error', mockContext),
            'One or more fields are not filled!');
      });
      test('user-not-found error message', () {
        expect(authService.getErrorMessage('user-not-found', mockContext),
            'No user found with that email');
      });
      test('wrong-password error message', () {
        expect(authService.getErrorMessage('wrong-password', mockContext), 'Wrong password');
      });
      test('invalid-credential error message', () {
        expect(authService.getErrorMessage('invalid-credential', mockContext),
            'Wrong email or password');
      });
      test('network-request-failed error message', () {
        expect(authService.getErrorMessage('network-request-failed', mockContext),
            'No internet connection');
      });
      test('weak-password error message', () {
        expect(authService.getErrorMessage('weak-password', mockContext),
            'Password is too short. Password must have at least 6 chars.');
      });
      test('email-already-in-use error message', () {
        expect(authService.getErrorMessage('email-already-in-use', mockContext),
            'An account already exists for that email');
      });
      test('google-sing-error error message', () {
        expect(
            authService.getErrorMessage('google-sign-error', mockContext), "Google sign in failed");
      });
      test('default error message', () {
        expect(authService.getErrorMessage('not-known-error', mockContext), 'not-known-error.');
      });
    });
  });
}
