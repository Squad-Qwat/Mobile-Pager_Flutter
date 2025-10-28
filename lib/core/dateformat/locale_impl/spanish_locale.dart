import 'package:mobile_pager_flutter/core/dateformat/locale_abst/common_locale.dart';

class SpanishDateLocale implements DateLocale 
{
  const SpanishDateLocale();

  @override
  final List<String> monthsShort = const [
    'Ene',
    'Feb',
    'Mar',
    'Abr',
    'May',
    'Jun',
    'Jul',
    'Ago',
    'Sep',
    'Oct',
    'Nov',
    'Dic'
  ];

  @override
  final List<String> monthsLong = const [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre'
  ];

  @override
  final List<String> daysShort = const [
    'Lun',
    'Mar',
    'Mié',
    'Jue',
    'Vie',
    'Sáb',
    'Dom'
  ];

  @override
  final List<String> daysLong = const [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo'
  ];

  @override
  String get am => "AM";

  @override
  String get pm => "PM";
}