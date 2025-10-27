import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:mobile_pager_flutter/core/theme/app_color.dart';
import 'package:mobile_pager_flutter/features/home/presentation/home_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const TransactionPage(),
    const InboxPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
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
                  icon: Iconsax.barcode_copy,
                  selectedIcon: Iconsax.barcode_copy,
                  label: 'Pager QR',
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
              style: GoogleFonts.dmSans(
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

// Placeholder pages for Transaction and Inbox
class TransactionPage extends StatelessWidget {
  const TransactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Transaction',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.bold,
            color: AppColor.textPrimary,
          ),
        ),
        backgroundColor: AppColor.white,
        elevation: 0,
      ),
      body: Center(
        child: Text(
          'Transaction Page',
          style: GoogleFonts.dmSans(fontSize: 18, color: AppColor.textPrimary),
        ),
      ),
    );
  }
}

class InboxPage extends StatelessWidget {
  const InboxPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Inbox',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.bold,
            color: AppColor.textPrimary,
          ),
        ),
        backgroundColor: AppColor.white,
        elevation: 0,
      ),
      body: Center(
        child: Text(
          'Inbox Page',
          style: GoogleFonts.dmSans(fontSize: 18, color: AppColor.textPrimary),
        ),
      ),
    );
  }
}
