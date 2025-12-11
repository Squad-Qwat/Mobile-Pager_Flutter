import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_pager_flutter/features/pager/domain/models/pager_model.dart';
import 'package:mobile_pager_flutter/features/pager/domain/repositories/i_pager_repository.dart';

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

      final now = DateTime.now();
      final expiresAt = now.add(const Duration(hours: 24));

      final pagerData = {
        'pagerId': '', // Will be updated with doc ID
        'merchantId': merchantId,
        'number': number,
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

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create temporary pager: $e');
    }
  }

  @override
  Stream<List<PagerModel>> watchTemporaryPagers(String merchantId) {
    return _firestore
        .collection(_temporaryCollection)
        .where('merchantId', isEqualTo: merchantId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => PagerModel.fromFirestore(doc))
              .toList();
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
      // Get the temporary pager
      final tempDoc = await _firestore
          .collection(_temporaryCollection)
          .doc(pagerId)
          .get();

      if (!tempDoc.exists) {
        throw Exception('Temporary pager not found');
      }

      final tempPager = PagerModel.fromFirestore(tempDoc);

      // Get queue number for this merchant
      final queueNumber = await _getNextQueueNumber(tempPager.merchantId);

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
        'scannedBy': customerInfo,
        if (tempPager.metadata != null) 'metadata': tempPager.metadata,
      };

      // Add to active collection
      await _firestore.collection(_activeCollection).add(activePagerData);

      // Delete from temporary collection
      await _firestore.collection(_temporaryCollection).doc(pagerId).delete();
    } catch (e) {
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

      // Try active collection
      final activeQuery = await _firestore
          .collection(_activeCollection)
          .where('pagerId', isEqualTo: pagerId)
          .limit(1)
          .get();

      if (activeQuery.docs.isNotEmpty) {
        return PagerModel.fromFirestore(activeQuery.docs.first);
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
      final activeQuery = await _firestore
          .collection(_activeCollection)
          .where('pagerId', isEqualTo: pagerId)
          .limit(1)
          .get();

      if (activeQuery.docs.isEmpty) {
        throw Exception('Active pager not found');
      }

      final updateData = <String, dynamic>{'status': status.name};

      // If changing status to ringing, increment ringingCount
      if (status == PagerStatus.ringing) {
        final currentData = activeQuery.docs.first.data();
        final currentCount = currentData['ringingCount'] ?? 0;
        updateData['ringingCount'] = currentCount + 1;
      }

      await activeQuery.docs.first.reference.update(updateData);
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
      final activeQuery = await _firestore
          .collection(_activeCollection)
          .where('pagerId', isEqualTo: pagerId)
          .limit(1)
          .get();

      if (activeQuery.docs.isEmpty) {
        throw Exception('Active pager not found');
      }

      await activeQuery.docs.first.reference.update({'notes': notes});
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
                return status == PagerStatus.waiting.name ||
                    status == PagerStatus.ready.name;
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
      final query = await _firestore
          .collection(_activeCollection)
          .where('merchantId', isEqualTo: merchantId)
          .orderBy('queueNumber', descending: true)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        return 1;
      }

      return (query.docs.first.data()['queueNumber'] ?? 0) + 1;
    } catch (e) {
      return 1;
    }
  }
}
