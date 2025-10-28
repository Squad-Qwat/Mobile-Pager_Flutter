import 'package:mobile_pager_flutter/core/dateformat/locale_abst/common_locale.dart';

class ItalianDateLocale implements DateLocale 
{
  const ItalianDateLocale();

  @override
  final List<String> monthsShort = const [
    'Gen',
    'Feb',
    'Mar',
    'Apr',
    'Mag',
    'Giu',
    'Lug',
    'Ago',
    'Set',
    'Ott',
    'Nov',
    'Dic'
  ];

  @override
  final List<String> monthsLong = const [
    'Gennaio',
    'Febbraio',
    'Marzo',
    'Aprile',
    'Maggio',
    'Giugno',
    'Luglio',
    'Agosto',
    'Settembre',
    'Ottobre',
    'Novembre',
    'Dicembre'
  ];

  @override
  final List<String> daysShort = const [
    'Lun',
    'Mar',
    'Mer',
    'Gio',
    'Ven',
    'Sab',
    'Dom'
  ];

  @override
  final List<String> daysLong = const [
    'Lunedì',
    'Martedì',
    'Mercoledì',
    'Giovedì',
    'Venerdì',
    'Sabato',
    'Domenica'
  ];

  @override
  String get am => "AM";

  @override
  String get pm => "PM";
}