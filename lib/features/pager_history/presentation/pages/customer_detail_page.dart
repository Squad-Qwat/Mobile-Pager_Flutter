import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pager_flutter/core/theme/app_color.dart';
import 'package:mobile_pager_flutter/features/detail_history/presentation/detail_history_page.dart';
import 'package:mobile_pager_flutter/features/pager/domain/models/pager_model.dart';
import 'package:mobile_pager_flutter/features/pager_history/presentation/providers/customer_stats_providers.dart';

class CustomerDetailPage extends ConsumerWidget {
  final String merchantId;
  final String customerId;
  final String customerName;

  const CustomerDetailPage({
    Key? key,
    required this.merchantId,
    required this.customerId,
    required this.customerName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerHistoryAsync = ref.watch(
      customerPagerHistoryProvider(
        CustomerHistoryParams(
          merchantId: merchantId,
          customerId: customerId,
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColor.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detail Customer',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w800,
                color: AppColor.black,
                fontSize: 18.sp,
              ),
            ),
            Text(
              customerName,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ),
      body: customerHistoryAsync.when(
        data: (pagers) {
          if (pagers.isEmpty) {
            return _buildEmptyState();
          }

          // Calculate statistics
          final totalOrders = pagers.length;
          final finishedOrders = pagers
              .where((p) => p.status == PagerStatus.finished)
              .length;
          final expiredOrders = pagers
              .where((p) => p.status == PagerStatus.expired)
              .length;

          return Column(
            children: [
              // Statistics Summary
              _buildStatisticsSummary(
                totalOrders: totalOrders,
                finishedOrders: finishedOrders,
                expiredOrders: expiredOrders,
              ),

              // Order History List
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  itemCount: pagers.length,
                  itemBuilder: (context, index) {
                    return _buildOrderCard(context, pagers[index]);
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(error),
      ),
    );
  }

  Widget _buildStatisticsSummary({
    required int totalOrders,
    required int finishedOrders,
    required int expiredOrders,
  }) {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
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
          Text(
            'Ringkasan Statistik',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColor.black,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  label: 'Total Order',
                  value: '$totalOrders',
                  icon: Icons.receipt_long,
                  color: Colors.blue,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatCard(
                  label: 'Selesai',
                  value: '$finishedOrders',
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatCard(
                  label: 'Expired',
                  value: '$expiredOrders',
                  icon: Icons.cancel,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          SizedBox(height: 8.h),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, PagerModel pager) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    final formattedDate = pager.activatedAt != null
        ? dateFormat.format(pager.activatedAt!)
        : dateFormat.format(pager.createdAt);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
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
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailHistoryPage(pagerId: pager.pagerId),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: ID & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    pager.displayId,
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: _getStatusColor(pager.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _getStatusColor(pager.status).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _getStatusText(pager.status),
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(pager.status),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Date/Time
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                SizedBox(width: 6.w),
                Text(
                  formattedDate,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),

            // Pager Number & Label
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.tag, size: 14, color: Colors.grey[600]),
                    SizedBox(width: 6.w),
                    Text(
                      'Nomor: #${pager.queueNumber ?? pager.number}',
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (pager.label != null)
                  Text(
                    pager.label!,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),

            SizedBox(height: 12.h),

            // View Detail Link
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Lihat Detail',
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColor.primary,
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: AppColor.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 100.w, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text(
            'Belum Ada Riwayat',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Customer ini belum pernah melakukan order',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          SizedBox(height: 16.h),
          Text(
            'Error memuat data',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            error.toString(),
            style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(PagerStatus status) {
    switch (status) {
      case PagerStatus.waiting:
        return Colors.orange;
      case PagerStatus.ready:
      case PagerStatus.ringing:
        return Colors.blue;
      case PagerStatus.finished:
        return Colors.grey;
      case PagerStatus.expired:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(PagerStatus status) {
    switch (status) {
      case PagerStatus.waiting:
        return 'Menunggu';
      case PagerStatus.ready:
        return 'Siap Diambil';
      case PagerStatus.ringing:
        return 'Berdering';
      case PagerStatus.finished:
        return 'Selesai';
      case PagerStatus.expired:
        return 'Kedaluwarsa';
      case PagerStatus.temporary:
        return 'Temporary';
    }
  }
}
