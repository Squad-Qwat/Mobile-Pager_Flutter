package com.squadqwat.mobile_pager_flutter

import android.app.NotificationChannel
import android.app.NotificationManager
import android.media.AudioAttributes
import android.media.RingtoneManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createNotificationChannels()
    }

    private fun createNotificationChannels() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val notificationManager = getSystemService(NotificationManager::class.java)

            // Pager Call Channel - High priority for urgent notifications
            val pagerCallChannel = NotificationChannel(
                "pager_call_channel",
                "Pager Calls",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "High priority notifications for pager calls when your order is ready"
                enableVibration(true)
                // Long 3x vibration pattern: 
                // [delay, vibrate1, pause1, vibrate2, pause2, vibrate3]
                // 0ms delay, 800ms vibe, 400ms pause, 800ms vibe, 400ms pause, 800ms vibe
                vibrationPattern = longArrayOf(0, 800, 400, 800, 400, 800)
                enableLights(true)
                lightColor = android.graphics.Color.RED
                setShowBadge(true)
                // Use custom notification sound from res/raw/pager_ringing.mp3
                val soundUri = android.net.Uri.parse(
                    "android.resource://${packageName}/raw/pager_ringing"
                )
                setSound(
                    soundUri,
                    AudioAttributes.Builder()
                        .setUsage(AudioAttributes.USAGE_NOTIFICATION_RINGTONE)
                        .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                        .build()
                )
            }
            notificationManager.createNotificationChannel(pagerCallChannel)

            // Pager Status Channel - Normal priority for status updates
            val pagerStatusChannel = NotificationChannel(
                "pager_status_channel",
                "Pager Status Updates",
                NotificationManager.IMPORTANCE_DEFAULT
            ).apply {
                description = "Notifications for pager status changes"
                enableVibration(true)
                vibrationPattern = longArrayOf(0, 500, 250, 500)
            }
            notificationManager.createNotificationChannel(pagerStatusChannel)
        }
    }
}
