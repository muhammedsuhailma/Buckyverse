import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _webClientId =
      '315420119841-nf46f5jc1bo8joo7r673kls52drm4oql.apps.googleusercontent.com';

  /// Create Firestore document for new users without blocking authentication
  Future<void> _createUserDocument(User user) async {
    try {
      final doc = _firestore.collection('users').doc(user.uid);

      final snapshot = await doc.get().timeout(
        const Duration(seconds: 5),
      );

      if (!snapshot.exists) {
        await doc.set({
          'username': user.displayName ?? '',
          'email': user.email ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        }).timeout(const Duration(seconds: 5));
      }
    } catch (e) {
      debugPrint("⚠️ Firestore user document creation warning: $e");
      // Auth continues even if user profile document creation times out or fails
    }
  }

  /// Google Sign In
  Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      serverClientId: _webClientId,
    );

    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      return null;
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    if (googleAuth.idToken == null && googleAuth.accessToken == null) {
      throw FirebaseAuthException(
        code: 'google-sign-in-failed',
        message: 'Failed to obtain Google authentication tokens.',
      );
    }

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);

    if (userCredential.user != null) {
      // Fire-and-forget user document creation so auth doesn't hang
      unawaited(_createUserDocument(userCredential.user!));
    }

    return userCredential;
  }

  /// Email Sign Up
  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (credential.user != null) {
      unawaited(_createUserDocument(credential.user!));
    }

    return credential;
  }

  /// Email Login
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Reset Password
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint("Error signing out of Firebase: $e");
    }
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: _webClientId,
      );
      await googleSignIn.signOut();
    } catch (e) {
      debugPrint("Error signing out of Google: $e");
    }
  }

  User? get currentUser => _auth.currentUser;
}
