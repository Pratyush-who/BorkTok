import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign up with email and password
  Future<User?> signUp({
    required String email, 
    required String password, 
    String? displayName
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      // Update display name if provided
      if (displayName != null) {
        await result.user?.updateDisplayName(displayName);
      }
      
      return result.user;
    } on FirebaseAuthException catch (e) {
      print('Sign Up Error: ${e.message}');
      return null;
    }
  }

  // Login with email and password
  Future<User?> signIn({
    required String email, 
    required String password
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      print('Sign In Error: ${e.message}');
      return null;
    }
  }

  // Google Sign In
   Future<User?> signInWithGoogle() async {
    try {
      // Begin interactive sign-in process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      // If user canceled the sign-in flow
      if (googleUser == null) {
        return null;
      }
      
      // Obtain auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Create new credential for Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print('Google sign in error: $e');
      // More detailed error handling
      if (e is FirebaseAuthException) {
        print('Firebase Auth Error Code: ${e.code}');
      }
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      print('Sign Out Error: $e');
    }
  }
}