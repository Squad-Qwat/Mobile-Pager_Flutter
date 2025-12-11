import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:mobile_pager_flutter/core/theme/app_color.dart';
import 'package:mobile_pager_flutter/features/active_pagers/presentation/active_pagers_page.dart';
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
    // Merchant: [Home, Pagers, QR, History] - 4 items
    // Customer: [Home, Scan, History] - 3 items (no Pagers)
    final List<Widget> pages = isMerchant
        ? [
            const HomePage(),
            const ActivePagersPage(),
            const QRViewPage(),
            const HistoryPage(),
          ]
        : [
            const HomePage(),
            const PagerScanPage(),
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
              children: isMerchant
                  ? [
                      // Merchant: 4 items
                      _buildNavItem(
                        icon: Iconsax.home_copy,
                        selectedIcon: Iconsax.home_copy,
                        label: 'Home',
                        index: 0,
                      ),
                      _buildNavItem(
                        icon: Iconsax.receipt_copy,
                        selectedIcon: Iconsax.receipt,
                        label: 'Pagers',
                        index: 1,
                      ),
                      _buildNavItem(
                        icon: Iconsax.barcode_copy,
                        selectedIcon: Iconsax.barcode_copy,
                        label: 'QR',
                        index: 2,
                      ),
                      _buildNavItem(
                        icon: Iconsax.clock_copy,
                        selectedIcon: Iconsax.clock,
                        label: 'History',
                        index: 3,
                      ),
                    ]
                  : [
                      // Customer: 3 items
                      _buildNavItem(
                        icon: Iconsax.home_copy,
                        selectedIcon: Iconsax.home_copy,
                        label: 'Home',
                        index: 0,
                      ),
                      _buildNavItem(
                        icon: Iconsax.scan_copy,
                        selectedIcon: Iconsax.scan,
                        label: 'Scan',
                        index: 1,
                      ),
                      _buildNavItem(
                        icon: Iconsax.clock_copy,
                        selectedIcon: Iconsax.clock,
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
