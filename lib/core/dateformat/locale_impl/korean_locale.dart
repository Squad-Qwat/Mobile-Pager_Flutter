import 'package:mobile_pager_flutter/core/dateformat/locale_abst/common_locale.dart';

class KoreanDateLocale implements DateLocale 
{
  const KoreanDateLocale();

  @override
  final List<String> monthsShort = const [
    '1월',
    '2월',
    '3월',
    '4월',
    '5월',
    '6월',
    '7월',
    '8월',
    '9월',
    '10월',
    '11월',
    '12월'
  ];

  @override
  final List<String> monthsLong = const [
    '1월',
    '2월',
    '3월',
    '4월',
    '5월',
    '6월',
    '7월',
    '8월',
    '9월',
    '10월',
    '11월',
    '12월'
  ];

  @override
  final List<String> daysShort = const ['월', '화', '수', '목', '금', '토', '일'];

  @override
  final List<String> daysLong = const [
    '월요일',
    '화요일',
    '수요일',
    '목요일',
    '금요일',
    '토요일',
    '일요일'
  ];

  @override
  String get am => "오전";

  @override
  String get pm => "오후";
}