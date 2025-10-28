import 'package:mobile_pager_flutter/core/dateformat/locale_abst/common_locale.dart';

class EnglishDateLocale implements DateLocale 
{
  const EnglishDateLocale();

  @override
  final List<String> monthsShort = const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  @override
  final List<String> monthsLong = const [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  @override
  final List<String> daysShort = const [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun'
  ];

  @override
  final List<String> daysLong = const [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  @override
  String get am => "AM";

  @override
  String get pm => "PM";
}