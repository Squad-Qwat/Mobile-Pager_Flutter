import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pager_flutter/core/domains/users.dart';
import 'package:mobile_pager_flutter/features/authentication/domain/repositories/i_auth_repository.dart';
import 'package:mobile_pager_flutter/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:mobile_pager_flutter/features/authentication/data/datasources/auth_remote_datasource_impl.dart';
import 'package:mobile_pager_flutter/features/authentication/domain/auth_notifier.dart';

final authRemoteDataSourceProvider = Provider((ref) {
  return AuthRemoteDataSourceImpl();
});

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final dataSource = ref.watch(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(dataSource);
});

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository);
});

final userStreamProvider = StreamProvider.autoDispose<UserModel?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final currentUser = authRepository.currentUser;

  if (currentUser == null) {
    return Stream.value(null);
  }

  return authRepository.streamUserData(currentUser.uid);
});
