import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Service wrapper for Firebase Authentication using Email and Password.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Stream of authentication state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Get the currently signed in user.
  User? get currentUser => _auth.currentUser;

  /// Sign up a new user with [email] and [password].
  Future<UserCredential?> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint('AuthService SignUp Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('AuthService Unexpected SignUp Error: $e');
      rethrow;
    }
  }

  /// Sign in an existing user with [email] and [password].
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint('AuthService SignIn Error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('AuthService Unexpected SignIn Error: $e');
      rethrow;
    }
  }

  /// Send a password reset email to [email].
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      debugPrint('AuthService PasswordReset Error: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('AuthService SignOut Error: $e');
      rethrow;
    }
  }
}
