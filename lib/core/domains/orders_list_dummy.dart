import 'package:mobile_pager_flutter/core/domains/orders_list.dart';

/// Raw data for recent activities
final List<Map<String, dynamic>> _recentActivitiesRawData = [
  {
    'id': 'EC-230201DDA',
    'time': '07:00, 19 Oct 2023',
    'pagerNum': 'PG-2228',
    'orderType': 'Take Away',
    'tableNum': 9,
    'name': 'Fauzan',
    'remainingTime': '00:40',
  },
  {
    'id': 'EC-230201DDB',
    'time': '07:30, 19 Oct 2023',
    'pagerNum': 'PG-2229',
    'orderType': 'Dine In',
    'tableNum': 10,
    'name': 'Fauzan',
    'remainingTime': '02:00',
  },
  {
    'id': 'EC-230201DDC',
    'time': '08:00, 19 Oct 2023',
    'pagerNum': 'PG-2230',
    'orderType': 'Take Away',
    'tableNum': 11,
    'name': 'Reza',
    'remainingTime': '05:00',
  },
  {
    'id': 'EC-230201DDD',
    'time': '08:20, 19 Oct 2023',
    'pagerNum': 'PG-2231',
    'orderType': 'Dine In',
    'tableNum': 12,
    'name': 'Nizar',
    'remainingTime': '07:00',
  },
  {
    'id': 'EC-230201DDE',
    'time': '09:30, 19 Oct 2023',
    'pagerNum': 'PG-2232',
    'orderType': 'Dine In',
    'tableNum': 13,
    'name': 'Fauzan',
    'remainingTime': '08:00',
  },
  {
    'id': 'EC-230201DDF',
    'time': '10:40, 19 Oct 2023',
    'pagerNum': 'PG-2233',
    'orderType': 'Take Away',
    'tableNum': 14,
    'name': 'Rahma',
    'remainingTime': '10:00',
  },
  {
    'id': 'EC-230201DDG',
    'time': '11:56, 19 Oct 2023',
    'pagerNum': 'PG-2234',
    'orderType': 'Dine In',
    'tableNum': 20,
    'name': 'Fauzan',
    'remainingTime': '20:00',
  },
  {
    'id': 'EC-230201DDH',
    'time': '12:30, 19 Oct 2023',
    'pagerNum': 'PG-2235',
    'orderType': 'Take Away',
    'tableNum': 15,
    'remainingTime': '15:00',
  },
  {
    'id': 'EC-230201DEA',
    'time': '13:40, 19 Oct 2023',
    'pagerNum': 'PG-2236',
    'orderType': 'Cancelled', // Faking a cancelled status
    'tableNum': 16,
    'name': 'Affan',
    'remainingTime': '25:00',
  },
];

/// The mapped list of [Orders] objects
final List<Orders> recentActivitiesData =
    _recentActivitiesRawData.map(_mapToOrders).toList(growable: false);

/// Helper function to map raw data to the [Orders] model
Orders _mapToOrders(Map<String, dynamic> data) {
  final DateTime createdTime = DateTime(
      2023,
      10,
      19,
      int.parse(data['time'].split(',')[0].trim().split(':')[0]),
      int.parse(data['time'].split(',')[0].trim().split(':')[1]));

  final List<String> remainingParts = (data['remainingTime'] as String).split(':');
  final int minutes = int.parse(remainingParts[0]) * 60 + int.parse(remainingParts[1]);
  final DateTime expiryTime = DateTime.now().add(Duration(minutes: minutes));

  // Determine actual status for dummy data completeness
  String status;
  if (data['orderType'] == 'Dine In') {
    status = 'ready';
  } else if (data['orderType'] == 'Take Away') {
    status = 'processing';
  } else {
    status = 'cancelled';
  }
  
  DateTime? ready = status == 'ready' ? createdTime.add(const Duration(minutes: 30)) : null;
  DateTime? pickedUp = status == 'finished' || status == 'picked_up'
      ? ready!.add(const Duration(minutes: 5))
      : null;
  DateTime? finished = status == 'finished' ? pickedUp!.add(const Duration(minutes: 5)) : null;
  String? cancelReason = data['id'] == 'EC-230201DEA' ? 'Pelanggan tidak jadi memesan' : null;

  return Orders(
    orderId: data['id'] ?? 'EC-000',
    queueNumber: data['tableNum'] is int ? data['tableNum'] : 0,
    merchantId: 'MCH-001',
    customerId: 'CST-001',
    customerType: (data['name'] == null || data['name'] == 'Guest') ? 'guest' : 'registered',
    customer: CustomerInfo(
      name: data['name'] ?? 'Guest',
      tableNumber: (data['tableNum'] is int) ? data['tableNum'].toString().padLeft(2, '0') : null,
      phone: data['name'] == 'Fauzan' ? '08123456789' : null,
    ),
    status: status,
    createdAt: createdTime.subtract(const Duration(minutes: 30)),
    processingAt: createdTime, // Dummy processing time
    readyAt: ready,
    expiresAt: status == 'ready' ? expiryTime : null, // Only set expiresAt if ready
    pickedUpAt: pickedUp,
    finishedAt: finished,
    ringing: RingingInfo(
        attempts: data['tableNum'] == 12 ? 3 : 0,
        isRinging: false,
        lastRingAt: data['tableNum'] == 12 ? DateTime.now().subtract(const Duration(minutes: 5)) : null),
    updatedAt: DateTime.now(),
    notes: data['tableNum'] == 14 ? 'Pedas sedang, tanpa sayur.' : null,
    cancelReason: cancelReason,
    scanLocation: data['tableNum'] == 10
        ? ScanLocation(
            latitude: -6.9175,
            longitude: 107.6191,
            timestamp: createdTime.subtract(const Duration(minutes: 1)),
            distanceFromMerchant: 550.5)
        : null,
  );
}

/// Other dummy data (if needed)
final List<Map<String, dynamic>> storeStatisticData = [
  {'number': 60, 'number2': null, 'statisticCount': '23'},
  {'number': 15, 'number2': 20, 'statisticCount': '40'},
];