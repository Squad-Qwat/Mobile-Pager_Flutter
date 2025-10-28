import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:mobile_pager_flutter/core/theme/app_color.dart';
import 'package:mobile_pager_flutter/core/theme/app_padding.dart';
import 'package:mobile_pager_flutter/features/authentication/presentation/providers/auth_providers.dart';
import 'package:mobile_pager_flutter/features/merchant/domain/models/merchant_settings_model.dart';
import 'package:mobile_pager_flutter/features/merchant/presentation/providers/merchant_settings_providers.dart';

class MerchantSettingsPage extends ConsumerStatefulWidget {
  const MerchantSettingsPage({super.key});

  @override
  ConsumerState<MerchantSettingsPage> createState() =>
      _MerchantSettingsPageState();
}

class _MerchantSettingsPageState extends ConsumerState<MerchantSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _merchantNameController = TextEditingController();
  final _merchantLocationController = TextEditingController();
  final _expireAfterHoursController = TextEditingController();
  final _maxRingingAttemptsController = TextEditingController();
  final _ringingIntervalMinutesController = TextEditingController();
  final _ringingDurationSecondsController = TextEditingController();

  bool _autoExpireOrders = false;
  bool _requireLocation = false;
  bool _requireCustomerInfo = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _merchantNameController.dispose();
    _merchantLocationController.dispose();
    _expireAfterHoursController.dispose();
    _maxRingingAttemptsController.dispose();
    _ringingIntervalMinutesController.dispose();
    _ringingDurationSecondsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider.select((state) => state.user));

    if (user == null || !user.isMerchant) {
      return Scaffold(
        body: Center(
          child: Text('Unauthorized'),
        ),
      );
    }

    final settingsAsync = ref.watch(merchantSettingsFutureProvider(user.uid));

    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: AppBar(
        title: Text(
          'Pengaturan Pager',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: AppColor.textPrimary,
          ),
        ),
        backgroundColor: AppColor.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColor.textPrimary),
      ),
      body: settingsAsync.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'Failed to load settings: $error',
            style: GoogleFonts.inter(color: Colors.red),
          ),
        ),
        data: (settings) {
          // Initialize form with existing settings
          if (_merchantNameController.text.isEmpty) {
            _merchantNameController.text = settings.merchantName;
            _merchantLocationController.text = settings.merchantLocation ?? '';
            _expireAfterHoursController.text =
                settings.expireAfterHours.toString();
            _maxRingingAttemptsController.text =
                settings.maxRingingAttempts.toString();
            _ringingIntervalMinutesController.text =
                settings.ringingIntervalMinutes.toString();
            _ringingDurationSecondsController.text =
                settings.ringingDurationSeconds.toString();
            _autoExpireOrders = settings.autoExpireOrders;
            _requireLocation = settings.requireLocation;
            _requireCustomerInfo = settings.requireCustomerInfo;
          }

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(AppPadding.p16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Informasi Merchant'),
                    SizedBox(height: 12.h),
                    _buildTextField(
                      controller: _merchantNameController,
                      label: 'Nama Merchant',
                      icon: Iconsax.shop,
                      hint: 'Masukkan nama merchant',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama merchant harus diisi';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    _buildTextField(
                      controller: _merchantLocationController,
                      label: 'Lokasi Merchant',
                      icon: Iconsax.location,
                      hint: 'Masukkan alamat merchant',
                    ),
                    SizedBox(height: 24.h),
                    _buildSectionTitle('Pengaturan Auto Expire'),
                    SizedBox(height: 12.h),
                    _buildSwitchTile(
                      title: 'Auto Expire Orders',
                      subtitle: 'Otomatis expired order yang tidak diambil',
                      value: _autoExpireOrders,
                      onChanged: (value) {
                        setState(() {
                          _autoExpireOrders = value;
                        });
                      },
                    ),
                    if (_autoExpireOrders) ...[
                      SizedBox(height: 16.h),
                      _buildNumberField(
                        controller: _expireAfterHoursController,
                        label: 'Expire Setelah (jam)',
                        icon: Iconsax.clock,
                        hint: '3',
                      ),
                    ],
                    SizedBox(height: 24.h),
                    _buildSectionTitle('Pengaturan Panggilan'),
                    SizedBox(height: 12.h),
                    _buildNumberField(
                      controller: _maxRingingAttemptsController,
                      label: 'Maksimal Percobaan Panggilan',
                      icon: Iconsax.notification,
                      hint: '3',
                    ),
                    SizedBox(height: 16.h),
                    _buildNumberField(
                      controller: _ringingIntervalMinutesController,
                      label: 'Jeda Antar Panggilan (menit)',
                      icon: Iconsax.timer_1,
                      hint: '5',
                    ),
                    SizedBox(height: 16.h),
                    _buildNumberField(
                      controller: _ringingDurationSecondsController,
                      label: 'Durasi Tiap Dering (detik)',
                      icon: Iconsax.sound,
                      hint: '60',
                    ),
                    SizedBox(height: 24.h),
                    _buildSectionTitle('Pengaturan Customer'),
                    SizedBox(height: 12.h),
                    _buildSwitchTile(
                      title: 'Require Location',
                      subtitle: 'Paksa customer dalam radius saat scan QR',
                      value: _requireLocation,
                      onChanged: (value) {
                        setState(() {
                          _requireLocation = value;
                        });
                      },
                    ),
                    SizedBox(height: 12.h),
                    _buildSwitchTile(
                      title: 'Require Customer Info',
                      subtitle: 'Paksa isi form sebelum join queue',
                      value: _requireCustomerInfo,
                      onChanged: (value) {
                        setState(() {
                          _requireCustomerInfo = value;
                        });
                      },
                    ),
                    SizedBox(height: 32.h),
                    SizedBox(
                      width: double.infinity,
                      height: 56.h,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () => _handleSaveSettings(settings),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Simpan Pengaturan',
                                style: GoogleFonts.inter(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 18.sp,
        fontWeight: FontWeight.w700,
        color: AppColor.textPrimary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColor.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              color: AppColor.textSecondary,
              fontSize: 14.sp,
            ),
            prefixIcon: Icon(icon, color: AppColor.primary, size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColor.grey300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColor.grey300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColor.primary, width: 2),
            ),
            filled: true,
            fillColor: AppColor.grey100,
          ),
          style: GoogleFonts.inter(fontSize: 14.sp),
        ),
      ],
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColor.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Field tidak boleh kosong';
            }
            final intValue = int.tryParse(value);
            if (intValue == null || intValue <= 0) {
              return 'Harus berupa angka positif';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              color: AppColor.textSecondary,
              fontSize: 14.sp,
            ),
            prefixIcon: Icon(icon, color: AppColor.primary, size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColor.grey300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColor.grey300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColor.primary, width: 2),
            ),
            filled: true,
            fillColor: AppColor.grey100,
          ),
          style: GoogleFonts.inter(fontSize: 14.sp),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColor.grey100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.grey300),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColor.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: AppColor.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColor.primary,
          ),
        ],
      ),
    );
  }

  Future<void> _handleSaveSettings(MerchantSettingsModel currentSettings) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user =
          ref.read(authNotifierProvider.select((state) => state.user));
      if (user == null) throw Exception('User not found');

      final updatedSettings = currentSettings.copyWith(
        merchantName: _merchantNameController.text.trim(),
        merchantLocation: _merchantLocationController.text.trim().isEmpty
            ? null
            : _merchantLocationController.text.trim(),
        autoExpireOrders: _autoExpireOrders,
        expireAfterHours: int.parse(_expireAfterHoursController.text),
        maxRingingAttempts: int.parse(_maxRingingAttemptsController.text),
        ringingIntervalMinutes:
            int.parse(_ringingIntervalMinutesController.text),
        ringingDurationSeconds:
            int.parse(_ringingDurationSecondsController.text),
        requireLocation: _requireLocation,
        requireCustomerInfo: _requireCustomerInfo,
        updatedAt: DateTime.now(),
      );

      final repository = ref.read(merchantSettingsRepositoryProvider);
      await repository.updateMerchantSettings(updatedSettings);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Pengaturan berhasil disimpan',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal menyimpan pengaturan: $e',
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
