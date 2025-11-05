// history_filter_service.dart
import 'package:mobile_pager_flutter/features/order/domain/orders.dart';

/// Enum for time filter
enum TimeFilter {
  today,
  thisWeek,
  thisMonth,
  customRange,
  customMonthYear,
}

/// Enum for sorting
enum SortOrder {
  dateDescending,
  dateAscending,
}

/// Model for filter options
class OrdersHistoryFilterOptions {
  final TimeFilter timeFilter;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? month; // 1-12
  final int? year;
  final String searchQuery;
  final SortOrder sortOrder;
  final List<String> statusFilter; // e.g., ['finished', 'expired', 'cancelled'] or ['all']

  OrdersHistoryFilterOptions({
    this.timeFilter = TimeFilter.today,
    this.startDate,
    this.endDate,
    this.month,
    this.year,
    this.searchQuery = '',
    this.sortOrder = SortOrder.dateDescending,
    this.statusFilter = const ['finished', 'expired', 'cancelled'],
  });

  OrdersHistoryFilterOptions copyWith({
    TimeFilter? timeFilter,
    DateTime? startDate,
    DateTime? endDate,
    int? month,
    int? year,
    String? searchQuery,
    SortOrder? sortOrder,
    List<String>? statusFilter,
  }) 
  {
    return OrdersHistoryFilterOptions(
      timeFilter: timeFilter ?? this.timeFilter,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      month: month ?? this.month,
      year: year ?? this.year,
      searchQuery: searchQuery ?? this.searchQuery,
      sortOrder: sortOrder ?? this.sortOrder,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }
}

/// Service for filtering and sorting history
class OrdersHistoryFilterService 
{
  /// Filter history based on options
  static List<OrdersHistory> filterHistory(List<OrdersHistory> historyList, OrdersHistoryFilterOptions options) {
    List<OrdersHistory> filtered = historyList;

    // 1. Filter by status
    filtered = _filterByStatus(filtered, options.statusFilter);

    // 2. Filter by time
    filtered = _filterByTime(filtered, options);

    // 3. Filter by search query
    if (options.searchQuery.isNotEmpty) {
      filtered = _filterBySearch(filtered, options.searchQuery);
    }

    // 4. Sort
    filtered = _sortHistory(filtered, options.sortOrder);

    return filtered;
  }

  /// Filter by status
  static List<OrdersHistory> _filterByStatus(List<OrdersHistory> historyList, List<String> statusFilter) {
    if (statusFilter.contains('all')) {
      return historyList;
    }

    return historyList.where((h) => statusFilter.contains(h.status)).toList(growable: true);
  }

  /// Filter by time
  static List<OrdersHistory> _filterByTime(List<OrdersHistory> historyList, OrdersHistoryFilterOptions options) {
    final now = DateTime.now();

    switch (options.timeFilter) {
      case TimeFilter.today:
        final startOfDay = DateTime(now.year, now.month, now.day);
        final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
        return historyList
            .where((h) => h.createdAt.isAfter(startOfDay) && h.createdAt.isBefore(endOfDay))
            .toList(growable: true);

      case TimeFilter.thisWeek:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final startOfWeekDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
        return historyList.where((h) => h.createdAt.isAfter(startOfWeekDay)).toList(growable: true);

      case TimeFilter.thisMonth:
        final startOfMonth = DateTime(now.year, now.month, 1);
        return historyList.where((h) => h.createdAt.isAfter(startOfMonth)).toList(growable: true);

      case TimeFilter.customRange:
        if (options.startDate != null && options.endDate != null) {
          final start = DateTime(
            options.startDate!.year,
            options.startDate!.month,
            options.startDate!.day,
          );
          final end = DateTime(
            options.endDate!.year,
            options.endDate!.month,
            options.endDate!.day,
            23,
            59,
            59,
          );
          return historyList
              .where((h) => h.createdAt.isAfter(start) && h.createdAt.isBefore(end))
              .toList(growable: true);
        }
        return historyList;

      case TimeFilter.customMonthYear:
        if (options.month != null && options.year != null) {
          return historyList
              .where((h) => h.createdAt.month == options.month && h.createdAt.year == options.year)
              .toList(growable: true);
        }
        return historyList;
    }
  }

  /// Filter by search query
  static List<OrdersHistory> _filterBySearch(List<OrdersHistory> historyList, String query) {
    final lowerQuery = query.toLowerCase();

    return historyList.where((h) {
      final matchesOrderId = h.orderId.toLowerCase().contains(lowerQuery);
      final matchesQueueNumber = h.queueNumber.toLowerCase().contains(lowerQuery);
      final matchesBusinessName = h.businessName?.toLowerCase().contains(lowerQuery) ?? false;
      // Assumes History has getStatusText() method
      final matchesStatus = h.getStatusText().toLowerCase().contains(lowerQuery);

      return matchesOrderId || matchesQueueNumber || matchesBusinessName || matchesStatus;
    }).toList(growable: true);
  }

  /// Sort history
  static List<OrdersHistory> _sortHistory(List<OrdersHistory> historyList, SortOrder sortOrder) {
    final sorted = List<OrdersHistory>.from(historyList);

    sorted.sort((a, b) {
      if (sortOrder == SortOrder.dateDescending) {
        return b.createdAt.compareTo(a.createdAt);
      } else {
        return a.createdAt.compareTo(b.createdAt);
      }
    });

    return sorted;
  }

  /// Get date range label for display
  static String getTimeFilterLabel(OrdersHistoryFilterOptions options) {
    switch (options.timeFilter) {
      case TimeFilter.today:
        return 'Hari Ini';
      case TimeFilter.thisWeek:
        return 'Minggu Ini';
      case TimeFilter.thisMonth:
        return 'Bulan Ini';
      case TimeFilter.customRange:
        if (options.startDate != null && options.endDate != null) {
          return '${_formatDate(options.startDate!)} - ${_formatDate(options.endDate!)}';
        }
        return 'Pilih Tanggal';
      case TimeFilter.customMonthYear:
        if (options.month != null && options.year != null) {
          return '${_getMonthName(options.month!)} ${options.year}';
        }
        return 'Pilih Bulan';
    }
  }

  /// Format date for display
  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Get month name
  static String _getMonthName(int month) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return months[month - 1];
  }
}