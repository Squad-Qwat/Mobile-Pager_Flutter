import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pager_flutter/features/pager/data/repositories/pager_repository_impl.dart';
import 'package:mobile_pager_flutter/features/pager/domain/models/pager_model.dart';
import 'package:mobile_pager_flutter/features/pager/domain/repositories/i_pager_repository.dart';
import 'package:mobile_pager_flutter/features/pager/presentation/notifiers/pager_notifier.dart';

/// Pager repository provider
final pagerRepositoryProvider = Provider<IPagerRepository>((ref) {
  return PagerRepositoryImpl();
});

/// Pager notifier provider
final pagerNotifierProvider = StateNotifierProvider<PagerNotifier, PagerState>((
  ref,
) {
  final repository = ref.watch(pagerRepositoryProvider);
  return PagerNotifier(repository);
});

/// Stream provider for temporary pagers (merchant view)
final temporaryPagersStreamProvider =
    StreamProvider.family<List<PagerModel>, String>((ref, merchantId) {
      final repository = ref.watch(pagerRepositoryProvider);
      return repository.watchTemporaryPagers(merchantId);
    });

/// Stream provider for active pagers (merchant view)
final activePagersStreamProvider =
    StreamProvider.family<List<PagerModel>, String>((ref, merchantId) {
      final repository = ref.watch(pagerRepositoryProvider);
      return repository.watchActivePagers(merchantId);
    });

/// Stream provider for customer's active pagers
final customerPagersStreamProvider =
    StreamProvider.family<List<PagerModel>, String>((ref, customerId) {
      final repository = ref.watch(pagerRepositoryProvider);
      return repository.getCustomerActivePagers(customerId);
    });

/// Stream provider for merchant's history pagers
final merchantHistoryPagersStreamProvider =
    StreamProvider.family<List<PagerModel>, String>((ref, merchantId) {
      final repository = ref.watch(pagerRepositoryProvider);
      return repository.getMerchantHistoryPagers(merchantId);
    });

/// Stream provider for customer's history pagers
final customerHistoryPagersStreamProvider =
    StreamProvider.family<List<PagerModel>, String>((ref, customerId) {
      final repository = ref.watch(pagerRepositoryProvider);
      return repository.getCustomerHistoryPagers(customerId);
    });

/// Future provider for single pager detail (auto-dispose for fresh data)
final pagerDetailProvider =
    FutureProvider.autoDispose.family<PagerModel?, String>((ref, pagerId) async {
      final repository = ref.watch(pagerRepositoryProvider);
      return repository.getPagerById(pagerId);
    });
