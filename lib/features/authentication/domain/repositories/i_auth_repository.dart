import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_pager_flutter/core/domains/users.dart';

abstract class IAuthRepository 
{
  Stream<User?> get authStateChanges;
  User? get currentUser;

  Future<UserModel> signInWithGoogle({required String role});
  Future<UserModel> signInAsGuest();
  Future<void> signOut();

  Future<UserModel?> getUserData(String uid);
  Stream<UserModel?> streamUserData(String uid);

  Future<void> updateUserProfile({required String uid, String? displayName, String? photoURL,});

  Future<void> deleteAccount();
  Future<bool> isMerchantProfileComplete(String uid);
}