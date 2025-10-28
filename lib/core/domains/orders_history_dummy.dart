import 'package:mobile_pager_flutter/core/domains/orders.dart';
import 'package:mobile_pager_flutter/features/pager_history/domain/history.dart';

class DummyDataService 
{
  static const String currentUserId = 'USER-001';

  static List<History> getDummyHistory() 
  {
    final now = DateTime.now();

    return <History>[
      History(
        orderId: 'ORD-001',
        merchantId: 'MERCH-001',
        queueNumber: 'Kursi: A-12',
        createdAt: now.subtract(const Duration(hours: 2)),
        status: 'ready',
        businessName: 'Kopi Kenangan',
        merchantPhotoURL: null,
      ),
      History(
        orderId: 'ORD-002',
        merchantId: 'MERCH-002',
        queueNumber: 'Kursi: B-05',
        createdAt: now.subtract(const Duration(days: 1)),
        status: 'finished',
        businessName: 'Starbucks',
        merchantPhotoURL: null,
      ),
      History(
        orderId: 'ORD-003',
        merchantId: 'MERCH-001',
        queueNumber: 'Kursi: C-21',
        createdAt: now.subtract(const Duration(days: 2)),
        status: 'processing',
        businessName: 'Kopi Kenangan',
        merchantPhotoURL: null,
      ),
      History(
        orderId: 'ORD-004',
        merchantId: 'MERCH-003',
        queueNumber: 'Kursi: D-15',
        createdAt: now.subtract(const Duration(days: 3)),
        status: 'cancelled',
        businessName: 'Fore Coffee',
        merchantPhotoURL: null,
      ),
      History(
        orderId: 'ORD-005',
        merchantId: 'MERCH-002',
        queueNumber: 'Kursi: E-03',
        createdAt: now.subtract(const Duration(days: 4)),
        status: 'expired',
        businessName: 'Starbucks',
        merchantPhotoURL: null,
      ),
      History(
        orderId: 'ORD-006',
        merchantId: 'MERCH-001',
        queueNumber: 'Kursi: F-10',
        createdAt: now.subtract(const Duration(days: 5)),
        status: 'waiting',
        businessName: 'Kopi Kenangan',
        merchantPhotoURL: null,
      ),
    ];
  }

  static Orders? getDummyOrderDetail(String orderId) 
  {
    final now = DateTime.now();

    final dummyOrders = 
    {
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
        items: <OrderItem>[
          OrderItem(
            name: 'Kopi Susu', 
            quantity: 1, 
            notes: 'Less sugar'
          ),
          OrderItem(
            name: 'Croissant', 
            quantity: 2, 
            notes: null
          ),
        ],
        status: 'ready',
        createdAt: now.subtract(const Duration(hours: 2)),
        processingAt: now.subtract(const Duration(
          hours: 2, 
          minutes: -5
        )),
        readyAt: now.subtract(const Duration(
          hours: 1, 
          minutes: 30
        )),
        pickedUpAt: null,
        finishedAt: null,
        expiredAt: null,
        expiresAt: now.add(const Duration(
          hours: 1, 
          minutes: 30
        )),
        ringing: RingingInfo(
          attempts: 2,
          lastRingAt: now.subtract(const Duration(minutes: 10)),
          nextRingAt: now.add(const Duration(minutes: 5)),
          isRinging: false,
          ringStartedAt: null,
          ringEndsAt: null,
        ),
        notes: 'Mohon ambil di counter utama',
        cancelReason: null,
        updatedAt: now.subtract(const Duration(minutes: 10)),
      ),

      'ORD-002': Orders(
        orderId: 'ORD-002',
        queueNumber: 5,
        merchantId: 'MERCH-002',
        customerId: currentUserId,
        customerType: 'registered',
        customer: CustomerInfo(
          name: 'John Doe',
          phone: '+6281234567890',
          tableNumber: 'B3',
        ),
        scanLocation: ScanLocation(
          latitude: -6.900977,
          longitude: 107.618481,
          timestamp: now.subtract(const Duration(days: 1)),
          distanceFromMerchant: 180,
        ),
        status: 'finished',
        createdAt: now.subtract(const Duration(days: 1)),
        processingAt: now.subtract(const Duration(
          days: 1, 
          hours: -1
        )),
        readyAt: now.subtract(const Duration(
          days: 1, 
          hours: -2
        )),
        pickedUpAt: now.subtract(const Duration(
          days: 1, 
          hours: -2, 
          minutes: -10
        )),
        finishedAt: now.subtract(const Duration(
          days: 1, 
          hours: -2, 
          minutes: -10
        )),
        expiredAt: null,
        expiresAt: null,
        ringing: RingingInfo(
          attempts: 1,
          lastRingAt: now.subtract(const Duration(
            days: 1, 
            hours: -2
          )),
          nextRingAt: null,
          isRinging: false,
          ringStartedAt: null,
          ringEndsAt: null,
        ),
        notes: null,
        cancelReason: null,
        updatedAt: now.subtract(const Duration(
          days: 1, 
          hours: -2, 
          minutes: -10
        )),
      ),

      'ORD-003': Orders(
        orderId: 'ORD-003',
        queueNumber: 21,
        merchantId: 'MERCH-001',
        customerId: currentUserId,
        customerType: 'guest',
        customer: CustomerInfo(
          name: 'Guest User', 
          phone: null
        ),
        scanLocation: ScanLocation(
          latitude: -6.900977,
          longitude: 107.618481,
          timestamp: now.subtract(const Duration(days: 2)),
          distanceFromMerchant: 320,
        ),
        status: 'processing',
        createdAt: now.subtract(const Duration(days: 2)),
        processingAt: now.subtract(const Duration(
          days: 2, 
          hours: -1
        )),
        readyAt: null,
        pickedUpAt: null,
        finishedAt: null,
        expiredAt: null,
        expiresAt: null,
        ringing: RingingInfo(
          attempts: 0,
          lastRingAt: null,
          nextRingAt: null,
          isRinging: false,
          ringStartedAt: null,
          ringEndsAt: null,
        ),
        notes: null,
        cancelReason: null,
        updatedAt: now.subtract(const Duration(
          days: 2, 
          hours: -1
        )),
      ),

      'ORD-004': Orders(
        orderId: 'ORD-004',
        queueNumber: 15,
        merchantId: 'MERCH-003',
        customerId: currentUserId,
        customerType: 'registered',
        customer: CustomerInfo(
          name: 'John Doe',
          phone: '+6281234567890',
          tableNumber: 'D1',
        ),
        scanLocation: null,
        status: 'cancelled',
        createdAt: now.subtract(const Duration(days: 3)),
        processingAt: null,
        readyAt: null,
        pickedUpAt: null,
        finishedAt: null,
        expiredAt: null,
        expiresAt: null,
        ringing: RingingInfo(
          attempts: 0,
          lastRingAt: null,
          nextRingAt: null,
          isRinging: false,
          ringStartedAt: null,
          ringEndsAt: null,
        ),
        notes: null,
        cancelReason: 'Stok habis',
        updatedAt: now.subtract(const Duration(
          days: 3, 
          hours: -1
        )),
      ),

      'ORD-005': Orders(
        orderId: 'ORD-005',
        queueNumber: 3,
        merchantId: 'MERCH-002',
        customerId: currentUserId,
        customerType: 'registered',
        customer: CustomerInfo(
          name: 'John Doe', 
          phone: '+6281234567890'
        ),
        scanLocation: ScanLocation(
          latitude: -6.900977,
          longitude: 107.618481,
          timestamp: now.subtract(const Duration(days: 4)),
          distanceFromMerchant: 450,
        ),
        status: 'expired',
        createdAt: now.subtract(const Duration(days: 4)),
        processingAt: now.subtract(const Duration(
          days: 4, 
          hours: -1
        )),
        readyAt: now.subtract(const Duration(
          days: 4, 
          hours: -2
        )),
        pickedUpAt: null,
        finishedAt: null,
        expiredAt: now.subtract(const Duration(
          days: 4, 
          hours: -5
        )),
        expiresAt: now.subtract(const Duration(
          days: 4, 
          hours: -5
        )),
        ringing: RingingInfo(
          attempts: 3,
          lastRingAt: now.subtract(const Duration(
            days: 4, 
            hours: -3
          )),
          nextRingAt: null,
          isRinging: false,
          ringStartedAt: null,
          ringEndsAt: null,
        ),
        notes: null,
        cancelReason: null,
        updatedAt: now.subtract(const Duration(
          days: 4, 
          hours: -5
        )),
      ),

      'ORD-006': Orders(
        orderId: 'ORD-006',
        queueNumber: 10,
        merchantId: 'MERCH-001',
        customerId: currentUserId,
        customerType: 'registered',
        customer: CustomerInfo(
          name: 'John Doe',
          phone: '+6281234567890',
          email: 'john@example.com',
        ),
        scanLocation: ScanLocation(
          latitude: -6.900977,
          longitude: 107.618481,
          timestamp: now.subtract(const Duration(days: 5)),
          distanceFromMerchant: 200,
        ),
        status: 'waiting',
        createdAt: now.subtract(const Duration(days: 5)),
        processingAt: null,
        readyAt: null,
        pickedUpAt: null,
        finishedAt: null,
        expiredAt: null,
        expiresAt: null,
        ringing: RingingInfo(
          attempts: 0,
          lastRingAt: null,
          nextRingAt: null,
          isRinging: false,
          ringStartedAt: null,
          ringEndsAt: null,
        ),
        notes: 'Order baru masuk',
        cancelReason: null,
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
    };

    return dummyOrders[orderId];
  }

  /// Filter dummy history by status
  static List<History> filterHistory(List<History> historyList, String filter) 
  {
    switch (filter) 
    {
      case 'active':
        return historyList.where((h) => ['waiting', 'processing', 'ready', 'picked_up',].contains(h.status)).toList();
      case 'finished':
        return historyList.where((h) => ['finished', 'expired', 'cancelled'].contains(h.status)).toList();
      default:
        return historyList;
    }
  }
}