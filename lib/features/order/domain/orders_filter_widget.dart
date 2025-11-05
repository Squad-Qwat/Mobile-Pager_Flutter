// history_filter_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pager_flutter/core/theme/app_color.dart'; // Assuming AppColor is here
import 'orders_filter_service.dart';

// Helper extension to replace deprecated .withOpacity()
extension ColorOpacity on Color {
  Color withValues({double? alpha}) {
    if (alpha == null) return this;
    return this.withAlpha((255 * alpha).round().clamp(0, 255));
  }
}

class OrdersHistoryFilterWidget extends StatefulWidget {
  final OrdersHistoryFilterOptions currentOptions;
  final Function(OrdersHistoryFilterOptions) onFilterChanged;

  const OrdersHistoryFilterWidget({Key? key, required this.currentOptions, required this.onFilterChanged})
      : super(key: key);

  @override
  State<OrdersHistoryFilterWidget> createState() => _HistoryFilterWidgetState();
}

class _HistoryFilterWidgetState extends State<OrdersHistoryFilterWidget> {
  late OrdersHistoryFilterOptions _options;

  @override
  void initState() {
    super.initState();
    _options = widget.currentOptions;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          // Search Bar
          _buildSearchBar(),
          SizedBox(height: 12.h),

          // Filter Chips Row
          Row(
            children: <Widget>[
              Expanded(child: _buildTimeFilterButton()),
              SizedBox(width: 8.w),
              _buildStatusFilterButton(),
              SizedBox(width: 8.w),
              _buildSortButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      onChanged: (value) {
        setState(() {
          _options = _options.copyWith(searchQuery: value);
        });
        widget.onFilterChanged(_options);
      },
      decoration: InputDecoration(
        hintText: 'Cari order ID, nomor pager, atau nama...',
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
    );
  }

  Widget _buildTimeFilterButton() {
    return InkWell(
      onTap: _showTimeFilterDialog,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColor.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColor.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today, size: 16, color: AppColor.primary),
            SizedBox(width: 6.w),
            Expanded(
              child: Text(
                OrdersHistoryFilterService.getTimeFilterLabel(_options),
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColor.primary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.arrow_drop_down, size: 20, color: AppColor.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusFilterButton() {
    return PopupMenuButton<List<String>>(
      icon: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.filter_list, size: 20, color: Colors.grey[700]),
      ),
      onSelected: (value) {
        setState(() {
          _options = _options.copyWith(statusFilter: value);
        });
        widget.onFilterChanged(_options);
      },
      itemBuilder: (context) => <PopupMenuEntry<List<String>>>[
        PopupMenuItem(
          value: const ['finished', 'expired', 'cancelled'],
          child: Text('Selesai', style: GoogleFonts.inter()),
        ),
        PopupMenuItem(
          value: const ['waiting', 'processing', 'ready', 'picked_up'],
          child: Text('Aktif', style: GoogleFonts.inter()),
        ),
        PopupMenuItem(
          value: const ['all'],
          child: Text('Semua', style: GoogleFonts.inter()),
        ),
      ],
    );
  }

  Widget _buildSortButton() {
    return PopupMenuButton<SortOrder>(
      icon: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          _options.sortOrder == SortOrder.dateDescending ? Icons.arrow_downward : Icons.arrow_upward,
          size: 20,
          color: Colors.grey[700],
        ),
      ),
      onSelected: (value) {
        setState(() {
          _options = _options.copyWith(sortOrder: value);
        });
        widget.onFilterChanged(_options);
      },
      itemBuilder: (context) => <PopupMenuEntry<SortOrder>>[
        PopupMenuItem(
          value: SortOrder.dateDescending,
          child: Text('Terbaru', style: GoogleFonts.inter()),
        ),
        PopupMenuItem(
          value: SortOrder.dateAscending,
          child: Text('Terlama', style: GoogleFonts.inter()),
        ),
      ],
    );
  }

  void _showTimeFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Filter Waktu', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildTimeFilterOption('Hari Ini', TimeFilter.today),
            _buildTimeFilterOption('Minggu Ini', TimeFilter.thisWeek),
            _buildTimeFilterOption('Bulan Ini', TimeFilter.thisMonth),
            _buildTimeFilterOption('Pilih Tanggal', TimeFilter.customRange),
            _buildTimeFilterOption('Pilih Bulan/Tahun', TimeFilter.customMonthYear),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeFilterOption(String label, TimeFilter filter) {
    return ListTile(
      title: Text(label, style: GoogleFonts.inter()),
      onTap: () async {
        Navigator.pop(context);

        if (filter == TimeFilter.customRange) {
          await _showDateRangePicker();
        } else if (filter == TimeFilter.customMonthYear) {
          await _showMonthYearPicker();
        } else {
          setState(() {
            _options = _options.copyWith(timeFilter: filter);
          });
          widget.onFilterChanged(_options);
        }
      },
    );
  }

  Future<void> _showDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: AppColor.primary)),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _options = _options.copyWith(
          timeFilter: TimeFilter.customRange,
          startDate: picked.start,
          endDate: picked.end,
        );
      });
      widget.onFilterChanged(_options);
    }
  }

  Future<void> _showMonthYearPicker() async {
    final now = DateTime.now();
    int? selectedMonth;
    int? selectedYear = now.year;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Pilih Bulan & Tahun', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Year Picker
              DropdownButtonFormField<int>(
                value: selectedYear,
                decoration: InputDecoration(
                  labelText: 'Tahun',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                items: List.generate(5, (index) => now.year - index)
                    .map((year) => DropdownMenuItem(value: year, child: Text('$year', style: GoogleFonts.inter())))
                    .toList(growable: true),
                onChanged: (value) {
                  setDialogState(() => selectedYear = value);
                },
              ),
              SizedBox(height: 16.h),
              // Month Picker
              DropdownButtonFormField<int>(
                value: selectedMonth,
                decoration: InputDecoration(
                  labelText: 'Bulan',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                items: List.generate(12, (index) => index + 1)
                    .map((month) => DropdownMenuItem(
                          value: month,
                          child: Text(_getMonthName(month), style: GoogleFonts.inter()),
                        ))
                    .toList(growable: true),
                onChanged: (value) {
                  setDialogState(() => selectedMonth = value);
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: GoogleFonts.inter()),
            ),
            ElevatedButton(
              onPressed: selectedMonth != null && selectedYear != null
                  ? () {
                      Navigator.pop(context);
                      setState(() {
                        _options = _options.copyWith(
                          timeFilter: TimeFilter.customMonthYear,
                          month: selectedMonth,
                          year: selectedYear,
                        );
                      });
                      widget.onFilterChanged(_options);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
              ),
              child: Text('Terapkan', style: GoogleFonts.inter(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return months[month - 1];
  }
}