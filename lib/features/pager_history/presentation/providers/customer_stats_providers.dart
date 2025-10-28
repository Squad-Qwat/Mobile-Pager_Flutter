import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pager_flutter/features/pager/domain/models/pager_model.dart';
import 'package:mobile_pager_flutter/features/pager/presentation/providers/pager_providers.dart';
import 'package:mobile_pager_flutter/features/pager_history/domain/models/customer_stats_model.dart';

/// Provider untuk mendapatkan daftar customer dengan statistik
/// Hanya menampilkan non-guest users
final customerStatsListProvider =
    FutureProvider.family<List<CustomerStatsModel>, String>(
  (ref, merchantId) async {
    final repository = ref.watch(pagerRepositoryProvider);
    return repository.getCustomerStatsList(merchantId);
  },
);

/// Provider untuk mendapatkan riwayat pager dari customer tertentu
final customerPagerHistoryProvider =
    FutureProvider.family<List<PagerModel>, CustomerHistoryParams>(
  (ref, params) async {
    final repository = ref.watch(pagerRepositoryProvider);
    return repository.getCustomerPagerHistory(
      merchantId: params.merchantId,
      customerId: params.customerId,
    );
  },
);

/// Parameter class untuk customerPagerHistoryProvider
class CustomerHistoryParams {
  final String merchantId;
  final String customerId;

  CustomerHistoryParams({
    required this.merchantId,
    required this.customerId,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CustomerHistoryParams &&
        other.merchantId == merchantId &&
        other.customerId == customerId;
  }

  @override
  int get hashCode => merchantId.hashCode ^ customerId.hashCode;
}
