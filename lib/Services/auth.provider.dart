import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:graduation_project/services/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AppAuthProvider with ChangeNotifier { // Renamed from AuthProvider
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'uid': credential.user!.uid,
        'email': email,
        'fullName': fullName,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Future<void> logout() async {
  //   await _auth.signOut();
  //   credential.user|.uid = null;
  //   notifyListeners();
  // }
}