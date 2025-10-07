import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserCredential> signUpWithEmail(
      String email, String password, String username, String phone) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    await _firestore.collection("users").doc(userCredential.user!.uid).set({
      "username": username,
      "email": email,
      "phone": phone,
      "photoUrl": "",
      "createdAt": FieldValue.serverTimestamp(),
    });

    return userCredential;
  }

  Future<UserCredential> loginWithEmail(String email, String password) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    await _auth.currentUser?.reload();

    final userDoc =
        _firestore.collection("users").doc(userCredential.user!.uid);
    final docSnap = await userDoc.get();

    if (!docSnap.exists) {
      await userDoc.set({
        "username": userCredential.user?.displayName ?? "Guest",
        "email": userCredential.user?.email,
        "phone": "",
        "photoUrl": "",
        "createdAt": FieldValue.serverTimestamp(),
      });
    }

    return userCredential;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    final list = await _auth.fetchSignInMethodsForEmail(email.trim());
    if (list.isEmpty) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'No user found with this email.',
      );
    }
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;
}
