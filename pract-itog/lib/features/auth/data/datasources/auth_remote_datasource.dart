import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  });
  Future<void> logout();
  Future<void> resetPassword(String email);
  Future<void> sendEmailVerification();
  Future<bool> isEmailVerified();
  UserModel? getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSourceImpl({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) : _auth = auth,
       _firestore = firestore;

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user!;
    return UserModel.fromFirebase(
      id: user.uid,
      email: user.email ?? email,
      name: user.displayName ?? '',
      isEmailVerified: user.emailVerified,
    );
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user!;
    await user.updateDisplayName(name.trim());
    await _firestore.collection('users').doc(user.uid).set({
      'id': user.uid,
      'name': name.trim(),
      'email': email.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    await user.sendEmailVerification();
    return UserModel.fromFirebase(
      id: user.uid,
      email: user.email ?? email,
      name: name.trim(),
      isEmailVerified: false,
    );
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
  }

  @override
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  @override
  Future<void> sendEmailVerification() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  @override
  Future<bool> isEmailVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  @override
  UserModel? getCurrentUser() {
    final user = _auth.currentUser;
    if (user == null) return null;
    return UserModel.fromFirebase(
      id: user.uid,
      email: user.email ?? '',
      name: user.displayName ?? '',
      isEmailVerified: user.emailVerified,
    );
  }
}
