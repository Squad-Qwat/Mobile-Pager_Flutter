import 'package:cloud_firestore/cloud_firestore.dart';

/// Model untuk menampung data history di ListView
/// Hanya berisi data ringkas yang dibutuhkan untuk tampilan list
class History {
  final String orderId;
  final String merchantId;
  final String queueNumber; // Format: "Kursi: A-12"
  final DateTime createdAt;
  final String
  status; // waiting, processing, ready, picked_up, finished, expired, cancelled
  final String? businessName; // Nama merchant
  final String? merchantPhotoURL;

  History({
    required this.orderId,
    required this.merchantId,
    required this.queueNumber,
    required this.createdAt,
    required this.status,
    this.businessName,
    this.merchantPhotoURL,
  });

  /// Factory constructor untuk membuat History dari Firestore document
  factory History.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return History(
      orderId: doc.id,
      merchantId: data['merchantId'] ?? '',
      queueNumber: _formatQueueNumber(data['queueNumber']),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      status: data['status'] ?? 'waiting',
      businessName:
          data['merchantName'], // Optional: perlu join dengan merchants collection
      merchantPhotoURL:
          data['merchantPhotoURL'], // Optional: perlu join dengan merchants collection
    );
  }

  /// Factory constructor untuk membuat History dari Map
  factory History.fromMap(Map<String, dynamic> data, String docId) {
    return History(
      orderId: docId,
      merchantId: data['merchantId'] ?? '',
      queueNumber: _formatQueueNumber(data['queueNumber']),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      status: data['status'] ?? 'waiting',
      businessName: data['merchantName'],
      merchantPhotoURL: data['merchantPhotoURL'],
    );
  }

  /// Convert History ke Map untuk Firestore
  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'merchantId': merchantId,
      'queueNumber': queueNumber,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status,
      'merchantName': businessName,
      'merchantPhotoURL': merchantPhotoURL,
    };
  }

  /// Helper method untuk format queue number
  /// Contoh: 12 -> "Kursi: A-12"
  static String _formatQueueNumber(dynamic queueNum) {
    if (queueNum == null) return 'Kursi: -';

    // Jika sudah dalam format string, return as is
    if (queueNum is String) return queueNum;

    // Jika integer, format dengan prefix
    int num = queueNum as int;
    String letter = String.fromCharCode(65 + (num ~/ 100)); // A, B, C, dst
    String number = (num % 100).toString().padLeft(2, '0');
    return 'Kursi: $letter-$number';
  }

  /// Get status color untuk UI
  String getStatusColor() {
    switch (status) {
      case 'waiting':
        return '#FFA500'; // Orange
      case 'processing':
        return '#2196F3'; // Blue
      case 'ready':
        return '#4CAF50'; // Green
      case 'picked_up':
        return '#8BC34A'; // Light Green
      case 'finished':
        return '#9E9E9E'; // Gray
      case 'expired':
        return '#F44336'; // Red
      case 'cancelled':
        return '#F44336'; // Red
      default:
        return '#9E9E9E'; // Gray
    }
  }

  /// Get status text bahasa Indonesia
  String getStatusText() {
    switch (status) {
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

  /// Get formatted date untuk display
  String getFormattedDate() {
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

  /// Check if order is active (not finished, expired, or cancelled)
  bool get isActive {
    return !['finished', 'expired', 'cancelled'].contains(status);
  }

  @override
  String toString() {
    return 'History(orderId: $orderId, queueNumber: $queueNumber, status: $status, date: ${getFormattedDate()})';
  }
}
