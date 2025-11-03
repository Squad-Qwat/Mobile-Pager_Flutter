import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:mobile_pager_flutter/core/theme/app_color.dart';
import 'package:mobile_pager_flutter/features/authentication/presentation/providers/auth_providers.dart';
import 'package:mobile_pager_flutter/features/pager_history/presentation/pager_history_page.dart';
import 'package:mobile_pager_flutter/features/pager_qr_view/presentation/qr_view_page.dart';
import 'package:mobile_pager_flutter/features/pager_scan/presentation/pager_scan_page.dart';
import 'package:mobile_pager_flutter/features/home/presentation/home_page.dart';

class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isMerchant = authState.isMerchant;

    // Define pages based on merchant status
    final List<Widget> pages = [
      const HomePage(),
      isMerchant ? const QRViewPage() : const PagerScanPage(),
      const HistoryPage(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColor.white,
          border: Border(
            top: BorderSide(color: AppColor.black.withOpacity(0.3), width: 1),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Iconsax.home_copy,
                  selectedIcon: Iconsax.home_copy,
                  label: 'Home',
                  index: 0,
                ),
                _buildNavItem(
                  icon: isMerchant ? Iconsax.barcode_copy : Iconsax.scan_copy,
                  selectedIcon: isMerchant
                      ? Iconsax.barcode_copy
                      : Iconsax.scan,
                  label: isMerchant ? 'Pager QR' : 'Pager Scan',
                  index: 1,
                ),
                _buildNavItem(
                  icon: Iconsax.sms_copy,
                  selectedIcon: Iconsax.sms_copy,
                  label: 'History',
                  index: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;

    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected ? AppColor.primary : AppColor.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: isSelected ? AppColor.primary : AppColor.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
