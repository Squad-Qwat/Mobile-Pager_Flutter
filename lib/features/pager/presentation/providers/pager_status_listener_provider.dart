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
    // Initialize notification service
    await _notificationService.initialize();

    // Get current user
    final authState = _ref.read(authNotifierProvider);
    if (!authState.isAuthenticated || authState.user == null) {
      print('⚠️ User not authenticated, skipping pager status listener');
      return;
    }

    final user = authState.user!;

    // Only listen for customer pagers (not merchant)
    if (user.isMerchant) {
      print('⚠️ User is merchant, skipping customer pager status listener');
      return;
    }

    print('👂 Starting to listen for pager status changes for customer: ${user.uid}');

    // Listen to customer's active pagers
    final repository = PagerRepositoryImpl();
    _subscription = repository.getCustomerActivePagers(user.uid).listen(
      (pagers) {
        _handlePagerUpdates(pagers);
      },
      onError: (error) {
        print('❌ Error listening to pager updates: $error');
      },
    );
  }

  void _handlePagerUpdates(List<PagerModel> pagers) {
    print('🔄 Received ${pagers.length} active pagers');

    for (final pager in pagers) {
      final lastStatus = _lastKnownStatus[pager.pagerId];
      final currentStatus = pager.status;

      // Check if status changed
      if (lastStatus != null && lastStatus != currentStatus) {
        print('📊 Status changed for ${pager.displayId}: $lastStatus → $currentStatus');
        _handleStatusChange(pager, lastStatus, currentStatus);
      }

      // Update last known status
      _lastKnownStatus[pager.pagerId] = currentStatus;
    }

    // Clean up statuses for pagers that are no longer active
    final activePagerIds = pagers.map((p) => p.pagerId).toSet();
    _lastKnownStatus.removeWhere((key, value) => !activePagerIds.contains(key));
  }

  Future<void> _handleStatusChange(
    PagerModel pager,
    PagerStatus oldStatus,
    PagerStatus newStatus,
  ) async {
    print('🔔 Handling status change: ${pager.displayId} - $oldStatus → $newStatus');

    // Get merchant name from Firestore
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
      print('⚠️ Error getting merchant name: $e');
    }

    switch (newStatus) {
      case PagerStatus.ringing:
        // PAGER IS CALLING! Show full notification with vibration
        print('📳 PAGER RINGING! Showing notification for ${pager.displayId}');
        await _notificationService.showPagerCallNotification(pager, merchantName);
        break;

      case PagerStatus.ready:
        // Order is ready
        print('✅ Order ready: ${pager.displayId}');
        // Stop vibration immediately
        await _notificationService.stopVibration();
        // Cancel ringing notification
        await _notificationService.cancelPagerCallNotification(pager.pagerId);
        // Show ready notification
        await _notificationService.showStatusChangeNotification(
          pagerId: pager.pagerId,
          title: '✅ Pesanan Siap Diambil!',
          body: '$merchantName - Antrian ${pager.queueNumber}',
        );
        break;

      case PagerStatus.finished:
        // Order finished/collected
        print('🎉 Order finished: ${pager.displayId}');
        // Stop vibration immediately
        await _notificationService.stopVibration();
        // Cancel all notifications
        await _notificationService.cancelPagerCallNotification(pager.pagerId);
        break;

      case PagerStatus.expired:
        // Order expired
        print('⏰ Order expired: ${pager.displayId}');
        // Stop vibration immediately
        await _notificationService.stopVibration();
        // Cancel all notifications
        await _notificationService.cancelPagerCallNotification(pager.pagerId);
        break;

      default:
        break;
    }
  }

  void dispose() {
    print('🔌 Disposing pager status listener');
    _subscription?.cancel();
    _notificationService.stopVibration();
  }
}
