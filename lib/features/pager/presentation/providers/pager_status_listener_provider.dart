import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pager_flutter/core/services/pager_notification_service.dart';
import 'package:mobile_pager_flutter/features/authentication/presentation/providers/auth_providers.dart';
import 'package:mobile_pager_flutter/features/pager/data/repositories/pager_repository_impl.dart';
import 'package:mobile_pager_flutter/features/pager/domain/models/pager_model.dart';

/// Provider that listens to pager status changes and triggers notifications
final pagerStatusListenerProvider = Provider.autoDispose((ref) {
  return PagerStatusListener(ref);
});

class PagerStatusListener {
  final Ref _ref;
  final PagerNotificationService _notificationService =
      PagerNotificationService();
  final Map<String, PagerStatus> _lastKnownStatus = {};
  StreamSubscription? _subscription;

  PagerStatusListener(this._ref) {
    _initialize();
  }

  Future<void> _initialize() async {
    await _notificationService.initialize();

    final authState = _ref.read(authNotifierProvider);
    if (!authState.isAuthenticated || authState.user == null) {
      return;
    }

    final user = authState.user!;

    if (user.isMerchant) {
      return;
    }

    final repository = PagerRepositoryImpl();
    _subscription = repository.getCustomerActivePagers(user.uid).listen(
      (pagers) {
        _handlePagerUpdates(pagers);
      },
      onError: (error) {},
    );
  }

  void _handlePagerUpdates(List<PagerModel> pagers) {
    for (final pager in pagers) {
      final lastStatus = _lastKnownStatus[pager.pagerId];
      final currentStatus = pager.status;

      if (lastStatus != null && lastStatus != currentStatus) {
        _handleStatusChange(pager, lastStatus, currentStatus);
      }

      _lastKnownStatus[pager.pagerId] = currentStatus;
    }

    final activePagerIds = pagers.map((p) => p.pagerId).toSet();
    _lastKnownStatus.removeWhere((key, value) => !activePagerIds.contains(key));
  }

  Future<void> _handleStatusChange(
    PagerModel pager,
    PagerStatus oldStatus,
    PagerStatus newStatus,
  ) async {
    String merchantName = 'Merchant';
    try {
      final merchantDoc = await FirebaseFirestore.instance
          .collection('merchants')
          .doc(pager.merchantId)
          .get();
      if (merchantDoc.exists) {
        merchantName = merchantDoc.data()?['businessName'] ??
                      merchantDoc.data()?['name'] ??
                      'Merchant';
      }
    } catch (e) {
      // Use default merchant name
    }

    switch (newStatus) {
      case PagerStatus.ringing:
        await _notificationService.showPagerCallNotification(pager, merchantName);
        break;

      case PagerStatus.ready:
        await _notificationService.stopVibration();
        await _notificationService.cancelPagerCallNotification(pager.pagerId);
        await _notificationService.showStatusChangeNotification(
          pagerId: pager.pagerId,
          title: '✅ Pesanan Siap Diambil!',
          body: '$merchantName - Antrian ${pager.queueNumber}',
        );
        break;

      case PagerStatus.finished:
        await _notificationService.stopVibration();
        await _notificationService.cancelPagerCallNotification(pager.pagerId);
        break;

      case PagerStatus.expired:
        await _notificationService.stopVibration();
        await _notificationService.cancelPagerCallNotification(pager.pagerId);
        break;

      default:
        break;
    }
  }

  void dispose() {
    _subscription?.cancel();
    _notificationService.stopVibration();
  }
}
