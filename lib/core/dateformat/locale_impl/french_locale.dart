import 'package:mobile_pager_flutter/core/dateformat/locale_abst/common_locale.dart';

class FrenchDateLocale implements DateLocale 
{
  const FrenchDateLocale();

  @override
  final List<String> monthsShort = const [
    'Janv.',
    'Févr',
    'Mars',
    'Avr.',
    'Mai',
    'Juin',
    'Juill.',
    'Août',
    'Sep.',
    'Oct.',
    'Nov.',
    'Déc.'
  ];

  @override
  final List<String> monthsLong = const [
    'Janvier',
    'Février',
    'Mars',
    'Avril',
    'Mai',
    'Juin',
    'Juillet',
    'Août',
    'Septembre',
    'Octobre',
    'Novembre',
    'Décembre'
  ];

  @override
  final List<String> daysShort = const [
    'Lu',
    'Ma',
    'Me',
    'Je',
    'Ve',
    'Sa',
    'Di'
  ];

  @override
  final List<String> daysLong = const [
    'Lundi',
    'Mardi',
    'Mercredi',
    'Jeudi',
    'Vendredi',
    'Samedi',
    'Dimanche'
  ];

  @override
  String get am => "avant midi";

  @override
  String get pm => "après midi";
}