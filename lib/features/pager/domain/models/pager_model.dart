import 'package:cloud_firestore/cloud_firestore.dart';

enum PagerStatus { temporary, waiting, ready, ringing, finished, expired }

class PagerModel {
  final String id;
  final String pagerId;
  final String merchantId;
  final String? customerId;
  final String? customerType;
  final int number;
  final int? queueNumber;
  final PagerStatus status;
  final DateTime createdAt;
  final DateTime? activatedAt;
  final DateTime? expiresAt;
  final String? label;
  final Map<String, dynamic>? scannedBy;
  final int ringingCount;
  final String? notes;
  final String? invoiceImageUrl;
  final Map<String, dynamic>? metadata;

  PagerModel({
    required this.id,
    required this.pagerId,
    required this.merchantId,
    this.customerId,
    this.customerType,
    required this.number,
    this.queueNumber,
    required this.status,
    required this.createdAt,
    this.activatedAt,
    this.expiresAt,
    this.label,
    this.scannedBy,
    this.ringingCount = 0,
    this.notes,
    this.invoiceImageUrl,
    this.metadata,
  });

  factory PagerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PagerModel(
      id: doc.id,
      pagerId: data['pagerId'] ?? doc.id,
      merchantId: data['merchantId'] ?? '',
      customerId: data['customerId'],
      customerType: data['customerType'],
      number: data['number'] ?? 0,
      queueNumber: data['queueNumber'],
      status: _statusFromString(data['status'] ?? 'temporary'),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      activatedAt: (data['activatedAt'] as Timestamp?)?.toDate(),
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate(),
      label: data['label'],
      scannedBy: data['scannedBy'] != null
          ? Map<String, dynamic>.from(data['scannedBy'])
          : null,
      ringingCount: data['ringingCount'] ?? 0,
      notes: data['notes'],
      invoiceImageUrl: data['invoiceImageUrl'],
      metadata: data['metadata'] != null
          ? Map<String, dynamic>.from(data['metadata'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pagerId': pagerId,
      'merchantId': merchantId,
      if (customerId != null) 'customerId': customerId,
      if (customerType != null) 'customerType': customerType,
      'number': number,
      if (queueNumber != null) 'queueNumber': queueNumber,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      if (activatedAt != null) 'activatedAt': Timestamp.fromDate(activatedAt!),
      if (expiresAt != null) 'expiresAt': Timestamp.fromDate(expiresAt!),
      if (label != null) 'label': label,
      if (scannedBy != null) 'scannedBy': scannedBy,
      'ringingCount': ringingCount,
      if (notes != null) 'notes': notes,
      if (invoiceImageUrl != null) 'invoiceImageUrl': invoiceImageUrl,
      if (metadata != null) 'metadata': metadata,
    };
  }

  static PagerStatus _statusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'temporary':
        return PagerStatus.temporary;
      case 'waiting':
        return PagerStatus.waiting;
      case 'ready':
        return PagerStatus.ready;
      case 'ringing':
        return PagerStatus.ringing;
      case 'finished':
        return PagerStatus.finished;
      case 'expired':
        return PagerStatus.expired;
      default:
        return PagerStatus.temporary;
    }
  }

  PagerModel copyWith({
    String? id,
    String? pagerId,
    String? merchantId,
    String? customerId,
    String? customerType,
    int? number,
    int? queueNumber,
    PagerStatus? status,
    DateTime? createdAt,
    DateTime? activatedAt,
    DateTime? expiresAt,
    String? label,
    Map<String, dynamic>? scannedBy,
    int? ringingCount,
    String? notes,
    String? invoiceImageUrl,
    Map<String, dynamic>? metadata,
  }) {
    return PagerModel(
      id: id ?? this.id,
      pagerId: pagerId ?? this.pagerId,
      merchantId: merchantId ?? this.merchantId,
      customerId: customerId ?? this.customerId,
      customerType: customerType ?? this.customerType,
      number: number ?? this.number,
      queueNumber: queueNumber ?? this.queueNumber,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      activatedAt: activatedAt ?? this.activatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      label: label ?? this.label,
      scannedBy: scannedBy ?? this.scannedBy,
      ringingCount: ringingCount ?? this.ringingCount,
      notes: notes ?? this.notes,
      invoiceImageUrl: invoiceImageUrl ?? this.invoiceImageUrl,
      metadata: metadata ?? this.metadata,
    );
  }

  String get displayId => 'PG-${number.toString().padLeft(4, '0')}';
}
