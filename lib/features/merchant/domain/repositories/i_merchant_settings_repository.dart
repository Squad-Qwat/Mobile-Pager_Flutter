import 'package:mobile_pager_flutter/features/merchant/domain/models/merchant_settings_model.dart';

abstract class IMerchantSettingsRepository {
  /// Get merchant settings by merchant ID
  Future<MerchantSettingsModel> getMerchantSettings(String merchantId);

  /// Update merchant settings
  Future<void> updateMerchantSettings(MerchantSettingsModel settings);

  /// Stream of merchant settings for real-time updates
  Stream<MerchantSettingsModel> watchMerchantSettings(String merchantId);
}
