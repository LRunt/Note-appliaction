import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:notes/services/authentificationService.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUserCredential extends Mock implements UserCredential {}

void main() {
  final MockFirebaseAuth mockFirebaseAuth = MockFirebaseAuth();
  final AuthentificationService authService = AuthentificationService();
  final MockUserCredential mockUserCredential = MockUserCredential();
  // Before every test
  setUp(() {});
  // After every test
  tearDown(() {});

  test("Creating account", () async {
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
  });
}
