import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pager_flutter/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:mobile_pager_flutter/features/notifications/domain/models/notification_model.dart';
import 'package:mobile_pager_flutter/features/notifications/domain/repositories/i_notification_repository.dart';

/// Notification repository provider
final notificationRepositoryProvider = Provider<INotificationRepository>((ref) {
  return NotificationRepositoryImpl();
});

/// Stream provider for user notifications
final userNotificationsProvider =
    StreamProvider.family<List<NotificationModel>, String>((ref, userId) {
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.watchUserNotifications(userId);
});

/// Stream provider for unread notification count
final unreadNotificationCountProvider =
    StreamProvider.family<int, String>((ref, userId) {
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.watchUnreadCount(userId);
});
