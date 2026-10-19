import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._auth, this._firestore);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  UserModel? get currentUser {
    final user = _auth.currentUser;
    if (user == null) return null;
    return UserModelBuilder()
        .id(user.uid)
        .fullName(user.displayName ?? '')
        .email(user.email ?? '')
        .build();
  }

  Future<String?> storedPhoto(String userId) async {
    try {
      final document = await _firestore.collection('Users').doc(userId).get();
      return document.data()?['photoBase64'] as String?;
    } on FirebaseException {
      return null;
    }
  }

  Future<UserModel> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user!;
    try {
      final document = await _firestore.collection('Users').doc(user.uid).get();
      final data = document.data();
      if (data != null &&
          data['id'] is String &&
          data['fullName'] is String &&
          data['email'] is String) {
        return UserModel.fromJson(data);
      }
    } on FirebaseException {
      // Authentication can still succeed while the profile is temporarily offline.
    }
    return UserModelBuilder()
        .id(user.uid)
        .fullName(user.displayName ?? '')
        .email(user.email ?? email)
        .build();
  }

  Future<UserModel> signUp(String name, String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user!;
    final model = UserModelBuilder()
        .id(user.uid)
        .fullName(name)
        .email(email)
        .build();

    try {
      await user.updateDisplayName(name);
      await _firestore.collection('Users').doc(user.uid).set(model.toJson());
      return model;
    } catch (_) {
      // A failed profile write must not leave a half-created account signed in.
      try {
        await user.delete();
      } catch (_) {
        try {
          await _auth.signOut();
        } catch (_) {}
      }
      rethrow;
    }
  }

  Future<void> signOut() => _auth.signOut();
}
