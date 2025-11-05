import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pager_flutter/core/theme/app_color.dart';
import 'package:mobile_pager_flutter/core/theme/app_padding.dart';
import 'package:mobile_pager_flutter/features/detail_history/presentation/detail_history_page.dart';
import 'package:mobile_pager_flutter/features/pager_history/domain/extended_dummy.dart';
import 'package:mobile_pager_flutter/features/pager_history/domain/history.dart';
import 'filter_widget.dart';
import 'history_filter_service.dart';

class HistoryPage extends StatefulWidget 
{
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> 
{
  List<History> _allHistory = [];
  List<History> _filteredHistory = [];
  HistoryFilterOptions _filterOptions = HistoryFilterOptions();

  // Pagination
  static const int _itemsPerPage = 10;
  int _currentPage = 0;
  bool _hasMore = true;

  @override
  void initState() 
  {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() 
  {
    setState(() 
    {
      // Load all data
      _allHistory = ExtendedDummyDataService.getExtendedDummyHistory();
      // Apply filters
      _applyFilters();
    });
  }

  void _applyFilters() 
  {
    setState(() 
    {
      _filteredHistory = HistoryFilterService.filterHistory(
        _allHistory,
        _filterOptions,
      );
      _currentPage = 0;
      _hasMore = _filteredHistory.length > _itemsPerPage;
    });
  }

  List<History> _getPaginatedHistory() 
  {
    final startIndex = 0;
    final endIndex = (_currentPage + 1) * _itemsPerPage;
    
    if (endIndex >= _filteredHistory.length) 
    {
      _hasMore = false;
      return _filteredHistory;
    }
    
    return _filteredHistory.sublist(startIndex, endIndex);
  }

  void _loadMore() {if (_hasMore && _filteredHistory.length > (_currentPage + 1) * _itemsPerPage) {setState(() {_currentPage++;});}}

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildHeader(),
      body: Column(
        children: <Widget>[
          // Filter Widget
          HistoryFilterWidget(
            currentOptions: _filterOptions,
            onFilterChanged: (newOptions) 
            {
              setState(() {_filterOptions = newOptions;});
              _applyFilters();
            },
          ),

          // Results Count
          _buildResultsInfo(),

          // History List
          Expanded(
            child: _filteredHistory.isEmpty ? _buildEmptyState() : RefreshIndicator(
              onRefresh: _refreshHistory,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: AppPadding.p16,
                  vertical: 8.h,
                ),
                itemCount: _getPaginatedHistory().length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) 
                {
                  if (index == _getPaginatedHistory().length) {return _buildLoadMoreButton();}
                  return _buildHistoryItem(_getPaginatedHistory()[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildHeader() 
  {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        'Pager History',
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w800,
          color: AppColor.black,
        ),
      ),
      actions: <Widget>[
        // Reset filter button
        IconButton(
          icon: Icon(Icons.refresh, color: AppColor.black),
          onPressed: () 
          {
            setState(() {_filterOptions = HistoryFilterOptions();});
            _applyFilters();
          },
          tooltip: 'Reset Filter',
        ),
        SizedBox(width: 8.w),
      ],
    );
  }

  Widget _buildResultsInfo() 
  {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w, 
        vertical: 8.h
      ),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            '${_filteredHistory.length} order ditemukan',
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          if (_filteredHistory.isNotEmpty)...[
            Text(
              HistoryFilterService.getTimeFilterLabel(_filterOptions),
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: AppColor.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _refreshHistory() async 
  {
    await Future.delayed(const Duration(milliseconds: 500));
    _loadHistory();
  }

  Widget _buildEmptyState() 
  {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.search_off, 
            size: 100.w, 
            color: Colors.grey[300]
          ),
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
            onPressed: () 
            {
              setState(() {_filterOptions = HistoryFilterOptions();});
              _applyFilters();
            },
            icon: Icon(Icons.refresh),
            label: Text('Reset Filter'),
            style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(
              horizontal: 24.w, 
              vertical: 12.h
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreButton() 
  {
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

  Widget _buildHistoryItem(History history) 
  {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: <BoxShadow>[
          BoxShadow(
            // Pengganti withOpacity() karena usang menurut flutter
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailHistoryPage(orderId: history.orderId))
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Header: ID & Date/Time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Text(
                    history.orderId,
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  history.getFormattedDate(),
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Details: Nomor Pager & Nama
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                // Nomor Pager Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Nomor Pager',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        history.queueNumber,
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                // Nama Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Nama',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        history.businessName ?? 'Guest',
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
            Divider(
              color: Colors.grey.shade300, 
              height: 1
            ),
            SizedBox(height: 12.h),

            // Footer: Status Badge & Detail Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    // Pengganti withOpacity() karena usang menurut flutter
                    color: _getStatusColor(history.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      // Pengganti withOpacity() karena usang menurut flutter
                      color: _getStatusColor(history.status).withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    history.getStatusText(),
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(history.status),
                    ),
                  ),
                ),
                Row(
                  children: <Widget>[
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

  Color _getStatusColor(String status) 
  {
    switch (status) 
    {
      case 'waiting':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'ready':
        return Colors.green;
      case 'picked_up':
        return Colors.lightGreen;
      case 'finished':
        return Colors.grey;
      case 'expired':
        return Colors.red;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}