import 'package:mobile_pager_flutter/core/dateformat/locale_abst/common_locale.dart';

class TurkishDateLocale implements DateLocale 
{
  const TurkishDateLocale();

  @override
  final List<String> monthsShort = const [
    'Oca',
    'Şub',
    'Mar',
    'Nis',
    'May',
    'Haz',
    'Tem',
    'Ağu',
    'Eyl',
    'Eki',
    'Kas',
    'Ara'
  ];

  @override
  final List<String> monthsLong = const [
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık'
  ];

  @override
  final List<String> daysShort = const [
    'Pzt',
    'Sal',
    'Çar',
    'Per',
    'Cum',
    'Cts',
    'Paz'
  ];

  @override
  final List<String> daysLong = const [
    'Pazartesi',
    'Salı',
    'Çarşamba',
    'Perşembe',
    'Cuma',
    'Cumartesi',
    'Pazar'
  ];

  @override
  String get am => "ÖÖ";

  @override
  String get pm => "ÖS";
}