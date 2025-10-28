import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pager_flutter/core/services/notification_service.dart';
import 'package:mobile_pager_flutter/features/notifications/presentation/providers/notification_providers.dart';

/// Notification service provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final notificationRepository = ref.watch(notificationRepositoryProvider);
  return NotificationService(notificationRepository);
});
