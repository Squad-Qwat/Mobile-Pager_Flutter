# Notification Integration Guide

## How to Trigger Notifications

Notifications are triggered when pager status changes. Here's where to call notification methods:

### 1. When Customer Joins Queue (activatePager)

**Location:** `lib/features/pager/data/repositories/pager_repository_impl.dart` → `activatePager()` method

**After activation succeeds, call:**
```dart
// Get notification service from Riverpod
final notificationService = ref.read(notificationServiceProvider);

// Send notification to merchant
await notificationService.sendNewCustomerNotification(
  merchantId: pager.merchantId,
  pager: pager,
);
```

### 2. When Status Changes to READY (updatePagerStatus)

**Location:** `lib/features/pager/data/repositories/pager_repository_impl.dart` → `updatePagerStatus()` method

**When status == PagerStatus.ready, call:**
```dart
final notificationService = ref.read(notificationServiceProvider);

// Send notification to customer
await notificationService.sendOrderReadyNotification(
  customerId: pager.customerId,
  pager: pager,
);
```

### 3. When Status Changes to RINGING (updatePagerStatus)

**Location:** `lib/features/pager/data/repositories/pager_repository_impl.dart` → `updatePagerStatus()` method

**When status == PagerStatus.ringing, call:**
```dart
final notificationService = ref.read(notificationServiceProvider);

// Send notification to customer
await notificationService.sendOrderCallingNotification(
  customerId: pager.customerId,
  pager: pager,
);
```

### 4. When Status Changes to FINISHED (updatePagerStatus)

**Location:** `lib/features/pager/data/repositories/pager_repository_impl.dart` → `updatePagerStatus()` method

**When status == PagerStatus.finished, call:**
```dart
final notificationService = ref.read(notificationServiceProvider);

// Send notification to customer
await notificationService.sendOrderFinishedNotification(
  customerId: pager.customerId,
  pager: pager,
);
```

### 5. When Status Changes to EXPIRED (updatePagerStatus)

**Location:** `lib/features/pager/data/repositories/pager_repository_impl.dart` → `updatePagerStatus()` method

**When status == PagerStatus.expired, call:**
```dart
final notificationService = ref.read(notificationServiceProvider);

// Send notification to customer
await notificationService.sendOrderExpiredNotification(
  customerId: pager.customerId,
  pager: pager,
);
```

---

## Example Integration in Widget

Since repository shouldn't have direct access to Riverpod ref, you should call notifications from the **UI layer** (e.g., in `PagerTicketCard` when user taps action button).

**Example in `lib/core/presentation/widget/pager_ticket_card.dart`:**

```dart
// Import notification service provider
import 'package:mobile_pager_flutter/core/services/notification_service_provider.dart';

// In your status update method:
Future<void> _handleStatusChange(PagerStatus newStatus) async {
  final repository = ref.read(pagerRepositoryProvider);
  final notificationService = ref.read(notificationServiceProvider);

  // Update status in repository
  await repository.updatePagerStatus(
    pagerId: widget.pager.pagerId,
    status: newStatus,
  );

  // Send notification based on status
  if (newStatus == PagerStatus.ready) {
    await notificationService.sendOrderReadyNotification(
      customerId: widget.pager.customerId,
      pager: widget.pager,
    );
  } else if (newStatus == PagerStatus.ringing) {
    await notificationService.sendOrderCallingNotification(
      customerId: widget.pager.customerId,
      pager: widget.pager,
    );
  } else if (newStatus == PagerStatus.finished) {
    await notificationService.sendOrderFinishedNotification(
      customerId: widget.pager.customerId,
      pager: widget.pager,
    );
  }
}
```

---

## FCM Token Management

### Save Token on Login

**Location:** After successful login in `lib/features/authentication/presentation/page/authentication_page.dart`

```dart
// Import
import 'package:mobile_pager_flutter/core/services/fcm_service.dart';
import 'package:mobile_pager_flutter/features/notifications/presentation/providers/notification_providers.dart';

// After login succeeds:
final fcmService = FCMService();
final token = await fcmService.getToken();
if (token != null) {
  final repository = ref.read(notificationRepositoryProvider);
  await repository.saveFCMToken(user.uid, token);
}
```

### Delete Token on Logout

**Location:** Before logout in `lib/features/profile/presentation/profile_page.dart`

```dart
// Before signOut:
final fcmService = FCMService();
final repository = ref.read(notificationRepositoryProvider);
await repository.deleteFCMToken(user.uid);
await fcmService.deleteToken();
```

---

## Testing Notifications

### 1. Test Local Notifications (without FCM server)

Run app and trigger status changes. Notifications will appear in Firestore `notifications` collection and show in notification history page.

### 2. Test FCM Push Notifications (requires backend)

To send actual push notifications, you need to:

1. **Setup Firebase Cloud Function** or backend API
2. **Call your backend** from `_sendFCMNotification()` in `notification_service.dart`

Example Cloud Function:
```javascript
exports.sendNotification = functions.https.onCall(async (data, context) => {
  const { token, title, body, data } = data;

  await admin.messaging().send({
    token: token,
    notification: { title, body },
    data: data,
    android: {
      priority: 'high',
    },
  });
});
```

---

## Firebase Schema

### Collection: `notifications`
```
notifications/{notificationId}
├─ userId: String (recipient)
├─ title: String
├─ body: String
├─ type: String (enum)
├─ data: Map<String, dynamic>
├─ isRead: Boolean
└─ createdAt: Timestamp
```

### Collection: `fcm_tokens`
```
fcm_tokens/{userId}
├─ token: String
└─ updatedAt: Timestamp
```

---

## Custom Sound & Vibration

### Android
1. Add sound file to `android/app/src/main/res/raw/notification_sound.mp3`
2. Vibration pattern already configured in `fcm_service.dart`

### iOS
1. Add sound file to `ios/Runner/notification_sound.aiff`
2. Update `Info.plist` if needed

---

## Notification Types

- `newCustomer` - New customer joined queue (to merchant)
- `orderReady` - Order is ready (to customer)
- `orderCalling` - Customer is being called (to customer)
- `orderExpiringSoon` - Order will expire soon (to customer)
- `orderExpired` - Order expired (to customer)
- `orderFinished` - Order completed (to customer)
