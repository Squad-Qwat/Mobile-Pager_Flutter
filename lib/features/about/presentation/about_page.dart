import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pager_flutter/core/theme/app_color.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String _appVersion = '';
  String _buildNumber = '';

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
      _buildNumber = packageInfo.buildNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColor.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Tentang Aplikasi',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w800,
            color: AppColor.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // App Logo & Name Section
            _buildHeaderSection(),

            SizedBox(height: 24.h),

            // About Section
            _buildAboutSection(),

            SizedBox(height: 16.h),

            // Features Section
            _buildFeaturesSection(),

            SizedBox(height: 16.h),

            // Credits Section
            _buildCreditsSection(),

            SizedBox(height: 16.h),

            // Version Info
            _buildVersionSection(),

            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 40.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // App Icon
          Container(
            width: 100.w,
            height: 100.h,
            decoration: BoxDecoration(
              color: AppColor.primary,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColor.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              Icons.vibration,
              size: 60,
              color: Colors.white,
            ),
          ),

          SizedBox(height: 20.h),

          // App Name
          Text(
            'Call Management System',
            style: GoogleFonts.inter(
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              color: AppColor.black,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 8.h),

          // Subtitle
          Text(
            'Mobile Pager Application',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColor.primary, size: 24),
              SizedBox(width: 12.w),
              Text(
                'Tentang Aplikasi',
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColor.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            'Call Management System adalah aplikasi mobile pager modern yang membantu merchant mengelola antrian pelanggan secara efisien. Sistem ini memungkinkan pelanggan untuk menerima notifikasi real-time ketika pesanan mereka siap, mengurangi waktu tunggu dan meningkatkan kepuasan pelanggan.',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: Colors.grey[700],
              height: 1.6,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star_outline, color: AppColor.primary, size: 24),
              SizedBox(width: 12.w),
              Text(
                'Fitur Utama',
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColor.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          _buildFeatureItem(
            icon: Icons.qr_code_scanner,
            title: 'QR Code System',
            description: 'Scan QR untuk aktivasi pager secara cepat',
          ),
          SizedBox(height: 16.h),
          _buildFeatureItem(
            icon: Icons.notifications_active,
            title: 'Real-time Notifications',
            description: 'Notifikasi push dengan custom sound & vibration',
          ),
          SizedBox(height: 16.h),
          _buildFeatureItem(
            icon: Icons.analytics,
            title: 'Analytics Dashboard',
            description: 'Statistik dan analitik untuk merchant',
          ),
          SizedBox(height: 16.h),
          _buildFeatureItem(
            icon: Icons.people,
            title: 'Customer Management',
            description: 'Kelola daftar customer dan riwayat order',
          ),
          SizedBox(height: 16.h),
          _buildFeatureItem(
            icon: Icons.history,
            title: 'Order History',
            description: 'Riwayat lengkap semua transaksi',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: AppColor.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColor.primary, size: 24),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColor.black,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCreditsSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.workspace_premium, color: AppColor.primary, size: 24),
              SizedBox(width: 12.w),
              Text(
                'Credits',
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColor.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildCreditItem(
            title: 'Developed by',
            value: 'Mobile Development Team',
          ),
          SizedBox(height: 12.h),
          _buildCreditItem(
            title: 'Technology Stack',
            value: 'Flutter, Firebase, Riverpod',
          ),
          SizedBox(height: 12.h),
          _buildCreditItem(
            title: 'Design',
            value: 'Material Design 3',
          ),
          SizedBox(height: 12.h),
          _buildCreditItem(
            title: 'Project Type',
            value: 'Academic Project',
          ),
        ],
      ),
    );
  }

  Widget _buildCreditItem({required String title, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: AppColor.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildVersionSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.code, color: Colors.grey[400], size: 40),
          SizedBox(height: 12.h),
          Text(
            'Version $_appVersion',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColor.black,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Build #$_buildNumber',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            '© 2025 Call Management System',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'All rights reserved',
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
