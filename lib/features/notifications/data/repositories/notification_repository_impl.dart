import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_pager_flutter/features/notifications/domain/models/notification_model.dart';
import 'package:mobile_pager_flutter/features/notifications/domain/repositories/i_notification_repository.dart';

class NotificationRepositoryImpl implements INotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _notificationsCollection = 'notifications';
  final String _fcmTokensCollection = 'fcm_tokens';

  @override
  Stream<List<NotificationModel>> watchUserNotifications(String userId) {
    return _firestore
        .collection(_notificationsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50) // Limit to last 50 notifications
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromFirestore(doc))
            .toList());
  }

  @override
  Stream<int> watchUnreadCount(String userId) {
    return _firestore
        .collection(_notificationsCollection)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  @override
  Future<void> createNotification(NotificationModel notification) async {
    try {
      await _firestore
          .collection(_notificationsCollection)
          .add(notification.toMap());
    } catch (e) {
      throw Exception('Failed to create notification: $e');
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection(_notificationsCollection)
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    try {
      final batch = _firestore.batch();
      final unreadDocs = await _firestore
          .collection(_notificationsCollection)
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      for (var doc in unreadDocs.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore
          .collection(_notificationsCollection)
          .doc(notificationId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  @override
  Future<void> saveFCMToken(String userId, String token) async {
    try {
      await _firestore.collection(_fcmTokensCollection).doc(userId).set({
        'token': token,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save FCM token: $e');
    }
  }

  @override
  Future<void> deleteFCMToken(String userId) async {
    try {
      await _firestore.collection(_fcmTokensCollection).doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to delete FCM token: $e');
    }
  }

  @override
  Future<String?> getFCMToken(String userId) async {
    try {
      final doc =
          await _firestore.collection(_fcmTokensCollection).doc(userId).get();
      if (doc.exists) {
        return doc.data()?['token'];
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get FCM token: $e');
    }
  }
}
