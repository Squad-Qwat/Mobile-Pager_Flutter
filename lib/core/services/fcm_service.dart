import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FCMService 
{
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  /// Initialize FCM
  Future<void> initialize() async 
  {
    // Request permission for iOS
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    stdout.write('FCM Permission granted: ${settings.authorizationStatus}');

    await _initializeLocalNotifications();

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification taps when app is in background/terminated
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  /// Initialize local notifications for Android
  Future<void> _initializeLocalNotifications() async 
  {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  Future<String?> getToken() async 
  {
    try 
    {
      String? token = await _firebaseMessaging.getToken();
      stdout.write("FCM Token: $token");
      return token;
    } 
    catch (e) 
    {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  Future<void> deleteToken() async {
    try 
    {
      await _firebaseMessaging.deleteToken();
      stdout.write("FCM Token Deleted Sucessfully!");
    } 
    catch (e) {debugPrint('Error deleting FCM token: $e');}
  }

  void _handleForegroundMessage(RemoteMessage message) 
  {
    stdout.write('Foreground message received: ${message.notification?.title}');
    stdout.write('Message data: ${message.data}');

    // Check if this is a pager call notification
    if (message.data['type'] == 'pager_call') {stdout.write('📳 Pager call notification received!');} // PagerStatusListener will handle this via Firestore stream
    _showLocalNotification(message);
  }

  /// Show local notification with custom sound and vibration
  Future<void> _showLocalNotification(RemoteMessage message) async 
  {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'cammo_channel', // Channel ID
      'Cammo Notifications', // Channel name
      channelDescription: 'Notifications for pager call management',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList(const [0, 1000, 500, 1000]), // Custom vibration
      sound: const RawResourceAndroidNotificationSound('notification_sound'), // Custom sound
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'notification_sound.aiff', // Custom sound for iOS
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Cammo',
      message.notification?.body ?? '',
      notificationDetails,
      payload: message.data.toString(),
    );
  }

  void _handleMessageOpenedApp(RemoteMessage message) => stdout.write('Notification tapped: ${message.data}'); // Navigation handling can be added here

  void _onNotificationTapped(NotificationResponse response) => stdout.write('Local notification tapped: ${response.payload}'); // Navigation handling can be added here

  Future<void> subscribeToTopic(String topic) async 
  {
    await _firebaseMessaging.subscribeToTopic(topic);
    stdout.write("Subscribed to topic: $topic");
  }

  Future<void> unsubscribeFromTopic(String topic) async 
  {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    stdout.write("Unsubscribed from topic: $topic");
  }
}
