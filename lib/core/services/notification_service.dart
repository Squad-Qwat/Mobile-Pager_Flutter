// import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:mobile_pager_flutter/features/notifications/domain/models/notification_model.dart';
import 'package:mobile_pager_flutter/features/notifications/domain/repositories/i_notification_repository.dart';
import 'package:mobile_pager_flutter/features/pager/domain/models/pager_model.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

class NotificationService 
{
  final INotificationRepository _notificationRepository;
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  NotificationService(this._notificationRepository);

  /// Send notification when customer joins queue (to merchant)
  Future<void> sendNewCustomerNotification({required String merchantId, required PagerModel pager}) async 
  {
    try 
    {
      // Create notification in Firestore
      final notification = NotificationModel(
        id: '',
        userId: merchantId,
        title: 'Customer Baru',
        body: 'Customer baru bergabung dengan nomor antrian ${pager.number}',
        type: NotificationType.newCustomer,
        data: 
        {
          'pagerId': pager.id,
          'pagerNumber': pager.number,
        },
      );

      await _notificationRepository.createNotification(notification);

      // Send FCM push notification
      await _sendFCMNotification(
        userId: merchantId,
        title: notification.title,
        body: notification.body,
        data: notification.data ?? {},
      );
    } 
    catch (e) {stdout.write('Error sending new customer notification: $e');}
  }

  /// Send notification when order is ready (to customer)
  Future<void> sendOrderReadyNotification({required String customerId, required PagerModel pager}) async 
  {
    try 
    {
      final notification = NotificationModel(
        id: '',
        userId: customerId,
        title: 'Pesanan Anda Siap!',
        body: 'Pesanan Anda dengan nomor ${pager.number} sudah siap. Silakan ambil.',
        type: NotificationType.orderReady,
        data: 
        {
          'pagerId': pager.id,
          'pagerNumber': pager.number,
        },
      );

      await _notificationRepository.createNotification(notification);

      await _sendFCMNotification(
        userId: customerId,
        title: notification.title,
        body: notification.body,
        data: notification.data ?? {},
      );
    } 
    catch (e) {stdout.write('Error sending order ready notification: $e');}
  }

  /// Send notification when customer is being called (to customer)
  Future<void> sendOrderCallingNotification({required String customerId, required PagerModel pager}) async 
  {
    try 
    {
      final notification = NotificationModel(
        id: '',
        userId: customerId,
        title: 'Waktunya Ambil Pesanan!',
        body: 'Nomor antrian ${pager.number} dipanggil. Segera ke counter!',
        type: NotificationType.orderCalling,
        data: 
        {
          'pagerId': pager.id,
          'pagerNumber': pager.number,
        },
      );

      await _notificationRepository.createNotification(notification);

      await _sendFCMNotification(
        userId: customerId,
        title: notification.title,
        body: notification.body,
        data: notification.data ?? {},
      );
    } 
    catch (e) {stdout.write('Error sending order calling notification: $e');}
  }

  /// Send notification when order will expire soon (to customer)
  Future<void> sendOrderExpiringSoonNotification({
    required String customerId,
    required PagerModel pager,
    required int minutesRemaining
  }) async 
  {
    try 
    {
      final notification = NotificationModel(
        id: '',
        userId: customerId,
        title: 'Pesanan Akan Kadaluarsa',
        body:
            'Pesanan ${pager.number} akan kadaluarsa dalam $minutesRemaining menit. Segera ambil!',
        type: NotificationType.orderExpiringSoon,
        data: 
        {
          'pagerId': pager.id,
          'pagerNumber': pager.number,
        },
      );

      await _notificationRepository.createNotification(notification);

      await _sendFCMNotification(
        userId: customerId,
        title: notification.title,
        body: notification.body,
        data: notification.data ?? {},
      );
    } 
    catch (e) {stdout.write('Error sending expiring soon notification: $e');}
  }

  /// Send notification when order has expired (to customer)
  Future<void> sendOrderExpiredNotification({required String customerId, required PagerModel pager}) async 
  {
    try 
    {
      final notification = NotificationModel(
        id: '',
        userId: customerId,
        title: 'Pesanan Kadaluarsa',
        body: 'Maaf, pesanan ${pager.number} telah kadaluarsa karena tidak diambil.',
        type: NotificationType.orderExpired,
        data: 
        {
          'pagerId': pager.id,
          'pagerNumber': pager.number,
        },
      );

      await _notificationRepository.createNotification(notification);

      await _sendFCMNotification(
        userId: customerId,
        title: notification.title,
        body: notification.body,
        data: notification.data ?? {},
      );
    } 
    catch (e) {stdout.write('Error sending order expired notification: $e');}
  }

  /// Send notification when order is finished (to customer)
  Future<void> sendOrderFinishedNotification({required String customerId, required PagerModel pager}) async 
  {
    try 
    {
      final notification = NotificationModel(
        id: '',
        userId: customerId,
        title: 'Terima Kasih!',
        body: 'Terima kasih telah menggunakan layanan kami. Pesanan ${pager.number} selesai.',
        type: NotificationType.orderFinished,
        data: 
        {
          'pagerId': pager.id,
          'pagerNumber': pager.number,
        },
      );

      await _notificationRepository.createNotification(notification);

      await _sendFCMNotification(
        userId: customerId,
        title: notification.title,
        body: notification.body,
        data: notification.data ?? {},
      );
    } 
    catch (e) {stdout.write('Error sending order finished notification: $e');}
  }

  /// Send FCM push notification via Firebase Cloud Functions
  /// Note: This requires a backend Cloud Function to send FCM messages
  /// For now, this is a placeholder that gets the token
  Future<void> _sendFCMNotification({
    required String userId, 
    required String title, 
    required String body, 
    required Map<String, dynamic> data
  }) async 
  {
    try 
    {
      // Get user's FCM token
      final token = await _notificationRepository.getFCMToken(userId);
      if (token == null) 
      {
        stdout.write('No FCM token found for user: $userId');
        return;
      }

      // TODO: Call your Cloud Function here to send FCM notification
      // For now, we just print the token
      stdout.write('Would send FCM to token: $token');
      stdout.write('Title: $title, Body: $body');

      // Example of what the Cloud Function call would look like:
      // await http.post(
      //   Uri.parse('https://YOUR_CLOUD_FUNCTION_URL/sendNotification'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: json.encode({
      //     'token': token,
      //     'title': title,
      //     'body': body,
      //     'data': data,
      //   }),
      // );
    } 
    catch (e) {stdout.write('Error sending FCM notification: $e');}
  }
}
