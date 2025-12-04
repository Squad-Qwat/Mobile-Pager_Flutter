import 'package:mobile_pager_flutter/features/pager/domain/models/pager_model.dart';

abstract class IPagerRepository {
  /// Create a temporary pager for merchant
  Future<String> createTemporaryPager({
    required String merchantId,
    String? label,
    Map<String, dynamic>? metadata,
  });

  /// Watch temporary pagers for a merchant (real-time stream)
  Stream<List<PagerModel>> watchTemporaryPagers(String merchantId);

  /// Watch active pagers for a merchant (real-time stream)
  Stream<List<PagerModel>> watchActivePagers(String merchantId);

  /// Activate a pager by moving it from temporary to active collection
  Future<void> activatePager({
    required String pagerId,
    required String customerId,
    required String customerType,
    required Map<String, dynamic> customerInfo,
  });

  /// Get a single pager by ID from either collection
  Future<PagerModel?> getPagerById(String pagerId);

  /// Update pager status (ready, finished, expired)
  Future<void> updatePagerStatus({
    required String pagerId,
    required PagerStatus status,
  });

  /// Delete a temporary pager
  Future<void> deleteTemporaryPager(String pagerId);

  /// Get customer's active pagers
  Stream<List<PagerModel>> getCustomerActivePagers(String customerId);
}
