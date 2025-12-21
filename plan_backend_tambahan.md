# Rencana Backend Tambahan untuk Mobile Pager Flutter

## Masalah yang Perlu Diselesaikan dengan Backend

### 1. **Queue Number Increment Issue**
**Masalah Saat Ini:**
- Queue number tidak increment dengan benar karena query Firestore tanpa composite index
- Solusi client-side (fetch semua + loop manual) sudah diimplementasikan tapi belum optimal
- Potensi race condition jika 2+ customer scan bersamaan

**Solusi Backend:**
- Gunakan Cloud Functions atau VPS backend untuk handle queue number generation secara atomic
- Increment counter di server-side dengan transaction

### 2. **Notifikasi Saat App Closed**
**Masalah Saat Ini:**
- Flutter tidak bisa menjalankan background service saat app di-kill
- Notifikasi vibration + sound hanya bekerja saat app running (foreground/background)
- Customer tidak mendapat notifikasi jika app tertutup

**Solusi Backend:**
- Gunakan Firebase Cloud Functions untuk trigger FCM notifications
- Ketika merchant ubah status → Cloud Function → Send FCM → Customer dapat notifikasi

### 3. **Real-time Sync & Performance**
**Masalah Potensial:**
- Fetch semua active pagers untuk cari max queue number (tidak efisien untuk scale besar)
- Race condition pada concurrent scans

**Solusi Backend:**
- Centralized queue management di server
- Atomic operations untuk prevent race conditions

---

## Opsi Backend

### **Opsi 1: Firebase Cloud Functions (Recommended untuk MVP)**

#### Keuntungan:
✅ Terintegrasi langsung dengan Firebase/Firestore
✅ Auto-scaling (tidak perlu manage server)
✅ Mudah deploy dan maintain
✅ FCM notification built-in
✅ Free tier cukup untuk testing

#### Kekurangan:
❌ Butuh upgrade ke Firebase Blaze Plan (pay-as-you-go)
❌ Cold start latency pada free tier
❌ Biaya bisa mahal jika traffic tinggi

#### Biaya Estimasi:
- **Free Tier**: 2 juta invocations/bulan, 400K GB-seconds, 200K CPU-seconds
- **Paid**: $0.40 per juta invocations setelah free tier
- **Estimasi untuk 1000 users/day**: ~$5-10/bulan

#### Implementasi:

**File: `functions/index.js`**
```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// 1. Auto-increment Queue Number (Atomic)
exports.assignQueueNumber = functions.firestore
  .document('active_pagers/{pagerId}')
  .onCreate(async (snap, context) => {
    const pagerData = snap.data();
    const merchantId = pagerData.merchantId;

    // Use Firestore transaction for atomic increment
    const counterRef = admin.firestore()
      .collection('queue_counters')
      .doc(merchantId);

    return admin.firestore().runTransaction(async (transaction) => {
      const counterDoc = await transaction.get(counterRef);

      // Reset counter daily
      const today = new Date().toISOString().split('T')[0];
      const lastDate = counterDoc.data()?.lastDate;

      let newCount = 1;
      if (lastDate === today) {
        newCount = (counterDoc.data()?.count || 0) + 1;
      }

      // Update counter
      transaction.set(counterRef, {
        count: newCount,
        lastDate: today
      });

      // Update pager with queue number
      transaction.update(snap.ref, { queueNumber: newCount });

      return newCount;
    });
  });

// 2. Send FCM Notification on Status Change
exports.sendPagerNotification = functions.firestore
  .document('active_pagers/{pagerId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    // Check if status changed to 'ringing'
    if (before.status !== 'ringing' && after.status === 'ringing') {
      const customerId = after.customerId;

      // Get customer's FCM token
      const userDoc = await admin.firestore()
        .collection('users')
        .doc(customerId)
        .get();

      const fcmToken = userDoc.data()?.fcmToken;

      if (!fcmToken) {
        console.log('No FCM token for user:', customerId);
        return null;
      }

      // Get merchant name
      const merchantDoc = await admin.firestore()
        .collection('merchants')
        .doc(after.merchantId)
        .get();

      const merchantName = merchantDoc.data()?.businessName || 'Merchant';

      // Send notification
      const message = {
        token: fcmToken,
        notification: {
          title: `📞 ${merchantName} memanggil Anda`,
          body: `Antrian ${after.queueNumber} • ${after.displayId} - Pesanan siap!`
        },
        android: {
          priority: 'high',
          notification: {
            channelId: 'pager_call_channel',
            priority: 'max',
            sound: 'default',
            vibrationPattern: [0, 1000, 500, 1000, 500, 1000]
          }
        },
        data: {
          pagerId: context.params.pagerId,
          status: 'ringing',
          merchantName: merchantName
        }
      };

      return admin.messaging().send(message);
    }

    return null;
  });
```

**Deploy:**
```bash
cd functions
npm install
firebase deploy --only functions
```

---

### **Opsi 2: VPS Backend (Node.js + Express + Firestore Listener)**

#### Keuntungan:
✅ Full control atas server
✅ Biaya tetap bulanan (lebih predictable)
✅ Bisa host multiple services
✅ **Realtime listener** - auto-trigger saat status berubah
✅ Tidak tergantung Firebase pricing

#### Kekurangan:
❌ Harus manage server sendiri (security, updates, scaling)
❌ Butuh setup monitoring & logging
❌ Tidak auto-scaling
❌ Perlu handle Firestore admin SDK setup

#### Biaya Estimasi VPS:
- **Railway (Free Tier)**: 500 jam/bulan (gratis untuk testing)
- **Render (Free Tier)**: 750 jam/bulan (gratis untuk testing)
- **DigitalOcean Droplet**: $6-12/bulan (1-2GB RAM)
- **Vultr**: $5-10/bulan

#### Struktur Folder Project:
```
pager-notification-server/
├── src/
│   ├── index.js              # Entry point
│   ├── services/
│   │   └── fcmService.js     # FCM notification logic
│   ├── listeners/
│   │   └── firestoreListener.js  # Realtime status listener
│   └── routes/
│       └── notificationRoutes.js # Optional API endpoints
├── serviceAccountKey.json    # Firebase Admin credentials
├── .env
├── package.json
└── .gitignore
```

#### Struktur FCM Token di Firestore:
```
fcm_tokens/
  └── {userId}/
        ├── token: "fcm_token_string"
        └── updatedAt: Timestamp
```

#### Implementasi:

**File: `.env`**
```env
PORT=3000
FIREBASE_PROJECT_ID=your-project-id
```

**File: `src/index.js`**
```javascript
require('dotenv').config();
const express = require('express');
const admin = require('firebase-admin');
const { startFirestoreListener } = require('./listeners/firestoreListener');

// Initialize Firebase Admin
const serviceAccount = require('../serviceAccountKey.json');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: process.env.FIREBASE_PROJECT_ID,
});

const app = express();
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
  
  // Start Firestore realtime listener (auto-detect status changes)
  startFirestoreListener();
});
```

**File: `src/services/fcmService.js`**
```javascript
const admin = require('firebase-admin');
const db = admin.firestore();
const messaging = admin.messaging();

// Get FCM token from Firestore
async function getFCMToken(userId) {
  try {
    const tokenDoc = await db.collection('fcm_tokens').doc(userId).get();
    return tokenDoc.exists ? tokenDoc.data().token : null;
  } catch (error) {
    console.error('Error getting FCM token:', error);
    return null;
  }
}

// Send FCM notification
async function sendNotificationToUser(userId, notification, data = {}) {
  const token = await getFCMToken(userId);
  if (!token) return { success: false, error: 'No FCM token' };

  const message = {
    token: token,
    notification: {
      title: notification.title,
      body: notification.body,
    },
    data: { ...data, click_action: 'FLUTTER_NOTIFICATION_CLICK' },
    android: {
      priority: 'high',
      notification: {
        channelId: 'pager_call_channel',
        priority: 'max',
        sound: 'default',
      },
    },
  };

  try {
    const response = await messaging.send(message);
    console.log('✅ FCM sent:', response);
    return { success: true, messageId: response };
  } catch (error) {
    console.error('❌ FCM error:', error);
    return { success: false, error: error.message };
  }
}

module.exports = { getFCMToken, sendNotificationToUser };
```

**File: `src/listeners/firestoreListener.js`** ⭐ PENTING
```javascript
const admin = require('firebase-admin');
const { sendNotificationToUser } = require('../services/fcmService');

const db = admin.firestore();
const lastKnownStatus = new Map();

function startFirestoreListener() {
  console.log('🔔 Starting Firestore listener for active_pagers...');

  // Realtime listener - auto-triggers on any change
  db.collection('active_pagers').onSnapshot(
    (snapshot) => {
      snapshot.docChanges().forEach(async (change) => {
        const pager = { ...change.doc.data(), pagerId: change.doc.id };

        if (change.type === 'modified') {
          const oldStatus = lastKnownStatus.get(pager.pagerId);
          const newStatus = pager.status;

          lastKnownStatus.set(pager.pagerId, newStatus);

          if (oldStatus && oldStatus !== newStatus) {
            console.log(`📊 Status: ${pager.pagerId} - ${oldStatus} → ${newStatus}`);
            await handleStatusChange(pager, oldStatus, newStatus);
          }
        } else if (change.type === 'added') {
          lastKnownStatus.set(pager.pagerId, pager.status);
        } else if (change.type === 'removed') {
          lastKnownStatus.delete(pager.pagerId);
        }
      });
    },
    (error) => console.error('❌ Firestore listener error:', error)
  );
}

async function handleStatusChange(pager, oldStatus, newStatus) {
  const customerId = pager.customerId;
  if (!customerId) return;

  // Get merchant name
  let merchantName = 'Merchant';
  try {
    const merchantDoc = await db.collection('merchants').doc(pager.merchantId).get();
    if (merchantDoc.exists) {
      const data = merchantDoc.data();
      merchantName = data.businessName || data.name || 'Merchant';
    }
  } catch (e) {}

  // Send notification based on new status
  switch (newStatus) {
    case 'ringing':
      console.log(`📳 PAGER CALL: ${pager.queueNumber}`);
      await sendNotificationToUser(customerId, {
        title: `📞 ${merchantName} memanggil Anda`,
        body: `Antrian ${pager.queueNumber} - Pesanan siap!`,
      }, { type: 'pager_call', pagerId: pager.pagerId });
      break;

    case 'ready':
      await sendNotificationToUser(customerId, {
        title: '✅ Pesanan Siap Diambil!',
        body: `${merchantName} - Antrian ${pager.queueNumber}`,
      }, { type: 'order_ready', pagerId: pager.pagerId });
      break;

    case 'finished':
      await sendNotificationToUser(customerId, {
        title: 'Terima Kasih!',
        body: `Pesanan ${pager.queueNumber} selesai.`,
      }, { type: 'order_finished', pagerId: pager.pagerId });
      break;

    case 'expired':
      await sendNotificationToUser(customerId, {
        title: 'Pesanan Kadaluarsa',
        body: `Antrian ${pager.queueNumber} telah kadaluarsa.`,
      }, { type: 'order_expired', pagerId: pager.pagerId });
      break;
  }
}

module.exports = { startFirestoreListener };
```

**Deploy ke Railway (Gratis):**
```bash
# Install Railway CLI
npm install -g @railway/cli

# Login dan deploy
railway login
railway init
railway up

# Set environment variables di Railway dashboard
# FIREBASE_PROJECT_ID=your-project-id
```

**Deploy di VPS (Berbayar):**
```bash
# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Clone & setup
git clone <your-repo>
cd pager-notification-server
npm install

# Use PM2 untuk keep alive
npm install -g pm2
pm2 start src/index.js
pm2 startup
pm2 save
```

---

### **Opsi 3: Hybrid (Firebase + Lightweight Backend)**

Gunakan Firebase Cloud Functions untuk notification, tapi VPS untuk queue management jika butuh custom logic kompleks.

---

## Rekomendasi

### Untuk Testing & MVP (0-1000 users):
**Gunakan Firebase Cloud Functions**
- Paling cepat implement
- Auto-scaling
- Maintenance minimal
- Free tier cukup untuk testing

### Untuk Production (1000+ users):
**Mulai dengan Firebase, migrate ke VPS jika:**
- Biaya Firebase > $50/bulan
- Butuh custom logic kompleks
- Ingin full control

---

## Langkah Implementasi

### Phase 1: Fix Queue Number (Priority)
1. ✅ Implementasi client-side solution (sudah selesai)
2. 🔄 Deploy Firebase Cloud Functions untuk atomic queue increment
3. Update Flutter app untuk call Cloud Function

### Phase 2: Fix Background Notifications
1. Deploy Cloud Function untuk FCM notifications
2. Update Flutter app untuk register FCM token
3. Test notification saat app closed

### Phase 3: Optimization
1. Monitor performance & costs
2. Optimize queries dengan composite indexes
3. Consider migration ke VPS jika perlu

---

## Estimasi Waktu & Biaya

| Task | Time | Cost (Monthly) |
|------|------|----------------|
| Setup Firebase Cloud Functions | 2-4 jam | Free tier (testing) |
| Implement Queue Atomic Increment | 1-2 jam | ~$5-10 (production) |
| Implement FCM Notifications | 2-3 jam | Included |
| Testing & Debugging | 2-4 jam | - |
| **Total** | **1-2 hari** | **$5-10/bulan** |

### Alternatif VPS:
| Task | Time | Cost (Monthly) |
|------|------|----------------|
| Setup VPS & Node.js | 2-3 jam | $5-12 |
| Implement API Endpoints | 3-4 jam | - |
| Setup PM2 & Nginx | 1-2 jam | - |
| Testing & Debugging | 2-4 jam | - |
| **Total** | **2-3 hari** | **$5-12/bulan** |

---

## Catatan Penting

⚠️ **Untuk saat ini**, queue number issue kemungkinan bukan karena butuh backend, tapi karena:
1. **Pager sudah finished/expired** tidak dihitung dalam query
2. Atau ada error di Firestore query yang tidak terdeteksi

💡 **Rekomendasi**:
- Cek log Firestore untuk melihat apakah ada error
- Verifikasi bahwa pager dengan queueNumber masih ada di database
- Test dengan 2 customer berbeda scan 2 QR code berbeda
- Jika masih issue, baru implement backend solution

---

## Kontak & Support

Jika butuh bantuan implementasi:
- Firebase Cloud Functions: https://firebase.google.com/docs/functions
- Firebase Admin SDK: https://firebase.google.com/docs/admin/setup
- FCM Documentation: https://firebase.google.com/docs/cloud-messaging

---

**Dibuat:** 2025-12-19
**Direvisi:** 2025-12-21
**Status:** Planning Phase → Ready for Implementation
**Next Step:** Deploy Express.js server dengan Firestore Listener ke Railway (gratis)
