import 'package:mobile_pager_flutter/core/dateformat/locale_abst/common_locale.dart';

class GermanDateLocale implements DateLocale 
{
  const GermanDateLocale();

  @override
  final List<String> monthsShort = const [
    'Jan.',
    'Feb.',
    'März',
    'Apr.',
    'Mai',
    'Jun.',
    'Jul.',
    'Aug.',
    'Sep.',
    'Okt.',
    'Nov.',
    'Dez.'
  ];

  @override
  final List<String> monthsLong = const [
    'Januar',
    'Februar',
    'März',
    'April',
    'Mai',
    'Juni',
    'Juli',
    'August',
    'September',
    'Oktober',
    'November',
    'Dezember'
  ];

  @override
  final List<String> daysShort = const [
    'Mo',
    'Di',
    'Mi',
    'Do',
    'Fr',
    'Sa',
    'So'
  ];

  @override
  final List<String> daysLong = const [
    'Montag',
    'Dienstag',
    'Mittwoch',
    'Donnerstag',
    'Freitag',
    'Samstag',
    'Sonntag'
  ];

  @override
  String get am => "vormittags";

  @override
  String get pm => "nachmittags";
}