import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pager_flutter/core/theme/app_color.dart';
import 'package:mobile_pager_flutter/core/theme/app_padding.dart';
import 'package:mobile_pager_flutter/features/authentication/presentation/providers/auth_providers.dart';
import 'package:mobile_pager_flutter/features/detail_history/presentation/detail_history_page.dart';
import 'package:mobile_pager_flutter/features/merchant/presentation/providers/merchant_settings_providers.dart';
import 'package:mobile_pager_flutter/features/pager/domain/models/pager_model.dart';
import 'package:mobile_pager_flutter/features/pager/presentation/providers/pager_providers.dart';
import 'package:mobile_pager_flutter/features/pager_history/presentation/filter_widget.dart';
import 'package:mobile_pager_flutter/features/pager_history/presentation/widgets/customer_list_view.dart';
import 'history_filter_service.dart';

enum HistoryViewMode {
  allHistory,
  perCustomer,
}

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  HistoryFilterOptions _filterOptions = HistoryFilterOptions();
  HistoryViewMode _viewMode = HistoryViewMode.allHistory;

  // Pagination
  static const int _itemsPerPage = 10;
  int _currentPage = 0;

  void _applyFilters() {
    setState(() {
      _currentPage = 0;
    });
  }

  List<PagerModel> _applyLocalFilters(List<PagerModel> pagers) {
    List<PagerModel> filtered = List.from(pagers);

    // Apply time filter
    if (_filterOptions.timeFilter != 'all') {
      final now = DateTime.now();
      filtered = filtered.where((pager) {
        final pagerDate = pager.activatedAt ?? pager.createdAt;

        switch (_filterOptions.timeFilter) {
          case 'today':
            return pagerDate.year == now.year &&
                pagerDate.month == now.month &&
                pagerDate.day == now.day;
          case 'yesterday':
            final yesterday = now.subtract(const Duration(days: 1));
            return pagerDate.year == yesterday.year &&
                pagerDate.month == yesterday.month &&
                pagerDate.day == yesterday.day;
          case 'this_week':
            final weekStart = now.subtract(Duration(days: now.weekday - 1));
            return pagerDate.isAfter(weekStart.subtract(const Duration(days: 1)));
          case 'this_month':
            return pagerDate.year == now.year && pagerDate.month == now.month;
          case 'last_month':
            final lastMonth = DateTime(now.year, now.month - 1);
            return pagerDate.year == lastMonth.year &&
                pagerDate.month == lastMonth.month;
          default:
            return true;
        }
      }).toList();
    }

    // Apply search query
    if (_filterOptions.searchQuery.isNotEmpty) {
      final query = _filterOptions.searchQuery.toLowerCase();
      filtered = filtered.where((pager) {
        final displayId = pager.displayId.toLowerCase();
        final queueNumber = pager.queueNumber?.toString().toLowerCase() ?? '';
        return displayId.contains(query) || queueNumber.contains(query);
      }).toList();
    }

    // Apply sorting
    filtered.sort((a, b) {
      final dateA = a.activatedAt ?? a.createdAt;
      final dateB = b.activatedAt ?? b.createdAt;

      if (_filterOptions.sortOrder == SortOrder.dateDescending) {
        return dateB.compareTo(dateA);
      } else {
        return dateA.compareTo(dateB);
      }
    });

    return filtered;
  }

  List<PagerModel> _getPaginatedPagers(List<PagerModel> pagers) {
    final startIndex = 0;
    final endIndex = (_currentPage + 1) * _itemsPerPage;

    if (endIndex >= pagers.length) {
      return pagers;
    }

    return pagers.sublist(startIndex, endIndex);
  }

  bool _hasMore(List<PagerModel> pagers) {
    return pagers.length > (_currentPage + 1) * _itemsPerPage;
  }

  void _loadMore() {
    setState(() {
      _currentPage++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: _buildHeader(),
        body: const Center(child: Text('Please login')),
      );
    }

    // Get appropriate stream based on user role
    final historyPagersAsync = user.isMerchant
        ? ref.watch(merchantHistoryPagersStreamProvider(user.uid))
        : ref.watch(customerHistoryPagersStreamProvider(user.uid));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildHeader(),
      body: Column(
        children: [
          // View Mode Selector (Only for merchant)
          if (user.isMerchant) _buildViewModeSelector(),

          // Content based on view mode
          Expanded(
            child: _viewMode == HistoryViewMode.allHistory
                ? _buildAllHistoryView(historyPagersAsync)
                : CustomerListView(merchantId: user.uid),
          ),
        ],
      ),
    );
  }

  Widget _buildViewModeSelector() {
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
      child: Row(
        children: [
          Text(
            'Tampilan:',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<HistoryViewMode>(
                  value: _viewMode,
                  isExpanded: true,
                  icon: Icon(Icons.arrow_drop_down, color: AppColor.primary),
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColor.primary,
                  ),
                  items: [
                    DropdownMenuItem(
                      value: HistoryViewMode.allHistory,
                      child: Text('Semua Riwayat'),
                    ),
                    DropdownMenuItem(
                      value: HistoryViewMode.perCustomer,
                      child: Text('Per Customer'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _viewMode = value;
                      });
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllHistoryView(AsyncValue<List<PagerModel>> historyPagersAsync) {
    return historyPagersAsync.when(
      data: (pagers) {
        final filteredPagers = _applyLocalFilters(pagers);
        final paginatedPagers = _getPaginatedPagers(filteredPagers);
        final hasMore = _hasMore(filteredPagers);

        return Column(
          children: [
            // Filter Widget
            HistoryFilterWidget(
              currentOptions: _filterOptions,
              onFilterChanged: (newOptions) {
                setState(() {
                  _filterOptions = newOptions;
                });
                _applyFilters();
              },
            ),

            // Results Count
            _buildResultsInfo(filteredPagers.length),

            // History List
            Expanded(
              child: filteredPagers.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: () async {
                        // Refresh is handled automatically by stream
                        await Future.delayed(const Duration(milliseconds: 500));
                      },
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppPadding.p16,
                          vertical: 8.h,
                        ),
                        itemCount: paginatedPagers.length + (hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == paginatedPagers.length) {
                            return _buildLoadMoreButton();
                          }
                          return _buildHistoryItem(paginatedPagers[index]);
                        },
                      ),
                    ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Error loading history',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildHeader() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        'History',
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w800,
          color: AppColor.black,
        ),
      ),
      actions: [
        // Reset filter button
        SizedBox(width: 8.w),
      ],
    );
  }

  Widget _buildResultsInfo(int count) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$count order ditemukan',
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          if (count > 0)
            Text(
              HistoryFilterService.getTimeFilterLabel(_filterOptions),
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: AppColor.primary,
                fontWeight: FontWeight.w600,
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
          Icon(Icons.search_off, size: 100.w, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text(
            'Tidak Ada History',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Coba ubah filter pencarian',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _filterOptions = HistoryFilterOptions();
              });
              _applyFilters();
            },
            icon: Icon(Icons.refresh),
            label: Text('Reset Filter'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Center(
        child: ElevatedButton(
          onPressed: _loadMore,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.primary,
            padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
          ),
          child: Text(
            'Muat Lebih Banyak',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(PagerModel pager) {
    final dateFormat = DateFormat('dd MMM yyyy');
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
            // Header: ID & Date/Time
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
                Text(
                  formattedDate,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Merchant/Customer Info
            _buildMerchantOrCustomerInfo(pager),
            SizedBox(height: 12.h),

            // Details: Nomor Pager & Label
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Nomor Pager Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nomor Pager',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '#${pager.queueNumber ?? pager.number}',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                // Label Column
                if (pager.label != null)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lokasi',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          pager.label!,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            SizedBox(height: 12.h),

            // Divider
            Divider(color: Colors.grey.shade300, height: 1),
            SizedBox(height: 12.h),

            // Footer: Status Badge & Detail Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                Row(
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
          ],
        ),
      ),
    );
  }

  Widget _buildMerchantOrCustomerInfo(PagerModel pager) {
    final authState = ref.watch(authNotifierProvider);
    final isMerchant = authState.user?.isMerchant ?? false;

    if (isMerchant) {
      // Show customer name for merchant
      if (pager.customerId == null) {
        return SizedBox.shrink();
      }

      final customerAsync = ref.watch(userByIdProvider(pager.customerId!));

      return customerAsync.when(
        data: (customer) {
          if (customer == null) return SizedBox.shrink();

          return Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColor.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Iconsax.user,
                  size: 14,
                  color: AppColor.primary,
                ),
                SizedBox(width: 6.w),
                Flexible(
                  child: Text(
                    customer.displayName ?? customer.email ?? 'Customer',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: AppColor.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => SizedBox.shrink(),
        error: (_, __) => SizedBox.shrink(),
      );
    } else {
      // Show merchant name for customer
      final merchantSettingsAsync =
          ref.watch(merchantSettingsFutureProvider(pager.merchantId));

      return merchantSettingsAsync.when(
        data: (merchantSettings) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColor.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Iconsax.shop,
                  size: 14,
                  color: AppColor.primary,
                ),
                SizedBox(width: 6.w),
                Flexible(
                  child: Text(
                    merchantSettings.merchantName,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: AppColor.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                'Loading...',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        error: (error, stack) => SizedBox.shrink(),
      );
    }
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
