import 'package:mobile_pager_flutter/core/services/fcm_service.dart';
import 'package:mobile_pager_flutter/features/notifications/domain/repositories/i_notification_repository.dart';

class FCMTokenManager {
  final FCMService _fcmService;
  final INotificationRepository _notificationRepository;

  FCMTokenManager(this._fcmService, this._notificationRepository);

  Future<void> saveTokenForUser(String userId) async {
    try {
      final token = await _fcmService.getToken();
      if (token != null) {
        await _notificationRepository.saveFCMToken(userId, token);
      }
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> deleteTokenForUser(String userId) async {
    try {
      await _notificationRepository.deleteFCMToken(userId);
      await _fcmService.deleteToken();
    } catch (e) {
      // Silently fail
    }
  }
}
