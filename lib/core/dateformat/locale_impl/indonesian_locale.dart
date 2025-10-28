import 'package:mobile_pager_flutter/core/dateformat/locale_abst/common_locale.dart';

class IndonesianDateLocale implements DateLocale 
{
  const IndonesianDateLocale();

  @override
  final List<String> monthsShort = const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des'
  ];

  @override
  final List<String> monthsLong = const [
    'Januari',
    'Febuari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember'
  ];

  @override
  final List<String> daysShort = const [
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
    'Min'
  ];

  @override
  final List<String> daysLong = const [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu'
  ];

  @override
  String get am => "AM";

  @override
  String get pm => "PM";
}