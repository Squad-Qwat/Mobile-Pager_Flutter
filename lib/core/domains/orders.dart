import 'package:cloud_firestore/cloud_firestore.dart';

/// Model untuk menampung data lengkap order di DetailHistoryPage
class Orders 
{
  final String orderId;
  final int queueNumber;

  // References
  final String merchantId;
  final String customerId;
  final String customerType; // registered | guest

  // Customer Info
  final CustomerInfo customer;

  // Location verification
  final ScanLocation? scanLocation;

  // Order items (optional - for future)
  final List<OrderItem>? items;

  // Status lifecycle
  final String status;

  // Timestamps
  final DateTime createdAt;
  final DateTime? processingAt;
  final DateTime? readyAt;
  final DateTime? pickedUpAt;
  final DateTime? finishedAt;
  final DateTime? expiredAt;

  // Expiry logic
  final DateTime? expiresAt;

  // Ringing system
  final RingingInfo ringing;

  // Metadata
  final String? notes;
  final String? cancelReason;
  final DateTime updatedAt;

  Orders({
    required this.orderId,
    required this.queueNumber,
    required this.merchantId,
    required this.customerId,
    required this.customerType,
    required this.customer,
    this.scanLocation,
    this.items,
    required this.status,
    required this.createdAt,
    this.processingAt,
    this.readyAt,
    this.pickedUpAt,
    this.finishedAt,
    this.expiredAt,
    this.expiresAt,
    required this.ringing,
    this.notes,
    this.cancelReason,
    required this.updatedAt,
  });

  /// Factory constructor dari Firestore document
  factory Orders.fromFirestore(DocumentSnapshot doc) 
  {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Orders._fromMap(data, doc.id);
  }

  /// Factory constructor dari Map
  factory Orders.fromMap(Map<String, dynamic> data, String docId) {return Orders._fromMap(data, docId);}

  /// Private helper untuk parsing data
  static Orders _fromMap(Map<String, dynamic> data, String docId) 
  {
    return Orders(
      orderId: docId,
      queueNumber: data['queueNumber'] ?? 0,
      merchantId: data['merchantId'] ?? '',
      customerId: data['customerId'] ?? '',
      customerType: data['customerType'] ?? 'guest',
      customer: CustomerInfo.fromMap(data['customer'] ?? {}),
      scanLocation: data['scanLocation'] != null ? ScanLocation.fromMap(data['scanLocation']) : null,
      items: data['items'] != null ? (data['items'] as List).map((item) => OrderItem.fromMap(item)).toList() : null,
      status: data['status'] ?? 'waiting',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      processingAt: data['processingAt'] != null ? (data['processingAt'] as Timestamp).toDate() : null,
      readyAt: data['readyAt'] != null ? (data['readyAt'] as Timestamp).toDate() : null,
      pickedUpAt: data['pickedUpAt'] != null ? (data['pickedUpAt'] as Timestamp).toDate() : null,
      finishedAt: data['finishedAt'] != null ? (data['finishedAt'] as Timestamp).toDate() : null,
      expiredAt: data['expiredAt'] != null ? (data['expiredAt'] as Timestamp).toDate() : null,
      expiresAt: data['expiresAt'] != null ? (data['expiresAt'] as Timestamp).toDate() : null,
      ringing: RingingInfo.fromMap(data['ringing'] ?? {}),
      notes: data['notes'],
      cancelReason: data['cancelReason'],
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Convert ke Map untuk Firestore
  Map<String, dynamic> toMap() 
  {
    return 
    {
      'orderId': orderId,
      'queueNumber': queueNumber,
      'merchantId': merchantId,
      'customerId': customerId,
      'customerType': customerType,
      'customer': customer.toMap(),
      'scanLocation': scanLocation?.toMap(),
      'items': items?.map((item) => item.toMap()).toList(),
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'processingAt': processingAt != null ? Timestamp.fromDate(processingAt!) : null,
      'readyAt': readyAt != null ? Timestamp.fromDate(readyAt!) : null,
      'pickedUpAt': pickedUpAt != null ? Timestamp.fromDate(pickedUpAt!) : null,
      'finishedAt': finishedAt != null ? Timestamp.fromDate(finishedAt!) : null,
      'expiredAt': expiredAt != null ? Timestamp.fromDate(expiredAt!) : null,
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'ringing': ringing.toMap(),
      'notes': notes,
      'cancelReason': cancelReason,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Get formatted queue number (sama seperti History)
  String getFormattedQueueNumber() 
  {
    String letter = String.fromCharCode(65 + (queueNumber ~/ 100));
    String number = (queueNumber % 100).toString().padLeft(2, '0');
    return 'Kursi: $letter-$number';
  }

  /// Get status text bahasa Indonesia
  String getStatusText() 
  {
    switch (status) 
    {
      case 'waiting':
        return 'Menunggu';
      case 'processing':
        return 'Diproses';
      case 'ready':
        return 'Siap Diambil';
      case 'picked_up':
        return 'Sudah Diambil';
      case 'finished':
        return 'Selesai';
      case 'expired':
        return 'Kedaluwarsa';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return 'Tidak Diketahui';
    }
  }

  /// Get formatted date
  String getFormattedDate() 
  {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${createdAt.day} ${months[createdAt.month - 1]} ${createdAt.year}';
  }

  /// Get formatted time
  String getFormattedTime(DateTime? dateTime) 
  {
    if (dateTime == null){return '-';}
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Calculate duration between two timestamps
  String getDuration(DateTime? start, DateTime? end) 
  {
    if (start == null || end == null){ return '-';}

    final duration = end.difference(start);
    if (duration.inHours > 0) {return '${duration.inHours}j ${duration.inMinutes % 60}m';}
    return '${duration.inMinutes}m';
  }

  /// Get waiting time (createdAt to readyAt)
  String getWaitingTime() {return getDuration(createdAt, readyAt);}

  /// Get remaining expiry time
  String getRemainingTime() 
  {
    if (expiresAt == null || status != 'ready') {return '-';}

    final now = DateTime.now();
    if (now.isAfter(expiresAt!)) {return 'Kedaluwarsa';}

    final remaining = expiresAt!.difference(now);
    if (remaining.inHours > 0) {return '${remaining.inHours}j ${remaining.inMinutes % 60}m';}
    return '${remaining.inMinutes}m';
  }

  /// Check if order is active
  bool get isActive {return !['finished', 'expired', 'cancelled'].contains(status);}

  /// Check if order can be cancelled
  bool get canBeCancelled {return ['waiting', 'processing'].contains(status);}

  @override
  String toString() {return 'Orders(orderId: $orderId, queueNumber: $queueNumber, status: $status)';}
}

/// Model untuk customer info
class CustomerInfo 
{
  final String? name;
  final String? phone;
  final String? email;
  final String? tableNumber;

  CustomerInfo({this.name, this.phone, this.email, this.tableNumber});

  factory CustomerInfo.fromMap(Map<String, dynamic> data) 
  {
    return CustomerInfo(
      name: data['name'],
      phone: data['phone'],
      email: data['email'],
      tableNumber: data['tableNumber'],
    );
  }

  Map<String, dynamic> toMap() 
  {
    return 
    {
      'name': name,
      'phone': phone,
      'email': email,
      'tableNumber': tableNumber,
    };
  }
}

/// Model untuk scan location
class ScanLocation 
{
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double distanceFromMerchant;

  ScanLocation({required this.latitude, required this.longitude, required this.timestamp, required this.distanceFromMerchant});

  factory ScanLocation.fromMap(Map<String, dynamic> data) 
  {
    return ScanLocation(
      latitude: data['latitude'] ?? 0.0,
      longitude: data['longitude'] ?? 0.0,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      distanceFromMerchant: (data['distanceFromMerchant'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() 
  {
    return 
    {
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': Timestamp.fromDate(timestamp),
      'distanceFromMerchant': distanceFromMerchant,
    };
  }

  String getFormattedDistance() 
  {
    if (distanceFromMerchant < 1000) {return '${distanceFromMerchant.toStringAsFixed(0)} m';}
    return '${(distanceFromMerchant / 1000).toStringAsFixed(1)} km';
  }
}

/// Model untuk order items (future feature)
class OrderItem 
{
  final String name;
  final int quantity;
  final String? notes;

  OrderItem({required this.name, required this.quantity, this.notes});

  factory OrderItem.fromMap(Map<String, dynamic> data) 
  {
    return OrderItem(
      name: data['name'] ?? '',
      quantity: data['quantity'] ?? 1,
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toMap() {return {'name': name, 'quantity': quantity, 'notes': notes};}
}

/// Model untuk ringing info
class RingingInfo 
{
  final int attempts;
  final DateTime? lastRingAt;
  final DateTime? nextRingAt;
  final bool isRinging;
  final DateTime? ringStartedAt;
  final DateTime? ringEndsAt;

  RingingInfo({
    required this.attempts,
    this.lastRingAt,
    this.nextRingAt,
    required this.isRinging,
    this.ringStartedAt,
    this.ringEndsAt,
  });

  factory RingingInfo.fromMap(Map<String, dynamic> data) 
  {
    return RingingInfo(
      attempts: data['attempts'] ?? 0,
      lastRingAt: data['lastRingAt'] != null ? (data['lastRingAt'] as Timestamp).toDate() : null,
      nextRingAt: data['nextRingAt'] != null ? (data['nextRingAt'] as Timestamp).toDate() : null,
      isRinging: data['isRinging'] ?? false,
      ringStartedAt: data['ringStartedAt'] != null ? (data['ringStartedAt'] as Timestamp).toDate() : null,
      ringEndsAt: data['ringEndsAt'] != null ? (data['ringEndsAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() 
  {
    return 
    {
      'attempts': attempts,
      'lastRingAt': lastRingAt != null ? Timestamp.fromDate(lastRingAt!) : null,
      'nextRingAt': nextRingAt != null ? Timestamp.fromDate(nextRingAt!) : null,
      'isRinging': isRinging,
      'ringStartedAt': ringStartedAt != null? Timestamp.fromDate(ringStartedAt!) : null,
      'ringEndsAt': ringEndsAt != null ? Timestamp.fromDate(ringEndsAt!) : null,
    };
  }

  String getRingingStatus() 
  {
    if (attempts >= 3) {return 'Maksimal panggilan tercapai';}
    if (isRinging) {return 'Sedang berdering';}
    if (lastRingAt != null) {return 'Dipanggil ${attempts}x';}
    return 'Belum dipanggil';
  }
}