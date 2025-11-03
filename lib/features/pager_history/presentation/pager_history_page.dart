import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pager_flutter/core/domains/orders_history_dummy.dart';
import 'package:mobile_pager_flutter/core/theme/app_color.dart';
import 'package:mobile_pager_flutter/core/theme/app_padding.dart';
import 'package:mobile_pager_flutter/features/detail_history/presentation/detail_history_page.dart';
import 'package:mobile_pager_flutter/features/pager_history/domain/history.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String _selectedFilter = 'all'; // all, active, finished
  List<History> _historyList = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    setState(() {
      final allHistory = DummyDataService.getDummyHistory();
      _historyList = DummyDataService.filterHistory(
        allHistory,
        _selectedFilter,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildHeader(),
      body: _historyList.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _refreshHistory,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: AppPadding.p16,
                  vertical: 8.h,
                ),
                itemCount: _historyList.length,
                itemBuilder: (context, index) {
                  return _buildHistoryItem(_historyList[index]);
                },
              ),
            ),
    );
  }

  PreferredSizeWidget _buildHeader() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      actionsPadding: EdgeInsets.symmetric(horizontal: 16),
      title: Text(
        'Pager History',
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w800,
          color: AppColor.black,
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          icon: Icon(Icons.filter_list, color: AppColor.black),
          onSelected: (value) {
            setState(() {
              _selectedFilter = value;
              _loadHistory();
            });
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'all',
              child: Text('Semua', style: GoogleFonts.inter()),
            ),
            PopupMenuItem(
              value: 'active',
              child: Text('Aktif', style: GoogleFonts.inter()),
            ),
            PopupMenuItem(
              value: 'finished',
              child: Text('Selesai', style: GoogleFonts.inter()),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _refreshHistory() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _loadHistory();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 100.w, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text(
            'Belum Ada History',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Order kamu akan muncul disini',
            style: GoogleFonts.inter(fontSize: 14.sp, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(History history) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.symmetric(vertical: AppPadding.p12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailHistoryPage(orderId: history.orderId),
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
                Text(
                  history.orderId,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  history.getFormattedDate(),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Details: Nomor Pager & Nama
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Nomor Pager Column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nomor Pager',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      history.queueNumber,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                // Nama Column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nama',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      history.businessName ?? 'Guest',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),

            // Divider
            Divider(color: Colors.grey.shade300, height: 1),
            SizedBox(height: 12),

            // Footer: Status Badge & Detail Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(history.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _getStatusColor(history.status).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    history.getStatusText(),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(history.status),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'Lihat Detail',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColor.primary,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward,
                      size: 18,
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

  Color _getStatusColor(String status) {
    switch (status) {
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
