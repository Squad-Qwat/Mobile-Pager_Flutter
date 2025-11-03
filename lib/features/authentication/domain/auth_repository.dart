import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:mobile_pager_flutter/core/domains/users.dart';
import 'dart:io';

/// Repository untuk handle Firebase Authentication dan Firestore operations
class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Get current Firebase user
  User? get currentUser => _firebaseAuth.currentUser;

  /// Sign in with Google
  Future<UserModel> signInWithGoogle({required String role}) async {
    try {
      // Trigger Google Sign In flow with timeout
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn().timeout(
        const Duration(seconds: 60),
        onTimeout: () => throw AuthCancelledException('Waktu login habis'),
      );
      
      if (googleUser == null) {
        throw AuthCancelledException('Autentikasi dibatalkan');
      }

      // Obtain auth details with timeout
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication.timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Gagal mendapatkan kredensial'),
      );

      // Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with timeout
      final UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Gagal sign in ke Firebase'),
          );

      final User? firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Firebase user is null');
      }

      // Check if user exists in Firestore with timeout
      final userDoc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get()
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception('Gagal mengakses database'),
          );

      UserModel userModel;

      if (userDoc.exists) {
        // Check if existing role matches requested role
        userModel = UserModel.fromFirestore(userDoc);
        
        if (userModel.role != role) {
          // Sign out from Firebase Auth since we won't allow this
          await _firebaseAuth.signOut();
          throw RoleConflictException(
            'Akun ini sudah terdaftar sebagai ${_getRoleText(userModel.role)}. '
            'Gunakan akun Google lain atau hapus akun ${_getRoleText(userModel.role)} terlebih dahulu.'
          );
        }
        
        // Update last login
        await _updateLastLogin(firebaseUser.uid);
      } else {
        // Create new user
        userModel = UserModel.createRegistered(
          uid: firebaseUser.uid,
          role: role,
          email: firebaseUser.email!,
          displayName: firebaseUser.displayName,
          photoURL: firebaseUser.photoURL,
        );
        await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .set(userModel.toMap())
            .timeout(
              const Duration(seconds: 15),
              onTimeout: () => throw Exception('Gagal menyimpan data user'),
            );
      }

      return userModel;
    } on AuthCancelledException {
      rethrow;
    } on RoleConflictException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Error signing in with Google: $e');
    }
  }

  /// Sign in as guest (anonymous)
  Future<UserModel> signInAsGuest() async {
    try {
      // Sign in anonymously
      final UserCredential userCredential =
          await _firebaseAuth.signInAnonymously();

      final User? firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Firebase user is null');
      }

      // Generate guest ID
      final guestId = 'GUEST-${DateTime.now().millisecondsSinceEpoch}';

      // Get device ID
      final deviceId = await _getDeviceId();

      // Create guest user model
      final userModel = UserModel.createGuest(
        uid: firebaseUser.uid,
        guestId: guestId,
        deviceId: deviceId,
      );

      // Save to Firestore
      await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .set(userModel.toMap());

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Error signing in as guest: $e');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw Exception('Error signing out: $e');
    }
  }

  /// Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Error getting user data: $e');
    }
  }

  /// Stream of user data from Firestore
  Stream<UserModel?> streamUserData(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return null;
      return UserModel.fromFirestore(snapshot);
    });
  }

  /// Update user profile
  Future<void> updateUserProfile({
    required String uid,
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (displayName != null) updates['displayName'] = displayName;
      if (photoURL != null) updates['photoURL'] = photoURL;
      updates['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('users').doc(uid).update(updates);
    } catch (e) {
      throw Exception('Error updating user profile: $e');
    }
  }

  /// Delete user account
  Future<void> deleteAccount() async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No user signed in');

      // Delete Firestore data
      await _firestore.collection('users').doc(user.uid).delete();

      // Delete Firebase Auth account
      await user.delete();
    } catch (e) {
      throw Exception('Error deleting account: $e');
    }
  }

  /// Check if user profile is complete (for merchant)
  Future<bool> isMerchantProfileComplete(String uid) async {
    try {
      final merchantDoc =
          await _firestore.collection('merchants').doc(uid).get();
      return merchantDoc.exists;
    } catch (e) {
      return false;
    }
  }

  /// Private: Update last login timestamp
  Future<void> _updateLastLogin(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'lastLoginAt': FieldValue.serverTimestamp(),
    });
  }

  /// Private: Get device ID
  Future<String> _getDeviceId() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? 'unknown';
      }
      return 'unknown';
    } catch (e) {
      return 'unknown';
    }
  }

  /// Private: Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'account-exists-with-different-credential':
        return 'Akun sudah terdaftar dengan metode login berbeda';
      case 'invalid-credential':
        return 'Kredensial tidak valid';
      case 'operation-not-allowed':
        return 'Operasi tidak diizinkan';
      case 'user-disabled':
        return 'Akun telah dinonaktifkan';
      case 'user-not-found':
        return 'Pengguna tidak ditemukan';
      case 'wrong-password':
        return 'Password salah';
      case 'email-already-in-use':
        return 'Email sudah digunakan';
      case 'weak-password':
        return 'Password terlalu lemah';
      case 'network-request-failed':
        return 'Koneksi internet bermasalah';
      default:
        return 'Error: ${e.message}';
    }
  }

  /// Private: Get role text in Indonesian
  String _getRoleText(String role) {
    switch (role) {
      case 'merchant':
        return 'Merchant';
      case 'customer':
        return 'Customer';
      case 'guest':
        return 'Guest';
      default:
        return role;
    }
  }
}

/// Custom exception for cancelled authentication
class AuthCancelledException implements Exception {
  final String message;
  AuthCancelledException(this.message);
  
  @override
  String toString() => message;
}

/// Custom exception for role conflict
class RoleConflictException implements Exception {
  final String message;
  RoleConflictException(this.message);
  
  @override
  String toString() => message;
}