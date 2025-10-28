import 'package:mobile_pager_flutter/core/domains/orders.dart';
import 'package:mobile_pager_flutter/features/pager_history/domain/history.dart';

/// Extended service untuk generate dummy data dengan lebih banyak entries
class ExtendedDummyDataService {
  static const String currentUserId = 'USER-001';

  static List<History> getExtendedDummyHistory() {
    final now = DateTime.now();
    final List<History> historyList = [];

    // Hari ini - 3 entries
    historyList.addAll([
      History(
        orderId: 'ORD-001',
        merchantId: 'MERCH-001',
        queueNumber: 'Kursi: A-12',
        createdAt: now.subtract(const Duration(hours: 2)),
        status: 'finished',
        businessName: 'Kopi Kenangan',
        merchantPhotoURL: null,
      ),
      History(
        orderId: 'ORD-002',
        merchantId: 'MERCH-002',
        queueNumber: 'Kursi: B-05',
        createdAt: now.subtract(const Duration(hours: 4)),
        status: 'finished',
        businessName: 'Starbucks',
        merchantPhotoURL: null,
      ),
      History(
        orderId: 'ORD-003',
        merchantId: 'MERCH-003',
        queueNumber: 'Kursi: C-21',
        createdAt: now.subtract(const Duration(hours: 6)),
        status: 'expired',
        businessName: 'Fore Coffee',
        merchantPhotoURL: null,
      ),
    ]);

    // Kemarin - 2 entries
    historyList.addAll([
      History(
        orderId: 'ORD-004',
        merchantId: 'MERCH-001',
        queueNumber: 'Kursi: D-15',
        createdAt: now.subtract(const Duration(days: 1, hours: 3)),
        status: 'finished',
        businessName: 'Kopi Kenangan',
        merchantPhotoURL: null,
      ),
      History(
        orderId: 'ORD-005',
        merchantId: 'MERCH-004',
        queueNumber: 'Kursi: E-03',
        createdAt: now.subtract(const Duration(days: 1, hours: 8)),
        status: 'cancelled',
        businessName: 'Janji Jiwa',
        merchantPhotoURL: null,
      ),
    ]);

    // Minggu ini - 4 entries
    historyList.addAll([
      History(
        orderId: 'ORD-006',
        merchantId: 'MERCH-002',
        queueNumber: 'Kursi: F-10',
        createdAt: now.subtract(const Duration(days: 3)),
        status: 'finished',
        businessName: 'Starbucks',
        merchantPhotoURL: null,
      ),
      History(
        orderId: 'ORD-007',
        merchantId: 'MERCH-003',
        queueNumber: 'Kursi: G-08',
        createdAt: now.subtract(const Duration(days: 4)),
        status: 'finished',
        businessName: 'Fore Coffee',
        merchantPhotoURL: null,
      ),
      History(
        orderId: 'ORD-008',
        merchantId: 'MERCH-001',
        queueNumber: 'Kursi: H-22',
        createdAt: now.subtract(const Duration(days: 5)),
        status: 'expired',
        businessName: 'Kopi Kenangan',
        merchantPhotoURL: null,
      ),
      History(
        orderId: 'ORD-009',
        merchantId: 'MERCH-004',
        queueNumber: 'Kursi: I-17',
        createdAt: now.subtract(const Duration(days: 6)),
        status: 'finished',
        businessName: 'Janji Jiwa',
        merchantPhotoURL: null,
      ),
    ]);

    // Bulan ini (minggu sebelumnya) - 5 entries
    historyList.addAll([
      History(
        orderId: 'ORD-010',
        merchantId: 'MERCH-002',
        queueNumber: 'Kursi: J-04',
        createdAt: now.subtract(const Duration(days: 10)),
        status: 'finished',
        businessName: 'Starbucks',
        merchantPhotoURL: null,
      ),
      History(
        orderId: 'ORD-011',
        merchantId: 'MERCH-001',
        queueNumber: 'Kursi: K-19',
        createdAt: now.subtract(const Duration(days: 12)),
        status: 'finished',
        businessName: 'Kopi Kenangan',
        merchantPhotoURL: null,
      ),
      History(
        orderId: 'ORD-012',
        merchantId: 'MERCH-003',
        queueNumber: 'Kursi: L-06',
        createdAt: now.subtract(const Duration(days: 15)),
        status: 'cancelled',
        businessName: 'Fore Coffee',
        merchantPhotoURL: null,
      ),
      History(
        orderId: 'ORD-013',
        merchantId: 'MERCH-004',
        queueNumber: 'Kursi: M-13',
        createdAt: now.subtract(const Duration(days: 18)),
        status: 'finished',
        businessName: 'Janji Jiwa',
        merchantPhotoURL: null,
      ),
      History(
        orderId: 'ORD-014',
        merchantId: 'MERCH-002',
        queueNumber: 'Kursi: N-25',
        createdAt: now.subtract(const Duration(days: 20)),
        status: 'expired',
        businessName: 'Starbucks',
        merchantPhotoURL: null,
      ),
    ]);

    // Bulan lalu - 6 entries
    final lastMonth = DateTime(now.year, now.month - 1, 15);
    historyList.addAll([
      History(
        orderId: 'ORD-015',
        merchantId: 'MERCH-001',
        queueNumber: 'Kursi: O-11',
        createdAt: lastMonth,
        status: 'finished',
        businessName: 'Kopi Kenangan',
        merchantPhotoURL: null,
      ),
      History(
        orderId: 'ORD-016',
        merchantId: 'MERCH-003',
        queueNumber: 'Kursi: P-07',
        createdAt: lastMonth.subtract(const Duration(days: 2)),
        status: 'finished',
        businessName: 'Fore Coffee',
        merchantPhotoURL: null,
      ),
      History(
        orderId: 'ORD-017',
        merchantId: 'MERCH-004',
        queueNumber: 'Kursi: Q-20',
        createdAt: lastMonth.subtract(const Duration(days: 5)),
        status: 'finished',
        businessName: 'Janji Jiwa',
        merchantPhotoURL: null,
      ),
      History(
        orderId: 'ORD-018',
        merchantId: 'MERCH-002',
        queueNumber: 'Kursi: R-14',
        createdAt: lastMonth.subtract(const Duration(days: 8)),
        status: 'cancelled',
        businessName: 'Starbucks',
        merchantPhotoURL: null,
      ),
      History(
        orderId: 'ORD-019',
        merchantId: 'MERCH-001',
        queueNumber: 'Kursi: S-09',
        createdAt: lastMonth.subtract(const Duration(days: 12)),
        status: 'finished',
        businessName: 'Kopi Kenangan',
        merchantPhotoURL: null,
      ),
      History(
        orderId: 'ORD-020',
        merchantId: 'MERCH-003',
        queueNumber: 'Kursi: T-16',
        createdAt: lastMonth.subtract(const Duration(days: 15)),
        status: 'expired',
        businessName: 'Fore Coffee',
        merchantPhotoURL: null,
      ),
    ]);

    // Orders yang masih aktif (untuk testing filter status)
    historyList.addAll([
      History(
        orderId: 'ORD-021',
        merchantId: 'MERCH-001',
        queueNumber: 'Kursi: U-01',
        createdAt: now.subtract(const Duration(minutes: 30)),
        status: 'waiting',
        businessName: 'Kopi Kenangan',
        merchantPhotoURL: null,
      ),
      History(
        orderId: 'ORD-022',
        merchantId: 'MERCH-002',
        queueNumber: 'Kursi: V-05',
        createdAt: now.subtract(const Duration(minutes: 45)),
        status: 'processing',
        businessName: 'Starbucks',
        merchantPhotoURL: null,
      ),
      History(
        orderId: 'ORD-023',
        merchantId: 'MERCH-003',
        queueNumber: 'Kursi: W-12',
        createdAt: now.subtract(const Duration(hours: 1)),
        status: 'ready',
        businessName: 'Fore Coffee',
        merchantPhotoURL: null,
      ),
    ]);

    return historyList;
  }

  /// Get order detail (reuse dari dummy service asli)
  static Orders? getDummyOrderDetail(String orderId) {
    final now = DateTime.now();

    // Sample implementation untuk beberapa order
    final Map<String, Orders> orderDetails = {
      'ORD-001': Orders(
        orderId: 'ORD-001',
        queueNumber: 12,
        merchantId: 'MERCH-001',
        customerId: currentUserId,
        customerType: 'registered',
        customer: CustomerInfo(
          name: 'John Doe',
          phone: '+6281234567890',
          email: 'john@example.com',
          tableNumber: 'A5',
        ),
        scanLocation: ScanLocation(
          latitude: -6.900977,
          longitude: 107.618481,
          timestamp: now.subtract(const Duration(hours: 2)),
          distanceFromMerchant: 250,
        ),
        items: [
          OrderItem(name: 'Kopi Susu', quantity: 1, notes: 'Less sugar'),
          OrderItem(name: 'Croissant', quantity: 2, notes: null),
        ],
        status: 'finished',
        createdAt: now.subtract(const Duration(hours: 2)),
        processingAt: now.subtract(const Duration(hours: 2, minutes: -5)),
        readyAt: now.subtract(const Duration(hours: 1, minutes: 30)),
        pickedUpAt: now.subtract(const Duration(hours: 1, minutes: 15)),
        finishedAt: now.subtract(const Duration(hours: 1, minutes: 15)),
        expiredAt: null,
        expiresAt: null,
        ringing: RingingInfo(
          attempts: 1,
          lastRingAt: now.subtract(const Duration(hours: 1, minutes: 30)),
          nextRingAt: null,
          isRinging: false,
          ringStartedAt: null,
          ringEndsAt: null,
        ),
        notes: 'Terima kasih!',
        cancelReason: null,
        updatedAt: now.subtract(const Duration(hours: 1, minutes: 15)),
      ),
    };

    return orderDetails[orderId];
  }
}
