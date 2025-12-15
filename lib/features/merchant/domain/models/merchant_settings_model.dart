import 'package:cloud_firestore/cloud_firestore.dart';

class MerchantSettingsModel {
  final String merchantId;
  final String merchantName;
  final String? merchantLocation; // GeoPoint or address string
  final bool autoExpireOrders;
  final int expireAfterHours;
  final int maxRingingAttempts;
  final int ringingIntervalMinutes;
  final int ringingDurationSeconds;
  final bool requireLocation;
  final bool requireCustomerInfo;
  final DateTime updatedAt;

  MerchantSettingsModel({
    required this.merchantId,
    required this.merchantName,
    this.merchantLocation,
    this.autoExpireOrders = false,
    this.expireAfterHours = 3,
    this.maxRingingAttempts = 3,
    this.ringingIntervalMinutes = 5,
    this.ringingDurationSeconds = 60,
    this.requireLocation = false,
    this.requireCustomerInfo = false,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  factory MerchantSettingsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MerchantSettingsModel(
      merchantId: doc.id,
      merchantName: data['merchantName'] ?? '',
      merchantLocation: data['merchantLocation'],
      autoExpireOrders: data['autoExpireOrders'] ?? false,
      expireAfterHours: data['expireAfterHours'] ?? 3,
      maxRingingAttempts: data['maxRingingAttempts'] ?? 3,
      ringingIntervalMinutes: data['ringingIntervalMinutes'] ?? 5,
      ringingDurationSeconds: data['ringingDurationSeconds'] ?? 60,
      requireLocation: data['requireLocation'] ?? false,
      requireCustomerInfo: data['requireCustomerInfo'] ?? false,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'merchantId': merchantId,
      'merchantName': merchantName,
      if (merchantLocation != null) 'merchantLocation': merchantLocation,
      'autoExpireOrders': autoExpireOrders,
      'expireAfterHours': expireAfterHours,
      'maxRingingAttempts': maxRingingAttempts,
      'ringingIntervalMinutes': ringingIntervalMinutes,
      'ringingDurationSeconds': ringingDurationSeconds,
      'requireLocation': requireLocation,
      'requireCustomerInfo': requireCustomerInfo,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  MerchantSettingsModel copyWith({
    String? merchantId,
    String? merchantName,
    String? merchantLocation,
    bool? autoExpireOrders,
    int? expireAfterHours,
    int? maxRingingAttempts,
    int? ringingIntervalMinutes,
    int? ringingDurationSeconds,
    bool? requireLocation,
    bool? requireCustomerInfo,
    DateTime? updatedAt,
  }) {
    return MerchantSettingsModel(
      merchantId: merchantId ?? this.merchantId,
      merchantName: merchantName ?? this.merchantName,
      merchantLocation: merchantLocation ?? this.merchantLocation,
      autoExpireOrders: autoExpireOrders ?? this.autoExpireOrders,
      expireAfterHours: expireAfterHours ?? this.expireAfterHours,
      maxRingingAttempts: maxRingingAttempts ?? this.maxRingingAttempts,
      ringingIntervalMinutes:
          ringingIntervalMinutes ?? this.ringingIntervalMinutes,
      ringingDurationSeconds:
          ringingDurationSeconds ?? this.ringingDurationSeconds,
      requireLocation: requireLocation ?? this.requireLocation,
      requireCustomerInfo: requireCustomerInfo ?? this.requireCustomerInfo,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Factory for default settings
  factory MerchantSettingsModel.defaultSettings(
      String merchantId, String merchantName) {
    return MerchantSettingsModel(
      merchantId: merchantId,
      merchantName: merchantName,
      autoExpireOrders: false,
      expireAfterHours: 3,
      maxRingingAttempts: 3,
      ringingIntervalMinutes: 5,
      ringingDurationSeconds: 60,
      requireLocation: false,
      requireCustomerInfo: false,
    );
  }
}
