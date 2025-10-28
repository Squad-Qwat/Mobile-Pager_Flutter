import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mobile_pager_flutter/features/pager/domain/models/pager_model.dart';
import 'package:vibration/vibration.dart';

/// Service to handle pager-specific notifications with sound and vibration
class PagerNotificationService 
{
  static final PagerNotificationService _instance = PagerNotificationService._internal();
  factory PagerNotificationService() => _instance; 
  PagerNotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  Timer? _vibrationTimer;
  // Timer? _soundTimer;

  /// Initialize the pager notification service
  Future<void> initialize() async 
  {
    if (_isInitialized) {return;}

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

    await _localNotifications.initialize(initSettings);

    // Create notification channel for pager calls
    await _createPagerCallChannel();

    _isInitialized = true;
    stdout.write('✅ PagerNotificationService initialized');
  }

  /// Create a high-priority notification channel for pager calls
  Future<void> _createPagerCallChannel() async 
  {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'pager_call_channel', // id
      'Pager Calls', // name
      description: 'High priority notifications for pager calls',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      enableLights: true,
      ledColor: Color.fromARGB(255, 255, 0, 0),
      showBadge: true,
    );

    await _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
    ?.createNotificationChannel(channel);

    stdout.write('✅ Pager call notification channel created');
  }

  /// Show notification when pager status changes to "ringing"
  Future<void> showPagerCallNotification(PagerModel pager, String merchantName) async 
  {
    stdout.write('🔔 Showing pager call notification for: ${pager.displayId}');

    // Start continuous vibration
    await _startContinuousVibration();

    // Show notification with full-screen intent
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'pager_call_channel',
      'Pager Calls',
      channelDescription: 'High priority notifications for pager calls',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      // Use default notification sound (no custom sound file needed)
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000, 500, 1000]),
      fullScreenIntent: true, // Show as full screen on locked device
      category: AndroidNotificationCategory.call,
      ongoing: true, // Cannot be dismissed by swiping
      autoCancel: false,
      ticker: '$merchantName memanggil Anda',
      styleInformation: BigTextStyleInformation(
        '''$merchantName memanggil Anda!\n\nNomor Antrian: ${pager.queueNumber}\nPager: ${pager.displayId}\n\n
        Pesanan Anda sudah siap! Silakan ambil pesanan Anda.''',
        contentTitle: '📞 $merchantName memanggil Anda',
        summaryText: 'Antrian ${pager.queueNumber}',
      ),
      // Add actions to the notification
      actions: const <AndroidNotificationAction>[
        AndroidNotificationAction(
          'stop_vibration',
          'Stop Getaran',
          showsUserInterface: false,
          cancelNotification: false,
        ),
      ],
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'notification.aiff',
      interruptionLevel: InterruptionLevel.critical,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      pager.pagerId.hashCode,
      '📞 $merchantName memanggil Anda',
      'Antrian ${pager.queueNumber} • ${pager.displayId} - Pesanan siap!',
      notificationDetails,
      payload: pager.pagerId,
    );

    stdout.write('✅ Pager call notification shown with sound and vibration');
  }

  /// Start continuous vibration pattern
  /// Check if device has vibrator
  Future<void> _startContinuousVibration() async 
  {
    try 
    {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator != true) 
      {
        stdout.write('⚠️ Device does not have vibrator');
        return;
      }

      // Cancel any existing vibration timer
      _vibrationTimer?.cancel();

      // Vibrate continuously for 30 seconds (or until cancelled)
      int vibrationCount = 0;
      const maxVibrations = 30; // 30 seconds

      _vibrationTimer = Timer.periodic(const Duration(seconds: 1), (timer) 
      {
        if (vibrationCount >= maxVibrations) 
        {
          timer.cancel();
          stdout.write('⏹️ Vibration stopped after 30 seconds');
          return;
        }

        // Vibrate pattern: 500ms on, 500ms off
        Vibration.vibrate(duration: 500);
        vibrationCount++;
      });

      stdout.write('✅ Started continuous vibration');
    } 
    catch (e) {stdout.write('❌ Error starting vibration: $e');}
  }

  /// Stop continuous vibration
  Future<void> stopVibration() async 
  {
    try 
    {
      _vibrationTimer?.cancel();
      _vibrationTimer = null;
      await Vibration.cancel();
      stdout.write('⏹️ Vibration stopped');
    } 
    catch (e) {stdout.write('❌ Error stopping vibration: $e');}
  }

  /// Cancel pager call notification
  Future<void> cancelPagerCallNotification(String pagerId) async 
  {
    await _localNotifications.cancel(pagerId.hashCode);
    await stopVibration();
    stdout.write('🔕 Pager call notification cancelled for: $pagerId');
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async 
  {
    await _localNotifications.cancelAll();
    await stopVibration();
    stdout.write('🔕 All notifications cancelled');
  }

  /// Show notification for status change (ready, finished, etc.)
  Future<void> showStatusChangeNotification({required String pagerId, required String title, required String body}) async 
  {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'pager_status_channel',
      'Pager Status Updates',
      channelDescription: 'Notifications for pager status changes',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 250, 500]),
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      pagerId.hashCode,
      title,
      body,
      notificationDetails,
      payload: pagerId,
    );
  }
}