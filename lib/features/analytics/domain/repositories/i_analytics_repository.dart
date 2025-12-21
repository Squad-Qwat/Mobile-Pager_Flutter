import 'package:mobile_pager_flutter/features/analytics/domain/models/analytics_model.dart';

abstract class IAnalyticsRepository {
  /// Get analytics data for merchant dashboard (realtime stream)
  Stream<AnalyticsModel> watchMerchantAnalytics(String merchantId);
}
