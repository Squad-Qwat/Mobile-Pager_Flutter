import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_pager_flutter/features/analytics/domain/models/analytics_model.dart';
import 'package:mobile_pager_flutter/features/analytics/domain/repositories/i_analytics_repository.dart';
import 'package:mobile_pager_flutter/features/pager/domain/models/pager_model.dart';

class AnalyticsRepositoryImpl implements IAnalyticsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _activeCollection = 'active_pagers';

  @override
  Stream<AnalyticsModel> watchMerchantAnalytics(String merchantId) {
    return _firestore
        .collection(_activeCollection)
        .where('merchantId', isEqualTo: merchantId)
        .snapshots()
        .map((snapshot) => _calculateAnalytics(snapshot.docs));
  }

  AnalyticsModel _calculateAnalytics(List<QueryDocumentSnapshot> docs) {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final startOfWeek = now.subtract(Duration(days: 7));

    // Convert to PagerModel list
    final allPagers = docs.map((doc) => PagerModel.fromFirestore(doc)).toList();

    // Calculate today's pagers
    final todayPagers = allPagers.where((pager) {
      return pager.createdAt.isAfter(startOfToday);
    }).length;

    // Calculate weekly pagers
    final weeklyPagers = allPagers.where((pager) {
      return pager.createdAt.isAfter(startOfWeek);
    }).length;

    // Calculate average SERVICE time (activatedAt → finishedAt)
    // Service time = time from being called until finished
    final finishedPagersList = allPagers.where((pager) {
      return pager.status == PagerStatus.finished && 
             pager.activatedAt != null && 
             pager.finishedAt != null;
    }).toList();

    int totalServiceSeconds = 0;
    for (var pager in finishedPagersList) {
      final duration = pager.finishedAt!.difference(pager.activatedAt!);
      if (duration.inSeconds > 0) {
        totalServiceSeconds += duration.inSeconds;
      }
    }

    final averageWaitSeconds = finishedPagersList.isEmpty
        ? 0
        : (totalServiceSeconds / finishedPagersList.length).round();

    // Calculate completion rate (finished / total)
    final finishedPagers =
        allPagers.where((p) => p.status == PagerStatus.finished).length;
    final completionRate =
        allPagers.isEmpty ? 0.0 : (finishedPagers / allPagers.length) * 100;

    return AnalyticsModel(
      todayPagers: todayPagers,
      weeklyPagers: weeklyPagers,
      averageWaitSeconds: averageWaitSeconds,
      completionRate: completionRate,
    );
  }
}
