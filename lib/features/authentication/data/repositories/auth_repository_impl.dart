import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_pager_flutter/core/domains/users.dart';
import 'package:mobile_pager_flutter/features/authentication/data/datasources/i_auth_remote_datasource.dart';
import 'package:mobile_pager_flutter/features/authentication/domain/repositories/i_auth_repository.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final IAuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Stream<User?> get authStateChanges => _remoteDataSource.authStateChanges;

  @override
  User? get currentUser => _remoteDataSource.currentUser;

  @override
  Future<UserModel> signInWithGoogle({required String role}) async {
    try {
      final userCredential = await _remoteDataSource.signInWithGoogle();
      final user = userCredential.user;

      if (user == null) {
        throw Exception('User is null after sign in');
      }

      final userDoc = await _remoteDataSource.getUserDocument(user.uid);

      if (userDoc.exists) {
        return UserModel.fromFirestore(userDoc);
      } else {
        final newUser = UserModel.createRegistered(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? '',
          photoURL: user.photoURL ?? '',
          role: role,
        );

        await _remoteDataSource.setUserDocument(user.uid, newUser.toMap());
        return newUser;
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserModel> signInAsGuest() async {
    try {
      final userCredential = await _remoteDataSource.signInAnonymously();
      final user = userCredential.user;

      if (user == null) {
        throw Exception('User is null after anonymous sign in');
      }

      final userDoc = await _remoteDataSource.getUserDocument(user.uid);

      if (userDoc.exists) {
        return UserModel.fromFirestore(userDoc);
      }

      final deviceId = await _remoteDataSource.getDeviceId();
      final newUser = UserModel.createGuest(
        uid: user.uid,
        guestId: user.uid,
        deviceId: deviceId,
      );

      await _remoteDataSource.setUserDocument(user.uid, newUser.toMap());

      return newUser;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _remoteDataSource.signOut();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserModel?> getUserData(String uid) async {
    try {
      final userDoc = await _remoteDataSource.getUserDocument(uid);

      if (userDoc.exists) {
        return UserModel.fromFirestore(userDoc);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Stream<UserModel?> streamUserData(String uid) {
    return _remoteDataSource.streamUserDocument(uid).map((doc) {
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    });
  }

  @override
  Future<void> updateUserProfile({
    required String uid,
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (displayName != null) updates['displayName'] = displayName;
      if (photoURL != null) updates['photoURL'] = photoURL;

      if (updates.isNotEmpty) {
        await _remoteDataSource.updateUserDocument(uid, updates);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> isMerchantProfileComplete(String uid) async {
    try {
      final merchantDoc = await _remoteDataSource.getMerchantDocument(uid);
      return merchantDoc.exists;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No user signed in');

      await _remoteDataSource.deleteUserDocument(user.uid);
      await _remoteDataSource.deleteUser();
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> linkAnonymousToGoogle({required String role}) async {
    try {
      final currentFirebaseUser = currentUser;
      if (currentFirebaseUser == null) {
        throw Exception('No user signed in');
      }

      if (!currentFirebaseUser.isAnonymous) {
        throw Exception('Current user is not anonymous');
      }

      final credential = await _remoteDataSource.getGoogleCredential();
      final linkedUser = await currentFirebaseUser.linkWithCredential(
        credential,
      );
      final user = linkedUser.user;

      if (user == null) {
        throw Exception('Failed to link account');
      }

      final updatedUser = UserModel.createRegistered(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? '',
        photoURL: user.photoURL ?? '',
        role: role,
      );

      await _remoteDataSource.setUserDocument(user.uid, updatedUser.toMap());

      return updatedUser;
    } catch (e) {
      rethrow;
    }
  }
}
