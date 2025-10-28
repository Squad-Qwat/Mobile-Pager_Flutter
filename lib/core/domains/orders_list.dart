import 'dart:math'; // To generate random phone number with Random()
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_pager_flutter/core/dateformat/date_format_base.dart';

class CustomerInfo 
{
  final String? name;
  final int? phone; // Menggunakan angka agar sesuai dengan yang di dummy
  final String? email;
  final int? tableNumber; // Menggunakan angka agar sesuai dengan yang di dummy

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

  int? getPhoneNumber() => phone;

  Map<String, dynamic> toMap() => {'name': name, 'phone': phone, 'email': email, 'tableNumber': tableNumber};
}

class RingingInfo 
{
  final int attempts;
  final DateTime? lastRingAt;
  final DateTime? nextRingAt;
  final bool isRinging;
  final DateTime? ringStartedAt;
  final DateTime? ringEndsAt;

  RingingInfo(
  {
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
      isRinging: data['isRinging'] ?? false,
      lastRingAt: data['lastRingAt'] != null ? (data['lastRingAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() => {'attempts': attempts, 'isRinging': isRinging};

  String getRingingStatus() 
  {
    if (isRinging) {return 'Sedang Memanggil';}
    if (attempts > 0) {return 'Sudah Dipanggil';}
    return 'Belum Dipanggil';
  }
}

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
      timestamp: data['timestamp'] != null ? (data['timestamp'] as Timestamp).toDate() : DateTime.now(),
      distanceFromMerchant: data['distanceFromMerchant'] ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() => {'latitude': latitude, 'longitude': longitude};

  String getFormattedDistance() 
  {
    if (distanceFromMerchant < 1000) {return '${distanceFromMerchant.toStringAsFixed(0)} m';}
    return '${(distanceFromMerchant / 1000).toStringAsFixed(1)} km';
  }
}

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
      quantity: data['quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {'name': name, 'quantity': quantity};
}

class Orders 
{
  final String orderId;
  final int queueNumber;
  final CustomerInfo customer;
  final String status;
  final DateTime createdAt;
  final DateTime? readyAt;
  final DateTime? expiresAt;
  final String merchantId;
  final String customerId;
  final String customerType;
  final RingingInfo ringing;
  final DateTime updatedAt;
  final DateTime? processingAt;
  final DateTime? pickedUpAt;
  final DateTime? finishedAt;
  final String? notes;
  final String? cancelReason;
  final ScanLocation? scanLocation;

  Orders({
    required this.orderId,
    required this.queueNumber,
    required this.customer,
    required this.status,
    required this.createdAt,
    this.readyAt,
    this.expiresAt,
    required this.merchantId,
    required this.customerId,
    required this.customerType,
    required this.ringing,
    required this.updatedAt,
    this.processingAt,
    this.pickedUpAt,
    this.finishedAt,
    this.notes,
    this.cancelReason,
    this.scanLocation,
  });

  String getRemainingTime() 
  {
    if (expiresAt == null || status != 'ready') {return '-';}
    final now = DateTime.now();
    final remaining = expiresAt!.difference(now);
    if (remaining.isNegative) {return 'Waktu Habis';}
    if (remaining.inHours > 0) {return '${remaining.inHours}j ${remaining.inMinutes % 60}m';}
    return '${remaining.inMinutes}m';
  }

  String getFormattedQueueNumber() => '#${queueNumber.toString().padLeft(3, '0')}';

  String getStatusText() 
  {
    switch (status) 
    {
      case 'waiting':
        return 'Menunggu Konfirmasi';
      case 'processing':
        return 'Sedang Diproses';
      case 'ready':
        return 'Siap Diambil';
      case 'picked_up':
        return 'Sudah Diambil';
      case 'finished':
        return 'Selesai';
      case 'expired':
        return 'Kadaluarsa';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  String getFormattedDate() => formatDate(createdAt, [dd, ' ', MM, ' ', yyyy]);

  String getFormattedTime(DateTime? date) 
  {
    if (date == null){return '-';}
    return formatDate(date, [HH, ':', nn, ':', ss]);
  }

  String getWaitingTime() 
  {
    if (readyAt == null) {return '-';}
    final waiting = readyAt!.difference(createdAt);
    if (waiting.inMinutes <= 0) {return 'kurang dari 1m';}
    if (waiting.inHours > 0) {return '${waiting.inHours}j ${waiting.inMinutes % 60}m';}
    return '${waiting.inMinutes}m';
  }

  bool get canBeCancelled => status == 'processing' || status == 'ready';
}

// Independent function, to be called in another code.
int? generateNumber()
{
  Random randNumber = Random();
  final bool hasPhone = randNumber.nextDouble() > 0.6; // 40% chance of having a phone
  final int? randomPhone = hasPhone ? (08000000000 + randNumber.nextInt(999999999)) : null;
  return randomPhone;
}