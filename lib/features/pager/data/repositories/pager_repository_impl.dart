import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_pager_flutter/core/domains/users.dart';
import 'package:mobile_pager_flutter/features/pager/domain/models/pager_model.dart';
import 'package:mobile_pager_flutter/features/pager/domain/repositories/i_pager_repository.dart';
import 'package:mobile_pager_flutter/features/pager_history/domain/models/customer_stats_model.dart';

class PagerRepositoryImpl implements IPagerRepository {
  final FirebaseFirestore _firestore;

  static const String _temporaryCollection = 'temporary_pagers';
  static const String _activeCollection = 'active_pagers';

  PagerRepositoryImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<String> createTemporaryPager({
    required String merchantId,
    String? label,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Get the next pager number for this merchant
      final number = await _getNextPagerNumber(merchantId);

      // Generate secure random code for unpredictable display ID
      final randomCode = PagerModel.generateRandomCode();

      final now = DateTime.now();
      final expiresAt = now.add(const Duration(hours: 24));

      final pagerData = {
        'pagerId': '', // Will be updated with doc ID
        'merchantId': merchantId,
        'number': number,
        'randomCode': randomCode, // Add random code for secure display ID
        'status': PagerStatus.temporary.name,
        'createdAt': Timestamp.fromDate(now),
        'expiresAt': Timestamp.fromDate(expiresAt),
        if (label != null) 'label': label,
        if (metadata != null) 'metadata': metadata,
      };

      final docRef = await _firestore
          .collection(_temporaryCollection)
          .add(pagerData);

      // Update with actual doc ID
      await docRef.update({'pagerId': docRef.id});

      print('✅ Created pager with secure ID - Number: $number, RandomCode: $randomCode');

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create temporary pager: $e');
    }
  }

  @override
  Stream<List<PagerModel>> watchTemporaryPagers(String merchantId) {
    print('🔄 [STREAM] Starting to watch temporary pagers for merchant: $merchantId');
    return _firestore
        .collection(_temporaryCollection)
        .where('merchantId', isEqualTo: merchantId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          print('🔄 [STREAM] Temporary pagers stream update - count: ${snapshot.docs.length}');
          final pagers = snapshot.docs
              .map((doc) => PagerModel.fromFirestore(doc))
              .toList();
          print('🔄 [STREAM] Mapped pagers: ${pagers.map((p) => p.displayId).join(', ')}');
          return pagers;
        });
  }

  @override
  Stream<List<PagerModel>> watchActivePagers(String merchantId) {
    return _firestore
        .collection(_activeCollection)
        .where('merchantId', isEqualTo: merchantId)
        .orderBy('activatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .where((doc) {
                final data = doc.data();
                final status = data['status'] ?? '';
                return status == PagerStatus.waiting.name ||
                    status == PagerStatus.ready.name || 
                    status == PagerStatus.ringing.name;
              })
              .map((doc) => PagerModel.fromFirestore(doc))
              .toList();
        });
  }

  @override
  Future<void> activatePager({
    required String pagerId,
    required String customerId,
    required String customerType,
    required Map<String, dynamic> customerInfo,
  }) async {
    try {
      print('📦 [REPO] Checking if pager already activated...');
      // Check if pager is already activated
      final activeDoc = await _firestore
          .collection(_activeCollection)
          .doc(pagerId)
          .get();

      if (activeDoc.exists) {
        print('⚠️ [REPO] Pager already activated!');
        throw Exception('Pager sudah diaktifkan sebelumnya');
      }

      print('📦 [REPO] Getting temporary pager from Firestore...');
      // Get the temporary pager
      final tempDoc = await _firestore
          .collection(_temporaryCollection)
          .doc(pagerId)
          .get();

      if (!tempDoc.exists) {
        print('❌ [REPO] Temporary pager not found in collection: $_temporaryCollection');
        throw Exception('QR Code tidak valid atau sudah digunakan');
      }

      print('✅ [REPO] Temporary pager found, parsing data...');
      final tempPager = PagerModel.fromFirestore(tempDoc);

      print('📦 [REPO] Getting queue number for merchant: ${tempPager.merchantId}');
      // Get queue number for this merchant
      final queueNumber = await _getNextQueueNumber(tempPager.merchantId);
      print('✅ [REPO] Queue number assigned: $queueNumber');

      // Create active pager
      final activePagerData = {
        'pagerId': pagerId,
        'merchantId': tempPager.merchantId,
        'customerId': customerId,
        'customerType': customerType,
        'number': tempPager.number,
        'queueNumber': queueNumber,
        'status': PagerStatus.waiting.name,
        'createdAt': Timestamp.fromDate(tempPager.createdAt),
        'activatedAt': Timestamp.fromDate(DateTime.now()),
        if (tempPager.label != null) 'label': tempPager.label,
        if (tempPager.invoiceImageUrl != null) 'invoiceImageUrl': tempPager.invoiceImageUrl,
        if (tempPager.randomCode != null) 'randomCode': tempPager.randomCode, // Preserve random code
        'scannedBy': customerInfo,
        if (tempPager.metadata != null) 'metadata': tempPager.metadata,
      };

      print('📦 [REPO] Writing active pager to Firestore...');
      print('   Collection: $_activeCollection');
      print('   Document ID: $pagerId');
      // CRITICAL FIX: Use .doc(pagerId).set() instead of .add()
      // This ensures we use the same pagerId as document ID, preventing duplicates
      await _firestore.collection(_activeCollection).doc(pagerId).set(activePagerData);
      print('✅ [REPO] Active pager created successfully');

      print('📦 [REPO] Deleting temporary pager...');
      // Delete from temporary collection
      await _firestore.collection(_temporaryCollection).doc(pagerId).delete();
      print('✅ [REPO] Temporary pager deleted');

      print('🎉 [REPO] Pager activation completed successfully!');
    } catch (e, stackTrace) {
      print('❌ [REPO] Error activating pager: $e');
      print('📍 [REPO] Stack trace: $stackTrace');
      throw Exception('Failed to activate pager: $e');
    }
  }

  @override
  Future<PagerModel?> getPagerById(String pagerId) async {
    try {
      // Try temporary collection first
      final tempDoc = await _firestore
          .collection(_temporaryCollection)
          .doc(pagerId)
          .get();

      if (tempDoc.exists) {
        return PagerModel.fromFirestore(tempDoc);
      }

      // Try active collection - now using direct doc access
      final activeDoc = await _firestore
          .collection(_activeCollection)
          .doc(pagerId)
          .get();

      if (activeDoc.exists) {
        return PagerModel.fromFirestore(activeDoc);
      }

      return null;
    } catch (e) {
      throw Exception('Failed to get pager by ID: $e');
    }
  }

  @override
  Future<void> updatePagerStatus({
    required String pagerId,
    required PagerStatus status,
  }) async {
    try {
      // Direct doc access - no query needed
      final docRef = _firestore.collection(_activeCollection).doc(pagerId);
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        throw Exception('Active pager not found');
      }

      final updateData = <String, dynamic>{'status': status.name};

      // If changing status to ringing, increment ringingCount
      if (status == PagerStatus.ringing) {
        final currentData = docSnapshot.data();
        final currentCount = currentData?['ringingCount'] ?? 0;
        updateData['ringingCount'] = currentCount + 1;
      }

      await docRef.update(updateData);
    } catch (e) {
      throw Exception('Failed to update pager status: $e');
    }
  }

  @override
  Future<void> updatePagerNotes({
    required String pagerId,
    required String notes,
  }) async {
    try {
      // Direct doc access - no query needed
      final docRef = _firestore.collection(_activeCollection).doc(pagerId);
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        throw Exception('Active pager not found');
      }

      await docRef.update({'notes': notes});
    } catch (e) {
      throw Exception('Failed to update pager notes: $e');
    }
  }

  @override
  Future<void> deleteTemporaryPager(String pagerId) async {
    try {
      await _firestore.collection(_temporaryCollection).doc(pagerId).delete();
    } catch (e) {
      throw Exception('Failed to delete temporary pager: $e');
    }
  }

  @override
  Stream<List<PagerModel>> getCustomerActivePagers(String customerId) {
    return _firestore
        .collection(_activeCollection)
        .where('customerId', isEqualTo: customerId)
        .orderBy('activatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .where((doc) {
                final data = doc.data();
                final status = data['status'] ?? '';
                // Include waiting, ready, and ringing statuses for customer view
                return status == PagerStatus.waiting.name ||
                    status == PagerStatus.ready.name ||
                    status == PagerStatus.ringing.name;
              })
              .map((doc) => PagerModel.fromFirestore(doc))
              .toList();
        });
  }

  @override
  Stream<List<PagerModel>> getMerchantHistoryPagers(String merchantId) {
    return _firestore
        .collection(_activeCollection)
        .where('merchantId', isEqualTo: merchantId)
        .orderBy('activatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .where((doc) {
                final data = doc.data();
                final status = data['status'] ?? '';
                return status == PagerStatus.finished.name ||
                    status == PagerStatus.expired.name;
              })
              .map((doc) => PagerModel.fromFirestore(doc))
              .toList();
        });
  }

  @override
  Stream<List<PagerModel>> getCustomerHistoryPagers(String customerId) {
    return _firestore
        .collection(_activeCollection)
        .where('customerId', isEqualTo: customerId)
        .orderBy('activatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .where((doc) {
                final data = doc.data();
                final status = data['status'] ?? '';
                return status == PagerStatus.finished.name ||
                    status == PagerStatus.expired.name;
              })
              .map((doc) => PagerModel.fromFirestore(doc))
              .toList();
        });
  }

  Future<int> _getNextPagerNumber(String merchantId) async {
    try {
      // Query both collections to get the highest number
      final tempQuery = await _firestore
          .collection(_temporaryCollection)
          .where('merchantId', isEqualTo: merchantId)
          .orderBy('number', descending: true)
          .limit(1)
          .get();

      final activeQuery = await _firestore
          .collection(_activeCollection)
          .where('merchantId', isEqualTo: merchantId)
          .orderBy('number', descending: true)
          .limit(1)
          .get();

      int maxTemp = 0;
      int maxActive = 0;

      if (tempQuery.docs.isNotEmpty) {
        maxTemp = tempQuery.docs.first.data()['number'] ?? 0;
      }

      if (activeQuery.docs.isNotEmpty) {
        maxActive = activeQuery.docs.first.data()['number'] ?? 0;
      }

      return (maxTemp > maxActive ? maxTemp : maxActive) + 1;
    } catch (e) {
      // If error, return 1 as fallback
      return 1;
    }
  }

  Future<int> _getNextQueueNumber(String merchantId) async {
    try {
      // Get all active pagers for this merchant
      // We can't use orderBy with where without composite index
      // So we fetch all and find max manually
      final query = await _firestore
          .collection(_activeCollection)
          .where('merchantId', isEqualTo: merchantId)
          .get();

      if (query.docs.isEmpty) {
        print('📊 No active pagers found, starting queue at 1');
        return 1;
      }

      // Find the maximum queue number manually
      int maxQueueNumber = 0;
      for (final doc in query.docs) {
        final queueNumber = doc.data()['queueNumber'] as int?;
        if (queueNumber != null && queueNumber > maxQueueNumber) {
          maxQueueNumber = queueNumber;
        }
      }

      final nextQueue = maxQueueNumber + 1;
      print('📊 Current max queue: $maxQueueNumber, next queue: $nextQueue');
      return nextQueue;
    } catch (e) {
      print('❌ Error getting next queue number: $e');
      return 1;
    }
  }

  @override
  Future<List<CustomerStatsModel>> getCustomerStatsList(String merchantId) async {
    try {
      // Get all pagers for this merchant
      final pagersSnapshot = await _firestore
          .collection(_activeCollection)
          .where('merchantId', isEqualTo: merchantId)
          .get();

      // Group pagers by customerId
      final Map<String, List<PagerModel>> customerPagers = {};
      final Set<String> customerIds = {};

      for (final doc in pagersSnapshot.docs) {
        final pager = PagerModel.fromFirestore(doc);

        // Skip if no customerId
        if (pager.customerId == null) continue;

        customerIds.add(pager.customerId!);
        customerPagers.putIfAbsent(pager.customerId!, () => []);
        customerPagers[pager.customerId!]!.add(pager);
      }

      // Fetch user data for all customers (filter out guest users)
      final List<CustomerStatsModel> customerStats = [];

      for (final customerId in customerIds) {
        // Get user data
        final userDoc = await _firestore.collection('users').doc(customerId).get();

        if (!userDoc.exists) continue;

        final user = UserModel.fromFirestore(userDoc);

        // Skip guest users
        if (user.isGuestUser) continue;

        final pagers = customerPagers[customerId]!;

        // Calculate statistics
        final totalOrders = pagers.length;

        // Calculate average wait time (from activatedAt to ready/finished status)
        double totalWaitMinutes = 0;
        int countWithWaitTime = 0;

        for (final pager in pagers) {
          if (pager.activatedAt != null) {
            DateTime? endTime;

            // Determine end time based on status
            if (pager.status == PagerStatus.finished || pager.status == PagerStatus.expired) {
              // For finished/expired pagers, use updatedAt or assume some time
              // Since we don't have updatedAt field, we'll estimate based on status changes
              // This is a simplified calculation
              endTime = pager.activatedAt!.add(const Duration(minutes: 15)); // Default estimate
            } else if (pager.status == PagerStatus.ready || pager.status == PagerStatus.ringing) {
              endTime = DateTime.now();
            }

            if (endTime != null) {
              final waitMinutes = endTime.difference(pager.activatedAt!).inMinutes;
              if (waitMinutes >= 0) {
                totalWaitMinutes += waitMinutes;
                countWithWaitTime++;
              }
            }
          }
        }

        final averageWaitMinutes = countWithWaitTime > 0
            ? totalWaitMinutes / countWithWaitTime
            : 0.0;

        // Get last order date
        final lastOrderDate = pagers
            .map((p) => p.activatedAt)
            .whereType<DateTime>()
            .fold<DateTime?>(null, (prev, date) {
              if (prev == null) return date;
              return date.isAfter(prev) ? date : prev;
            });

        customerStats.add(CustomerStatsModel(
          customerId: customerId,
          customerName: user.displayName ?? user.email ?? 'Unknown',
          customerEmail: user.email ?? '',
          totalOrders: totalOrders,
          averageWaitMinutes: averageWaitMinutes,
          lastOrderDate: lastOrderDate,
        ));
      }

      // Sort by total orders descending
      customerStats.sort((a, b) => b.totalOrders.compareTo(a.totalOrders));

      return customerStats;
    } catch (e) {
      throw Exception('Failed to get customer stats list: $e');
    }
  }

  @override
  Future<List<PagerModel>> getCustomerPagerHistory({
    required String merchantId,
    required String customerId,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(_activeCollection)
          .where('merchantId', isEqualTo: merchantId)
          .where('customerId', isEqualTo: customerId)
          .orderBy('activatedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => PagerModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get customer pager history: $e');
    }
  }
}
