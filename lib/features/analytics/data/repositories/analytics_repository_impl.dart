import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_pager_flutter/features/analytics/domain/models/analytics_model.dart';
import 'package:mobile_pager_flutter/features/analytics/domain/repositories/i_analytics_repository.dart';
import 'package:mobile_pager_flutter/features/pager/domain/models/pager_model.dart';

class AnalyticsRepositoryImpl implements IAnalyticsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _activeCollection = 'active_pagers';

  @override
  Future<AnalyticsModel> getMerchantAnalytics(String merchantId) async {
    try {
      final now = DateTime.now();
      final startOfToday = DateTime(now.year, now.month, now.day);
      final startOfWeek = now.subtract(Duration(days: 7));

      // Query all active pagers for this merchant
      final activePagersQuery = await _firestore
          .collection(_activeCollection)
          .where('merchantId', isEqualTo: merchantId)
          .get();

      // Convert to PagerModel list
      final allPagers = activePagersQuery.docs
          .map((doc) => PagerModel.fromFirestore(doc))
          .toList();

      // Calculate today's pagers
      final todayPagers = allPagers.where((pager) {
        return pager.createdAt.isAfter(startOfToday);
      }).length;

      // Calculate weekly pagers
      final weeklyPagers = allPagers.where((pager) {
        return pager.createdAt.isAfter(startOfWeek);
      }).length;

      // Calculate average wait time (createdAt → finishedAt or current time)
      final pagersWithWaitTime = allPagers.where((pager) {
        return pager.status == PagerStatus.finished ||
            pager.status == PagerStatus.expired;
      }).toList();

      int totalWaitMinutes = 0;
      for (var pager in pagersWithWaitTime) {
        final endTime = pager.status == PagerStatus.finished
            ? (pager.activatedAt ?? pager.createdAt)
            : pager.createdAt;
        final waitDuration = endTime.difference(pager.createdAt);
        totalWaitMinutes += waitDuration.inMinutes;
      }

      final averageWaitMinutes = pagersWithWaitTime.isEmpty
          ? 0
          : (totalWaitMinutes / pagersWithWaitTime.length).round();

      // Calculate completion rate (finished / total)
      final finishedPagers =
          allPagers.where((p) => p.status == PagerStatus.finished).length;
      final completionRate =
          allPagers.isEmpty ? 0.0 : (finishedPagers / allPagers.length) * 100;

      return AnalyticsModel(
        todayPagers: todayPagers,
        weeklyPagers: weeklyPagers,
        averageWaitMinutes: averageWaitMinutes,
        completionRate: completionRate,
      );
    } catch (e) {
      throw Exception('Failed to get analytics: $e');
    }
  }
}
