import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_pager_flutter/core/domains/orders_list.dart';
import 'package:mobile_pager_flutter/core/domains/orders_list_dummy.dart';

class OrdersHistory 
{
  final String orderId;
  final String merchantId;
  final String queueNumber;
  final DateTime createdAt;
  final String status;
  final String? businessName; // In our case, we will map Customer Name to this
  final String? merchantPhotoURL;

  OrdersHistory({
    required this.orderId,
    required this.merchantId,
    required this.queueNumber,
    required this.createdAt,
    required this.status,
    this.businessName,
    this.merchantPhotoURL,
  });

  /// Factory to create a History summary from a full Orders object
  factory OrdersHistory.fromOrder(Orders order) 
  {
    return OrdersHistory(
      orderId: order.orderId,
      merchantId: order.merchantId,
      // We map the Order's Pager/Queue number to the History's queueNumber
      // Using Pager number if available, else the formatted queue number
      queueNumber: order.customer.tableNumber != null ? 'PG-${order.customer.tableNumber}' : order.getFormattedQueueNumber(),
      createdAt: order.createdAt,
      status: order.status,
      // Map the customer name to the 'businessName' field to work
      // with the HistoryFilterService's search logic
      businessName: order.customer.name ?? 'Guest',
      merchantPhotoURL: null, // No photo URL available in the Orders model
    );
  }

  factory OrdersHistory.fromFirestore(DocumentSnapshot doc) 
  {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return OrdersHistory(
      orderId: doc.id,
      merchantId: data['merchantId'] ?? '',
      queueNumber: _formatQueueNumber(data['queueNumber']),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      status: data['status'] ?? 'waiting',
      businessName: data['merchantName'],
      merchantPhotoURL: data['merchantPhotoURL'],
    );
  }

  factory OrdersHistory.fromMap(Map<String, dynamic> data, String docId) 
  {
    return OrdersHistory(
      orderId: docId,
      merchantId: data['merchantId'] ?? '',
      queueNumber: _formatQueueNumber(data['queueNumber']),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      status: data['status'] ?? 'waiting',
      businessName: data['merchantName'],
      merchantPhotoURL: data['merchantPhotoURL'],
    );
  }

  Map<String, dynamic> toMap() 
  {
    return 
    {
      'orderId': orderId,
      'merchantId': merchantId,
      'queueNumber': queueNumber,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status,
      'merchantName': businessName,
      'merchantPhotoURL': merchantPhotoURL,
    };
  }

  // Note: This formatting logic is from your customer-facing app example
  // and is different from the merchant-facing data.
  // We keep it for class integrity as requested.
  static String _formatQueueNumber(dynamic queueNum) 
  {
    if (queueNum == null) {return 'Kursi: -';}

    if (queueNum is String) {return queueNum;}

    int num = queueNum as int;
    String letter = String.fromCharCode(65 + (num ~/ 100));
    String number = (num % 100).toString().padLeft(2, '0');
    return 'Kursi: $letter-$number';
  }

  String getStatusColor() 
  {
    switch (status) 
    {
      case 'waiting':
        return '#FFA500'; // Orange
      case 'processing':
        return '#2196F3'; // Blue
      case'ready':
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

  String getFormattedDate() 
  {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli',
      'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];

    return '${createdAt.day} ${months[createdAt.month - 1]} ${createdAt.year}';
  }

  bool get isActive => !['finished', 'expired', 'cancelled'].contains(status);

  @override
  String toString() => 'History(orderId: $orderId, queueNumber: $queueNumber, status: $status, date: ${getFormattedDate()})';
}

final List<OrdersHistory> dummyHistoryList = recentActivitiesData.map((order) => OrdersHistory.fromOrder(order)).toList();