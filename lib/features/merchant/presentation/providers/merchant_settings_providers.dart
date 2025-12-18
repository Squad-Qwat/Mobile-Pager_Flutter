import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_pager_flutter/features/merchant/data/repositories/merchant_settings_repository_impl.dart';
import 'package:mobile_pager_flutter/features/merchant/domain/models/merchant_settings_model.dart';
import 'package:mobile_pager_flutter/features/merchant/domain/repositories/i_merchant_settings_repository.dart';

/// Merchant settings repository provider
final merchantSettingsRepositoryProvider =
    Provider<IMerchantSettingsRepository>((ref) {
  return MerchantSettingsRepositoryImpl();
});

/// Stream provider for merchant settings (real-time updates)
final merchantSettingsStreamProvider =
    StreamProvider.family<MerchantSettingsModel, String>((ref, merchantId) {
  final repository = ref.watch(merchantSettingsRepositoryProvider);
  return repository.watchMerchantSettings(merchantId);
});

/// Future provider for merchant settings (one-time fetch)
final merchantSettingsFutureProvider =
    FutureProvider.autoDispose.family<MerchantSettingsModel, String>((ref, merchantId) async {
  final repository = ref.watch(merchantSettingsRepositoryProvider);
  return repository.getMerchantSettings(merchantId);
});
