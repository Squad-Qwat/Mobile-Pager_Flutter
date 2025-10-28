import 'package:mobile_pager_flutter/core/dateformat/locale_abst/common_locale.dart';

class PortugueseDateLocale implements DateLocale 
{
  const PortugueseDateLocale();

  @override
  final List<String> monthsShort = const [
    'Jan',
    'Fev',
    'Mar',
    'Abr',
    'Mai',
    'Jun',
    'Jul',
    'Ago',
    'Set',
    'Out',
    'Nov',
    'Dez'
  ];

  @override
  final List<String> monthsLong = const [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro'
  ];

  @override
  final List<String> daysShort = const [
    'Seg',
    'Ter',
    'Qua',
    'Qui',
    'Sex',
    'Sáb',
    'Dom'
  ];

  @override
  final List<String> daysLong = const [
    'Segunda-feira',
    'Terça-feira',
    'Quarta-feira',
    'Quinta-feira',
    'Sexta-feira',
    'Sábado',
    'Domingo'
  ];

  @override
  String get am => "AM";

  @override
  String get pm => "PM";
}