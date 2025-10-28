import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:mobile_pager_flutter/core/providers/navigation_provider.dart';
import 'package:mobile_pager_flutter/core/theme/app_color.dart';
import 'package:mobile_pager_flutter/features/pager/presentation/pages/active_pagers_page.dart';
import 'package:mobile_pager_flutter/features/authentication/presentation/providers/auth_providers.dart';
import 'package:mobile_pager_flutter/features/pager_history/presentation/pager_history_page.dart';
import 'package:mobile_pager_flutter/features/pager_qr_view/presentation/qr_view_page.dart';
import 'package:mobile_pager_flutter/features/pager_scan/presentation/pager_scan_page.dart';
import 'package:mobile_pager_flutter/features/home/presentation/home_page.dart';
import 'package:mobile_pager_flutter/features/pager/presentation/providers/pager_status_listener_provider.dart';

class MainNavigation extends ConsumerWidget {
  const MainNavigation({super.key});

  void _onItemTapped(WidgetRef ref, int index) {
    ref.read(navigationIndexProvider.notifier).state = index;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final isMerchant = authState.isMerchant;
    final selectedIndex = ref.watch(navigationIndexProvider);

    // Initialize pager status listener for customers
    // This will monitor pager status changes and show notifications
    if (!isMerchant && authState.isAuthenticated) {
      ref.watch(pagerStatusListenerProvider);
    }

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
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColor.white,
          // Pengganti withOpacity() karena dianggap usang oleh flutter
          border: Border(top: BorderSide(
            color: AppColor.black.withValues(alpha: 0.3), 
            width: 1)
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16, 
              vertical: 8
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: isMerchant
                  ? [
                      // Merchant: 4 items
                      _buildNavItem(
                        ref,
                        selectedIndex,
                        icon: Iconsax.home_copy,
                        selectedIcon: Iconsax.home_copy,
                        label: 'Home',
                        index: 0,
                      ),
                      _buildNavItem(
                        ref,
                        selectedIndex,
                        icon: Iconsax.receipt_copy,
                        selectedIcon: Iconsax.receipt,
                        label: 'Pagers',
                        index: 1,
                      ),
                      _buildNavItem(
                        ref,
                        selectedIndex,
                        icon: Iconsax.barcode_copy,
                        selectedIcon: Iconsax.barcode_copy,
                        label: 'QR',
                        index: 2,
                      ),
                      _buildNavItem(
                        ref,
                        selectedIndex,
                        icon: Iconsax.clock_copy,
                        selectedIcon: Iconsax.clock,
                        label: 'History',
                        index: 3,
                      ),
                    ]
                  : [
                      // Customer: 3 items
                      _buildNavItem(
                        ref,
                        selectedIndex,
                        icon: Iconsax.home_copy,
                        selectedIcon: Iconsax.home_copy,
                        label: 'Home',
                        index: 0,
                      ),
                      _buildNavItem(
                        ref,
                        selectedIndex,
                        icon: Iconsax.scan_copy,
                        selectedIcon: Iconsax.scan,
                        label: 'Scan',
                        index: 1,
                      ),
                      _buildNavItem(
                        ref,
                        selectedIndex,
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

  Widget _buildNavItem(
    WidgetRef ref,
    int selectedIndex, {
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
  }) {
    final isSelected = selectedIndex == index;

    return InkWell(
      onTap: () => _onItemTapped(ref, index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
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
