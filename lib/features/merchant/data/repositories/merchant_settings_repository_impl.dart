import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_pager_flutter/features/merchant/domain/models/merchant_settings_model.dart';
import 'package:mobile_pager_flutter/features/merchant/domain/repositories/i_merchant_settings_repository.dart';

class MerchantSettingsRepositoryImpl implements IMerchantSettingsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'merchant_settings';

  @override
  Future<MerchantSettingsModel> getMerchantSettings(String merchantId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(merchantId).get();

      if (!doc.exists) {
        // Return default settings if not configured yet
        return MerchantSettingsModel.defaultSettings(merchantId, '');
      }

      return MerchantSettingsModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get merchant settings: $e');
    }
  }

  @override
  Future<void> updateMerchantSettings(MerchantSettingsModel settings) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(settings.merchantId)
          .set(settings.toMap(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update merchant settings: $e');
    }
  }

  @override
  Stream<MerchantSettingsModel> watchMerchantSettings(String merchantId) {
    return _firestore
        .collection(_collection)
        .doc(merchantId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) {
        return MerchantSettingsModel.defaultSettings(merchantId, '');
      }
      return MerchantSettingsModel.fromFirestore(doc);
    });
  }
}
