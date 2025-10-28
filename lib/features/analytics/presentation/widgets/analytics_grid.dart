import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pager_flutter/core/theme/app_color.dart';
import 'package:mobile_pager_flutter/features/analytics/domain/models/analytics_model.dart';
import 'package:mobile_pager_flutter/features/analytics/presentation/providers/analytics_providers.dart';

class AnalyticsGrid extends ConsumerWidget {
  final String merchantId;

  const AnalyticsGrid({
    Key? key,
    required this.merchantId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(merchantAnalyticsProvider(merchantId));

    return analyticsAsync.when(
      loading: () => _buildLoadingGrid(),
      error: (error, stack) => _buildErrorGrid(),
      data: (analytics) => _buildAnalyticsGrid(analytics),
    );
  }

  Widget _buildLoadingGrid() {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12.h,
        crossAxisSpacing: 12.w,
        childAspectRatio: 1.3,
        children: List.generate(
          4,
          (index) => Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorGrid() {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Center(
        child: Text(
          'Failed to load analytics',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: Colors.red,
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsGrid(AnalyticsModel analytics) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12.h,
        crossAxisSpacing: 12.w,
        childAspectRatio: 1.3,
        children: [
          _buildAnalyticsCard(
            title: 'Hari Ini',
            value: '${analytics.todayPagers}',
            subtitle: 'Pagers',
            icon: Icons.today,
            color: AppColor.primary,
          ),
          _buildAnalyticsCard(
            title: 'Minggu Ini',
            value: '${analytics.weeklyPagers}',
            subtitle: 'Total',
            icon: Icons.calendar_month,
            color: Colors.blue,
          ),
          _buildAnalyticsCard(
            title: 'Rata-rata',
            value: '${analytics.averageWaitMinutes}',
            subtitle: 'Menit',
            icon: Icons.schedule,
            color: Colors.orange,
          ),
          _buildAnalyticsCard(
            title: 'Success Rate',
            value: '${analytics.completionRate.toStringAsFixed(0)}%',
            subtitle: 'Selesai',
            icon: Icons.check_circle,
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 16.sp,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 28.sp,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
