import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:mobile_pager_flutter/core/constants/app_routes.dart';
import 'package:mobile_pager_flutter/core/presentation/widget/buttons/primary_button.dart';
import 'package:mobile_pager_flutter/core/theme/app_color.dart';
import 'package:mobile_pager_flutter/core/theme/app_padding.dart';
import 'package:mobile_pager_flutter/features/authentication/presentation/providers/auth_providers.dart';
import 'package:mobile_pager_flutter/features/merchant/presentation/providers/merchant_settings_providers.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    // Watch merchant settings if user is merchant
    final merchantSettingsAsync = user?.isMerchant == true
        ? ref.watch(merchantSettingsStreamProvider(user!.uid))
        : null;

    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Profile',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: AppColor.textPrimary,
          ),
        ),
        backgroundColor: AppColor.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppPadding.p24),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColor.grey200,
                      border: Border.all(color: AppColor.grey300, width: 2),
                      image: user?.photoURL != null
                          ? DecorationImage(
                              image: NetworkImage(user!.photoURL!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: user?.photoURL == null
                        ? Icon(Iconsax.user, size: 50, color: AppColor.grey600)
                        : null,
                  ),
                  SizedBox(height: AppPadding.p16),
                  Text(
                    user?.displayName ?? 'Guest User',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColor.textPrimary,
                    ),
                  ),
                  SizedBox(height: AppPadding.p8),
                  Text(
                    user?.email ?? 'No email',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColor.textSecondary,
                    ),
                  ),
                  if (user?.role != null)
                    Container(
                      margin: EdgeInsets.only(top: AppPadding.p12),
                      padding: EdgeInsets.symmetric(
                        horizontal: AppPadding.p12,
                        vertical: AppPadding.p8,
                      ),
                      decoration: BoxDecoration(
                        color: user!.isMerchant
                            ? AppColor.primary.withOpacity(0.1)
                            : AppColor.grey200,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: user.isMerchant
                              ? AppColor.primary
                              : AppColor.grey400,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        user.role.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: user.isMerchant
                              ? AppColor.primary
                              : AppColor.textSecondary,
                        ),
                      ),
                    ),
                  // Merchant name display
                  if (user?.isMerchant == true && merchantSettingsAsync != null)
                    merchantSettingsAsync.when(
                      data: (settings) {
                        if (settings.merchantName.isNotEmpty) {
                          return Container(
                            margin: EdgeInsets.only(top: AppPadding.p12),
                            padding: EdgeInsets.symmetric(
                              horizontal: AppPadding.p16,
                              vertical: AppPadding.p12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.grey100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Nama Merchant',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppColor.textSecondary,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  settings.merchantName,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return SizedBox.shrink();
                      },
                      loading: () => SizedBox.shrink(),
                      error: (_, __) => SizedBox.shrink(),
                    ),
                ],
              ),
            ),
            SizedBox(height: AppPadding.p24),
            // Menu Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppPadding.p16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColor.grey300, width: 1),
                ),
                child: Column(
                  children: [
                    // Merchant Settings (only for merchants)
                    if (user?.isMerchant == true)
                      _buildMenuItem(
                        icon: Iconsax.setting_2,
                        title: 'Pengaturan Pager',
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.merchantSettings);
                        },
                      ),
                    if (user?.isMerchant == true)
                      Divider(height: 1, color: AppColor.grey300),
                    // About App
                    _buildMenuItem(
                      icon: Iconsax.info_circle,
                      title: 'Tentang Aplikasi',
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.about);
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppPadding.p16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppPadding.p16),
              child: PrimaryButton(
                text: "Logout",
                onPressed: () => _handleLogout(context, ref),
                backgroundColor: Colors.red,
                icon: Iconsax.logout,
              ),
            ),
            SizedBox(height: AppPadding.p24),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColor.textSecondary),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColor.textPrimary,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: AppColor.grey600),
      onTap: onTap,
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Logout',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: AppColor.textPrimary,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin logout?',
          style: GoogleFonts.inter(color: AppColor.textSecondary),
        ),
        backgroundColor: AppColor.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                color: AppColor.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Logout',
              style: GoogleFonts.inter(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(authNotifierProvider.notifier).signOut();
        if (context.mounted) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(AppRoutes.authentication, (route) => false);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to logout: $e',
                style: GoogleFonts.inter(color: Colors.white),
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }
}
