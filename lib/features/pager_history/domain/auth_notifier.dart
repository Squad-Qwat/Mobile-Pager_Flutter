import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_pager_flutter/features/pager_history/domain/auth_repository.dart';
import 'package:mobile_pager_flutter/core/domains/users.dart';

/// Auth state class
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

  // Helper getters
  bool get isMerchant => user?.isMerchant ?? false;
  bool get isCustomer => user?.isCustomer ?? false;
  bool get isGuest => user?.isGuestUser ?? false;
}

/// Auth state notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(const AuthState()) {
    // Listen to auth state changes
    _authRepository.authStateChanges.listen(_onAuthStateChanged);
  }

  /// Handle auth state changes from Firebase
  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      state = const AuthState(isAuthenticated: false);
      return;
    }

    try {
      final userModel = await _authRepository.getUserData(firebaseUser.uid);
      if (userModel != null) {
        state = AuthState(
          user: userModel,
          isAuthenticated: true,
        );
      } else {
        // User exists in Firebase Auth but not in Firestore
        state = const AuthState(isAuthenticated: false);
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Error loading user data: $e',
        isAuthenticated: false,
      );
    }
  }

  /// Sign in with Google
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
      // Silent fail for cancellation - no error message
      state = state.copyWith(isLoading: false);
    }
    catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// Sign in as guest
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
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);

    try {
      await _authRepository.signOut();
      state = const AuthState(isAuthenticated: false, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// Update user profile
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    if (state.user == null) return;

    try {
      await _authRepository.updateUserProfile(
        uid: state.user!.uid,
        displayName: displayName,
        photoURL: photoURL,
      );

      // Update local state
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

  /// Check if merchant profile is complete
  Future<bool> checkMerchantProfile() async {
    if (state.user == null) return false;
    return await _authRepository.isMerchantProfileComplete(state.user!.uid);
  }

  /// Delete account
  Future<void> deleteAccount() async {
    state = state.copyWith(isLoading: true);

    try {
      await _authRepository.deleteAccount();
      state = const AuthState(isAuthenticated: false, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Riverpod providers
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository);
});

/// Stream provider for real-time user data
final userStreamProvider = StreamProvider.autoDispose<UserModel?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final currentUser = authRepository.currentUser;

  if (currentUser == null) {
    return Stream.value(null);
  }

  return authRepository.streamUserData(currentUser.uid);
});