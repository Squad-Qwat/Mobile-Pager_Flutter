import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class IAuthRemoteDataSource {
  Stream<User?> get authStateChanges;
  User? get currentUser;

  Future<UserCredential> signInWithGoogle();
  Future<AuthCredential> getGoogleCredential();
  Future<UserCredential> signInAnonymously();
  Future<void> signOut();
  Future<void> deleteUser();

  Future<DocumentSnapshot> getUserDocument(String uid);
  Stream<DocumentSnapshot> streamUserDocument(String uid);
  Future<void> setUserDocument(String uid, Map<String, dynamic> data);
  Future<void> updateUserDocument(String uid, Map<String, dynamic> updates);
  Future<void> deleteUserDocument(String uid);

  Future<DocumentSnapshot> getMerchantDocument(String uid);
  Future<String> getDeviceId();
}
