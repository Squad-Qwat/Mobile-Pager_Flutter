import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pager_flutter/features/analytics/data/repositories/analytics_repository_impl.dart';
import 'package:mobile_pager_flutter/features/analytics/domain/models/analytics_model.dart';
import 'package:mobile_pager_flutter/features/analytics/domain/repositories/i_analytics_repository.dart';

/// Analytics repository provider
final analyticsRepositoryProvider = Provider<IAnalyticsRepository>((ref) {
  return AnalyticsRepositoryImpl();
});

/// Future provider for merchant analytics
final merchantAnalyticsProvider =
    FutureProvider.family<AnalyticsModel, String>((ref, merchantId) async {
  final repository = ref.watch(analyticsRepositoryProvider);
  return repository.getMerchantAnalytics(merchantId);
});
