import 'package:mobile_pager_flutter/features/notifications/domain/models/notification_model.dart';

abstract class INotificationRepository {
  /// Get all notifications for a user
  Stream<List<NotificationModel>> watchUserNotifications(String userId);

  /// Get unread notification count
  Stream<int> watchUnreadCount(String userId);

  /// Create a new notification
  Future<void> createNotification(NotificationModel notification);

  /// Mark notification as read
  Future<void> markAsRead(String notificationId);

  /// Mark all notifications as read
  Future<void> markAllAsRead(String userId);

  /// Delete notification
  Future<void> deleteNotification(String notificationId);

  /// Save FCM token to Firestore
  Future<void> saveFCMToken(String userId, String token);

  /// Delete FCM token from Firestore
  Future<void> deleteFCMToken(String userId);

  /// Get FCM token for a user
  Future<String?> getFCMToken(String userId);
}
