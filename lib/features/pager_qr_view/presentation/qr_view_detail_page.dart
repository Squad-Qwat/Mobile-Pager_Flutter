import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pager_flutter/core/theme/app_color.dart';
import 'package:mobile_pager_flutter/core/theme/app_padding.dart';
import 'package:mobile_pager_flutter/features/pager/domain/models/pager_model.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

class QrDetailPage extends ConsumerStatefulWidget {
  final PagerModel pager;

  const QrDetailPage({super.key, required this.pager});

  @override
  ConsumerState<QrDetailPage> createState() => _QrDetailPageState();
}

class _QrDetailPageState extends ConsumerState<QrDetailPage> {
  void poppingButtons() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
  }

  String _getStatusText(PagerStatus status) {
    switch (status) {
      case PagerStatus.temporary:
        return 'Belum Diaktifkan';
      case PagerStatus.waiting:
        return 'Menunggu';
      case PagerStatus.ready:
        return 'Siap';
      case PagerStatus.ringing:
        return 'Sedang Dipanggil';
      case PagerStatus.finished:
        return 'Selesai';
      case PagerStatus.expired:
        return 'Kadaluarsa';
    }
  }

  Color _getStatusColor(PagerStatus status) {
    switch (status) {
      case PagerStatus.temporary:
        return Colors.grey;
      case PagerStatus.waiting:
        return AppColor.warning;
      case PagerStatus.ready:
        return AppColor.success;
      case PagerStatus.ringing:
        return AppColor.accent;
      case PagerStatus.finished:
        return AppColor.primary;
      case PagerStatus.expired:
        return AppColor.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pager = widget.pager;
    
    final qrData = jsonEncode({
      'pagerId': pager.pagerId,
      'merchantId': pager.merchantId,
      'number': pager.number,
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detail QR',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppColor.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Iconsax.arrow_left_copy,
            color: AppColor.textPrimary,
          ),
          onPressed: poppingButtons,
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      backgroundColor: AppColor.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppPadding.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Pager ID Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColor.primary, AppColor.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    pager.displayId,
                    style: GoogleFonts.poppins(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: _getStatusColor(pager.status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _getStatusText(pager.status),
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // QR Code Section
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Scan untuk Aktivasi',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColor.textPrimary,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColor.grey200, width: 2),
                    ),
                    child: SizedBox(
                      width: 200.w,
                      height: 200.w,
                      child: PrettyQrView.data(
                        data: qrData,
                        decoration: const PrettyQrDecoration(
                          quietZone: PrettyQrQuietZone.standart,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    pager.label ?? 'Pager #${pager.number}',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: AppColor.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // Info Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informasi Pager',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColor.textPrimary,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  
                  // Label/Name
                  _buildInfoRow(
                    icon: Iconsax.tag_copy,
                    title: 'Label',
                    value: pager.label ?? '-',
                  ),
                  Divider(height: 24.h, color: AppColor.grey200),
                  
                  // Pager Number
                  _buildInfoRow(
                    icon: Iconsax.hashtag,
                    title: 'Nomor Pager',
                    value: '#${pager.number}',
                  ),
                  Divider(height: 24.h, color: AppColor.grey200),
                  
                  // Created At
                  _buildInfoRow(
                    icon: Iconsax.calendar_add,
                    title: 'Dibuat pada',
                    value: _formatDateTime(pager.createdAt),
                  ),
                  
                  // Activated At (if available)
                  if (pager.activatedAt != null) ...[
                    Divider(height: 24.h, color: AppColor.grey200),
                    _buildInfoRow(
                      icon: Iconsax.tick_circle,
                      title: 'Diaktifkan pada',
                      value: _formatDateTime(pager.activatedAt!),
                      valueColor: AppColor.success,
                    ),
                  ],
                  
                  // Expires At (if available)
                  if (pager.expiresAt != null) ...[
                    Divider(height: 24.h, color: AppColor.grey200),
                    _buildInfoRow(
                      icon: Iconsax.timer_1,
                      title: 'Kadaluarsa pada',
                      value: _formatDateTime(pager.expiresAt!),
                      valueColor: AppColor.warning,
                    ),
                  ],
                  
                  // Notes (if available)
                  if (pager.notes != null && pager.notes!.isNotEmpty) ...[
                    Divider(height: 24.h, color: AppColor.grey200),
                    _buildInfoRow(
                      icon: Iconsax.note,
                      title: 'Catatan',
                      value: pager.notes!,
                    ),
                  ],
                  
                  // Ringing Count (if > 0)
                  if (pager.ringingCount > 0) ...[
                    Divider(height: 24.h, color: AppColor.grey200),
                    _buildInfoRow(
                      icon: Iconsax.notification,
                      title: 'Jumlah Panggilan',
                      value: '${pager.ringingCount}x',
                      valueColor: AppColor.accent,
                    ),
                  ],
                  
                  // Scanned By (if available)
                  if (pager.scannedBy != null) ...[
                    Divider(height: 24.h, color: AppColor.grey200),
                    _buildInfoRow(
                      icon: Iconsax.user,
                      title: 'Discan oleh',
                      value: pager.scannedBy!['name'] ?? pager.scannedBy!['email'] ?? 'Customer',
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // Invoice Image Preview (if available)
            if (pager.invoiceImageUrl != null) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Iconsax.receipt_item, size: 20, color: AppColor.grey700),
                        SizedBox(width: 8.w),
                        Text(
                          'Struk/Invoice',
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColor.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        pager.invoiceImageUrl!,
                        width: double.infinity,
                        height: 150.h,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 150.h,
                            color: AppColor.grey100,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 150.h,
                            color: AppColor.grey100,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Iconsax.image, size: 40, color: AppColor.grey400),
                                  SizedBox(height: 8.h),
                                  Text(
                                    'Gagal memuat gambar',
                                    style: GoogleFonts.inter(
                                      fontSize: 12.sp,
                                      color: AppColor.grey500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
            ],

            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColor.grey600),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: AppColor.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? AppColor.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
