import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pager_flutter/core/theme/app_color.dart';
import 'package:mobile_pager_flutter/features/pager_history/domain/models/customer_stats_model.dart';
import 'package:mobile_pager_flutter/features/pager_history/presentation/providers/customer_stats_providers.dart';

class CustomerListView extends ConsumerStatefulWidget {
  final String merchantId;

  const CustomerListView({
    Key? key,
    required this.merchantId,
  }) : super(key: key);

  @override
  ConsumerState<CustomerListView> createState() => _CustomerListViewState();
}

class _CustomerListViewState extends ConsumerState<CustomerListView> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final customerStatsAsync = ref.watch(customerStatsListProvider(widget.merchantId));

    return customerStatsAsync.when(
      data: (customerStats) {
        // Apply search filter
        final filteredCustomers = _searchQuery.isEmpty
            ? customerStats
            : customerStats.where((customer) {
                final query = _searchQuery.toLowerCase();
                final name = customer.customerName.toLowerCase();
                final email = customer.customerEmail.toLowerCase();
                return name.contains(query) || email.contains(query);
              }).toList();

        return Column(
          children: [
            // Search bar
            _buildSearchBar(),

            // Customer list
            Expanded(
              child: filteredCustomers.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: () async {
                        ref.invalidate(customerStatsListProvider(widget.merchantId));
                        await Future.delayed(const Duration(milliseconds: 500));
                      },
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                        itemCount: filteredCustomers.length,
                        itemBuilder: (context, index) {
                          return _buildCustomerCard(context, filteredCustomers[index]);
                        },
                      ),
                    ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Cari nama atau email customer...',
          hintStyle: GoogleFonts.inter(
            fontSize: 14.sp,
            color: Colors.grey[500],
          ),
          prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        ),
        style: GoogleFonts.inter(fontSize: 14.sp),
      ),
    );
  }

  Widget _buildCustomerCard(BuildContext context, CustomerStatsModel customer) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final lastOrderText = customer.lastOrderDate != null
        ? dateFormat.format(customer.lastOrderDate!)
        : 'Tidak ada';

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Customer Name & Email
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColor.primary.withOpacity(0.1),
                child: Text(
                  customer.customerName.isNotEmpty
                      ? customer.customerName[0].toUpperCase()
                      : '?',
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColor.primary,
                  ),
                ),
              ),
              SizedBox(width: 12.w),

              // Name & Email
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.customerName,
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColor.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      customer.customerEmail,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Divider
          Divider(color: Colors.grey.shade300, height: 1),
          SizedBox(height: 12.h),

          // Statistics Row
          Row(
            children: [
              // Total Orders
              Expanded(
                child: _buildStatItem(
                  icon: Icons.receipt_long,
                  label: 'Total Order',
                  value: '${customer.totalOrders}',
                  color: Colors.blue,
                ),
              ),

              SizedBox(width: 12.w),

              // Average Wait Time
              Expanded(
                child: _buildStatItem(
                  icon: Icons.schedule,
                  label: 'Rata-rata',
                  value: '${customer.averageWaitMinutes.toStringAsFixed(0)} mnt',
                  color: Colors.orange,
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Last Order Date
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
              SizedBox(width: 6.w),
              Text(
                'Terakhir order: $lastOrderText',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // View Detail Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/customer_detail',
                  arguments: {
                    'merchantId': widget.merchantId,
                    'customerId': customer.customerId,
                    'customerName': customer.customerName,
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                padding: EdgeInsets.symmetric(vertical: 10.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Lihat Detail Riwayat',
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Icon(Icons.arrow_forward, size: 16, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
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
          Icon(icon, size: 20, color: color),
          SizedBox(height: 6.h),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 100.w, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text(
            'Belum Ada Customer',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Customer yang terdaftar akan muncul di sini',
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
            'Error memuat data customer',
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
}
