import 'package:cloud_firestore/cloud_firestore.dart';

/// Model untuk statistik customer (non-guest users only)
class CustomerStatsModel {
  final String customerId;
  final String customerName;
  final String customerEmail;
  final int totalOrders;
  final double averageWaitMinutes;
  final DateTime? lastOrderDate;

  CustomerStatsModel({
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    required this.totalOrders,
    required this.averageWaitMinutes,
    this.lastOrderDate,
  });

  factory CustomerStatsModel.fromMap(Map<String, dynamic> map) {
    return CustomerStatsModel(
      customerId: map['customerId'] as String,
      customerName: map['customerName'] as String,
      customerEmail: map['customerEmail'] as String,
      totalOrders: map['totalOrders'] as int,
      averageWaitMinutes: (map['averageWaitMinutes'] as num).toDouble(),
      lastOrderDate: map['lastOrderDate'] != null
          ? (map['lastOrderDate'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'totalOrders': totalOrders,
      'averageWaitMinutes': averageWaitMinutes,
      'lastOrderDate':
          lastOrderDate != null ? Timestamp.fromDate(lastOrderDate!) : null,
    };
  }

  CustomerStatsModel copyWith({
    String? customerId,
    String? customerName,
    String? customerEmail,
    int? totalOrders,
    double? averageWaitMinutes,
    DateTime? lastOrderDate,
  }) {
    return CustomerStatsModel(
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      totalOrders: totalOrders ?? this.totalOrders,
      averageWaitMinutes: averageWaitMinutes ?? this.averageWaitMinutes,
      lastOrderDate: lastOrderDate ?? this.lastOrderDate,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CustomerStatsModel &&
        other.customerId == customerId &&
        other.customerName == customerName &&
        other.customerEmail == customerEmail &&
        other.totalOrders == totalOrders &&
        other.averageWaitMinutes == averageWaitMinutes &&
        other.lastOrderDate == lastOrderDate;
  }

  @override
  int get hashCode {
    return customerId.hashCode ^
        customerName.hashCode ^
        customerEmail.hashCode ^
        totalOrders.hashCode ^
        averageWaitMinutes.hashCode ^
        (lastOrderDate?.hashCode ?? 0);
  }

  @override
  String toString() {
    return 'CustomerStatsModel(customerId: $customerId, customerName: $customerName, customerEmail: $customerEmail, totalOrders: $totalOrders, averageWaitMinutes: $averageWaitMinutes, lastOrderDate: $lastOrderDate)';
  }
}
