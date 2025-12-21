import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pager_flutter/core/theme/app_color.dart';
import 'package:mobile_pager_flutter/core/theme/app_padding.dart';
import 'package:mobile_pager_flutter/features/authentication/presentation/providers/auth_providers.dart';
import 'package:mobile_pager_flutter/features/detail_history/presentation/detail_history_page.dart';
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
    final now = DateTime.now();
    filtered = filtered.where((pager) {
      final pagerDate = pager.activatedAt ?? pager.createdAt;

      switch (_filterOptions.timeFilter) {
        case TimeFilter.today:
          return pagerDate.year == now.year &&
              pagerDate.month == now.month &&
              pagerDate.day == now.day;
        case TimeFilter.thisWeek:
          final weekStart = now.subtract(Duration(days: now.weekday - 1));
          return pagerDate.isAfter(weekStart.subtract(const Duration(days: 1)));
        case TimeFilter.thisMonth:
          return pagerDate.year == now.year && pagerDate.month == now.month;
        case TimeFilter.customRange:
        case TimeFilter.customMonthYear:
          return true; // Handle custom ranges if needed
      }
    }).toList();

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
          // Integrated Filter Bar (for merchant includes view mode)
          _buildIntegratedFilterBar(user.isMerchant),

          // Content based on view mode
          Expanded(
            child: _viewMode == HistoryViewMode.allHistory
                ? _buildAllHistoryContent(historyPagersAsync)
                : CustomerListView(merchantId: user.uid),
          ),
        ],
      ),
    );
  }

  Widget _buildIntegratedFilterBar(bool isMerchant) {
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
      child: Column(
        children: [
          // Search Bar
          TextField(
            onChanged: (value) {
              setState(() {
                _filterOptions = _filterOptions.copyWith(searchQuery: value);
              });
              _applyFilters();
            },
            decoration: InputDecoration(
              hintText: 'Cari order ID atau nomor pager...',
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
          SizedBox(height: 12.h),

          // Filter Row: Time Filter + View Mode (for merchant) + Sort
          Row(
            children: [
              // Time Filter Dropdown
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<TimeFilter>(
                      value: _filterOptions.timeFilter,
                      isExpanded: true,
                      icon: Icon(Icons.arrow_drop_down, size: 20, color: Colors.grey[700]),
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                      items: [
                        DropdownMenuItem(
                          value: TimeFilter.today,
                          child: Text('Hari Ini'),
                        ),
                        DropdownMenuItem(
                          value: TimeFilter.thisWeek,
                          child: Text('Minggu Ini'),
                        ),
                        DropdownMenuItem(
                          value: TimeFilter.thisMonth,
                          child: Text('Bulan Ini'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _filterOptions = _filterOptions.copyWith(timeFilter: value);
                          });
                          _applyFilters();
                        }
                      },
                    ),
                  ),
                ),
              ),
              
              SizedBox(width: 8.w),

              // View Mode Dropdown (only for merchant)
              if (isMerchant)
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<HistoryViewMode>(
                        value: _viewMode,
                        isExpanded: true,
                        icon: Icon(Icons.arrow_drop_down, size: 20, color: Colors.grey[700]),
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                        items: [
                          DropdownMenuItem(
                            value: HistoryViewMode.allHistory,
                            child: Text('Riwayat'),
                          ),
                          DropdownMenuItem(
                            value: HistoryViewMode.perCustomer,
                            child: Text('Customer'),
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
              
              if (isMerchant) SizedBox(width: 8.w),

              // Sort Toggle Button
              InkWell(
                onTap: () {
                  setState(() {
                    _filterOptions = _filterOptions.copyWith(
                      sortOrder: _filterOptions.sortOrder == SortOrder.dateDescending
                          ? SortOrder.dateAscending
                          : SortOrder.dateDescending,
                    );
                  });
                  _applyFilters();
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _filterOptions.sortOrder == SortOrder.dateAscending
                        ? AppColor.primary
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _filterOptions.sortOrder == SortOrder.dateAscending
                          ? AppColor.primary
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: Icon(
                    _filterOptions.sortOrder == SortOrder.dateDescending
                        ? Icons.arrow_downward
                        : Icons.arrow_upward,
                    size: 20,
                    color: _filterOptions.sortOrder == SortOrder.dateAscending
                        ? Colors.white
                        : Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showTimeFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Filter Waktu', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTimeFilterOption('Hari Ini', TimeFilter.today),
            _buildTimeFilterOption('Minggu Ini', TimeFilter.thisWeek),
            _buildTimeFilterOption('Bulan Ini', TimeFilter.thisMonth),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeFilterOption(String label, TimeFilter filter) {
    return ListTile(
      title: Text(label, style: GoogleFonts.inter()),
      trailing: _filterOptions.timeFilter == filter
          ? Icon(Icons.check, color: AppColor.primary)
          : null,
      onTap: () {
        Navigator.pop(context);
        setState(() {
          _filterOptions = _filterOptions.copyWith(timeFilter: filter);
        });
        _applyFilters();
      },
    );
  }

  Widget _buildAllHistoryContent(AsyncValue<List<PagerModel>> historyPagersAsync) {
    return historyPagersAsync.when(
      data: (pagers) {
        final filteredPagers = _applyLocalFilters(pagers);
        final paginatedPagers = _getPaginatedPagers(filteredPagers);
        final hasMore = _hasMore(filteredPagers);

        return Column(
          children: [

            // Results Count
            _buildResultsInfo(filteredPagers.length),

            // History List
            Expanded(
              child: filteredPagers.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
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
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: ID & Status Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        pager.displayId,
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: _getStatusColor(pager.status),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _getStatusText(pager.status).toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // Details Row: Queue Number & Label
                Row(
                  children: [
                    // Queue Number
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Queue',
                            style: GoogleFonts.inter(
                              fontSize: 11.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            '#${pager.queueNumber ?? pager.number}',
                            style: GoogleFonts.inter(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Label if exists
                    if (pager.label != null)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Lokasi',
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              pager.label!,
                              style: GoogleFonts.inter(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                    // Date
                    Text(
                      formattedDate,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // Divider
                Divider(color: Colors.grey.shade200, height: 1),
                SizedBox(height: 12.h),

                // Footer: View Detail Link
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
        ),
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
