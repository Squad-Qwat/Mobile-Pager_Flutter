import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_pager_flutter/core/domains/users.dart';
import 'package:mobile_pager_flutter/features/authentication/domain/repositories/i_auth_repository.dart';
import 'package:mobile_pager_flutter/features/authentication/data/datasources/auth_remote_datasource_impl.dart';
import 'package:mobile_pager_flutter/core/services/fcm_service.dart';
import 'package:mobile_pager_flutter/features/notifications/data/repositories/notification_repository_impl.dart';

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? errorMessage;
  final bool isAuthenticated;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? errorMessage,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }

  bool get isMerchant => user?.isMerchant ?? false;
  bool get isCustomer => user?.isCustomer ?? false;
  bool get isGuest => user?.isGuestUser ?? false;
}

class AuthNotifier extends StateNotifier<AuthState> {
  final IAuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(const AuthState()) {
    _authRepository.authStateChanges.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      state = const AuthState(isAuthenticated: false);
      return;
    }

    try {
      final userModel = await _authRepository.getUserData(firebaseUser.uid);
      if (userModel != null) {
        state = AuthState(user: userModel, isAuthenticated: true);
        // Save FCM token for push notifications (non-blocking)
        _saveFCMToken(userModel.uid); // Remove await - don't block authentication
      } else {
        state = const AuthState(isAuthenticated: false);
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Error loading user data: $e',
        isAuthenticated: false,
      );
    }
  }

  Future<void> _saveFCMToken(String userId) async {
    try {
      final fcmService = FCMService();
      final token = await fcmService.getToken();
      if (token != null) {
        final notificationRepo = NotificationRepositoryImpl();
        await notificationRepo.saveFCMToken(userId, token);
        print('✅ FCM token saved for user: $userId');
      }
    } catch (e) {
      print('⚠️ Error saving FCM token: $e');
      // Don't throw error, just log it
    }
  }

  Future<void> signInWithGoogle({required String role}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final userModel = await _authRepository.signInWithGoogle(role: role);
      state = AuthState(
        user: userModel,
        isAuthenticated: true,
        isLoading: false,
      );
    } on AuthCancelledException {
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> signInAsGuest() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final userModel = await _authRepository.signInAsGuest();
      state = AuthState(
        user: userModel,
        isAuthenticated: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);

    try {
      await _authRepository.signOut();
      state = const AuthState(isAuthenticated: false, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    if (state.user == null) return;

    try {
      await _authRepository.updateUserProfile(
        uid: state.user!.uid,
        displayName: displayName,
        photoURL: photoURL,
      );

      state = state.copyWith(
        user: state.user!.copyWith(
          displayName: displayName ?? state.user!.displayName,
          photoURL: photoURL ?? state.user!.photoURL,
        ),
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      rethrow;
    }
  }

  Future<bool> checkMerchantProfile() async {
    if (state.user == null) return false;
    return await _authRepository.isMerchantProfileComplete(state.user!.uid);
  }

  Future<void> deleteAccount() async {
    state = state.copyWith(isLoading: true);

    try {
      await _authRepository.deleteAccount();
      state = const AuthState(isAuthenticated: false, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
