import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:mobile_pager_flutter/features/authentication/data/datasources/i_auth_remote_datasource.dart';
import 'dart:io';

class AuthRemoteDataSourceImpl implements IAuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthRemoteDataSourceImpl({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  @override
  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn
          .signIn()
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () => throw AuthCancelledException('Waktu login habis'),
          );

      if (googleUser == null) {
        throw AuthCancelledException('Autentikasi dibatalkan');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser
          .authentication
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Gagal mendapatkan kredensial'),
          );

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _firebaseAuth
          .signInWithCredential(credential)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Gagal sign in ke Firebase'),
          );
    } on AuthCancelledException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Error signing in with Google: $e');
    }
  }

  @override
  Future<AuthCredential> getGoogleCredential() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn
          .signIn()
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () => throw AuthCancelledException('Waktu login habis'),
          );

      if (googleUser == null) {
        throw AuthCancelledException('Autentikasi dibatalkan');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser
          .authentication
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Gagal mendapatkan kredensial'),
          );

      return GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
    } on AuthCancelledException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Error getting Google credential: $e');
    }
  }

  @override
  Future<UserCredential> signInAnonymously() async {
    try {
      return await _firebaseAuth.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Error signing in anonymously: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([_firebaseAuth.signOut(), _googleSignIn.signOut()]);
    } catch (e) {
      throw Exception('Error signing out: $e');
    }
  }

  @override
  Future<void> deleteUser() async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('No user signed in');
      await user.delete();
    } catch (e) {
      throw Exception('Error deleting user: $e');
    }
  }

  @override
  Future<DocumentSnapshot> getUserDocument(String uid) async {
    try {
      return await _firestore
          .collection('users')
          .doc(uid)
          .get()
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception('Gagal mengakses database'),
          );
    } catch (e) {
      throw Exception('Error getting user document: $e');
    }
  }

  @override
  Stream<DocumentSnapshot> streamUserDocument(String uid) {
    return _firestore.collection('users').doc(uid).snapshots();
  }

  @override
  Future<void> setUserDocument(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .set(data)
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception('Gagal menyimpan data user'),
          );
    } catch (e) {
      throw Exception('Error setting user document: $e');
    }
  }

  @override
  Future<void> updateUserDocument(
    String uid,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _firestore.collection('users').doc(uid).update(updates);
    } catch (e) {
      throw Exception('Error updating user document: $e');
    }
  }

  @override
  Future<void> deleteUserDocument(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
    } catch (e) {
      throw Exception('Error deleting user document: $e');
    }
  }

  @override
  Future<DocumentSnapshot> getMerchantDocument(String uid) async {
    try {
      return await _firestore.collection('merchants').doc(uid).get();
    } catch (e) {
      throw Exception('Error getting merchant document: $e');
    }
  }

  @override
  Future<String> getDeviceId() async {
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
}

class AuthCancelledException implements Exception {
  final String message;
  AuthCancelledException(this.message);

  @override
  String toString() => message;
}
