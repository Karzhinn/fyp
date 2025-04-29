import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AppAuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create a new account (email/password + store fullName in Firestore)
  Future<UserCredential> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    // 1) Create user in Firebase Auth
    UserCredential credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // 2) Save additional profile info
    await _firestore.collection('users').doc(credential.user!.uid).set({
      'uid': credential.user!.uid,
      'email': email,
      'fullName': fullName,
      'createdAt': FieldValue.serverTimestamp(),
    });

    notifyListeners();
    return credential;
  }

  /// Sign in an existing user
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    UserCredential credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    notifyListeners();
    return credential;
  }

  /// Sign out
  Future<void> signOut() => _auth.signOut();

  /// Stream of auth changes if you ever need it
  Stream<User?> get userChanges => _auth.authStateChanges();
}
