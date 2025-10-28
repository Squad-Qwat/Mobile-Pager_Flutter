import 'dart:math';
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
  final DateTime? finishedAt; // NEW: When order was completed
  final DateTime? expiresAt;
  final String? label;
  final Map<String, dynamic>? scannedBy;
  final int ringingCount;
  final String? notes;
  final String? invoiceImageUrl;
  final Map<String, dynamic>? metadata;
  final String? randomCode; // Random code for secure, unpredictable display IDs

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
    this.finishedAt,
    this.expiresAt,
    this.label,
    this.scannedBy,
    this.ringingCount = 0,
    this.notes,
    this.invoiceImageUrl,
    this.metadata,
    this.randomCode,
  });

  factory PagerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    String? randomCode = data['randomCode'];
    if (randomCode == null || randomCode.isEmpty) {
      randomCode = generateRandomCode();
      doc.reference.update({'randomCode': randomCode}).catchError((e) {});
    }

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
      finishedAt: (data['finishedAt'] as Timestamp?)?.toDate(),
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
      randomCode: randomCode,
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
      if (finishedAt != null) 'finishedAt': Timestamp.fromDate(finishedAt!),
      if (expiresAt != null) 'expiresAt': Timestamp.fromDate(expiresAt!),
      if (label != null) 'label': label,
      if (scannedBy != null) 'scannedBy': scannedBy,
      'ringingCount': ringingCount,
      if (notes != null) 'notes': notes,
      if (invoiceImageUrl != null) 'invoiceImageUrl': invoiceImageUrl,
      if (metadata != null) 'metadata': metadata,
      if (randomCode != null) 'randomCode': randomCode,
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
    DateTime? finishedAt,
    DateTime? expiresAt,
    String? label,
    Map<String, dynamic>? scannedBy,
    int? ringingCount,
    String? notes,
    String? invoiceImageUrl,
    Map<String, dynamic>? metadata,
    String? randomCode,
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
      finishedAt: finishedAt ?? this.finishedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      label: label ?? this.label,
      scannedBy: scannedBy ?? this.scannedBy,
      ringingCount: ringingCount ?? this.ringingCount,
      notes: notes ?? this.notes,
      invoiceImageUrl: invoiceImageUrl ?? this.invoiceImageUrl,
      metadata: metadata ?? this.metadata,
      randomCode: randomCode ?? this.randomCode,
    );
  }

  /// Generate a secure, unpredictable random code (6 characters)
  /// Uses alphanumeric characters excluding confusing ones (0,O,1,I,l)
  static String generateRandomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    return List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
  }

  /// Display ID in format: PG-[RANDOM]-[NUMBER]
  /// Example: PG-A3K9M2-001 (unpredictable)
  /// Falls back to old format if randomCode is null (for backward compatibility)
  String get displayId {
    if (randomCode != null && randomCode!.isNotEmpty) {
      return 'PG-$randomCode-${number.toString().padLeft(3, '0')}';
    }
    // Fallback for old pagers without randomCode
    return 'PG-${number.toString().padLeft(4, '0')}';
  }
}
