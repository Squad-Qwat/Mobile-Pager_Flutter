import 'package:cloud_firestore/cloud_firestore.dart';

class History {
  final String orderId;
  final String merchantId;
  final String queueNumber;
  final DateTime createdAt;
  final String status;
  final String? businessName;
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

  factory History.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return History(
      orderId: doc.id,
      merchantId: data['merchantId'] ?? '',
      queueNumber: _formatQueueNumber(data['queueNumber']),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      status: data['status'] ?? 'waiting',
      businessName: data['merchantName'],
      merchantPhotoURL: data['merchantPhotoURL'],
    );
  }

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

  static String _formatQueueNumber(dynamic queueNum) {
    if (queueNum == null) return 'Kursi: -';

    if (queueNum is String) return queueNum;

    int num = queueNum as int;
    String letter = String.fromCharCode(65 + (num ~/ 100));
    String number = (num % 100).toString().padLeft(2, '0');
    return 'Kursi: $letter-$number';
  }

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

  bool get isActive {
    return !['finished', 'expired', 'cancelled'].contains(status);
  }

  @override
  String toString() {
    return 'History(orderId: $orderId, queueNumber: $queueNumber, status: $status, date: ${getFormattedDate()})';
  }
}
