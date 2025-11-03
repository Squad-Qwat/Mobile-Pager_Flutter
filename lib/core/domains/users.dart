import 'package:cloud_firestore/cloud_firestore.dart';

/// Model untuk users collection di Firestore
/// Supports merchant, customer, dan guest users
class UserModel {
  final String uid;
  final String role; // "merchant" | "customer" | "guest"
  final String? email;
  final String? displayName;
  final String? photoURL;
  final String authProvider; // "google" | "guest"
  final DateTime createdAt;
  final DateTime lastLoginAt;

  // Guest-specific fields
  final bool? isGuest;
  final String? guestId;
  final String? deviceId;
  final DateTime? expiresAt;

  UserModel({
    required this.uid,
    required this.role,
    this.email,
    this.displayName,
    this.photoURL,
    required this.authProvider,
    required this.createdAt,
    required this.lastLoginAt,
    this.isGuest,
    this.guestId,
    this.deviceId,
    this.expiresAt,
  });

  /// Factory constructor dari Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel.fromMap(data, doc.id);
  }

  /// Factory constructor dari Map
  factory UserModel.fromMap(Map<String, dynamic> data, String docId) {
    return UserModel(
      uid: docId,
      role: data['role'] ?? 'customer',
      email: data['email'],
      displayName: data['displayName'],
      photoURL: data['photoURL'],
      authProvider: data['authProvider'] ?? 'google',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp).toDate(),
      isGuest: data['isGuest'],
      guestId: data['guestId'],
      deviceId: data['deviceId'],
      expiresAt: data['expiresAt'] != null
          ? (data['expiresAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// Convert ke Map untuk Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'role': role,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'authProvider': authProvider,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': Timestamp.fromDate(lastLoginAt),
      if (isGuest != null) 'isGuest': isGuest,
      if (guestId != null) 'guestId': guestId,
      if (deviceId != null) 'deviceId': deviceId,
      if (expiresAt != null) 'expiresAt': Timestamp.fromDate(expiresAt!),
    };
  }

  /// Helper untuk membuat guest user
  factory UserModel.createGuest({
    required String uid,
    required String guestId,
    required String deviceId,
  }) {
    final now = DateTime.now();
    final expiryDate = now.add(const Duration(days: 30));

    return UserModel(
      uid: uid,
      role: 'guest',
      authProvider: 'guest',
      createdAt: now,
      lastLoginAt: now,
      isGuest: true,
      guestId: guestId,
      deviceId: deviceId,
      expiresAt: expiryDate,
    );
  }

  /// Helper untuk membuat registered user
  factory UserModel.createRegistered({
    required String uid,
    required String role,
    required String email,
    String? displayName,
    String? photoURL,
  }) {
    final now = DateTime.now();

    return UserModel(
      uid: uid,
      role: role,
      email: email,
      displayName: displayName,
      photoURL: photoURL,
      authProvider: 'google',
      createdAt: now,
      lastLoginAt: now,
    );
  }

  /// CopyWith method
  UserModel copyWith({
    String? uid,
    String? role,
    String? email,
    String? displayName,
    String? photoURL,
    String? authProvider,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isGuest,
    String? guestId,
    String? deviceId,
    DateTime? expiresAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      role: role ?? this.role,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      authProvider: authProvider ?? this.authProvider,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isGuest: isGuest ?? this.isGuest,
      guestId: guestId ?? this.guestId,
      deviceId: deviceId ?? this.deviceId,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  /// Check if user is merchant
  bool get isMerchant => role == 'merchant';

  /// Check if user is customer
  bool get isCustomer => role == 'customer';

  /// Check if user is guest
  bool get isGuestUser => role == 'guest' && (isGuest ?? false);

  /// Check if guest account is expired
  bool get isExpired {
    if (!isGuestUser || expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, role: $role, email: $email, isGuest: $isGuest)';
  }
}