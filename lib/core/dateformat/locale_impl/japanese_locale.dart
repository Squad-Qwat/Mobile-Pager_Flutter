import 'package:mobile_pager_flutter/core/dateformat/locale_abst/common_locale.dart';

class JapaneseDateLocale implements DateLocale 
{
  const JapaneseDateLocale();

  @override
  final List<String> monthsShort = const [
    '1月',
    '2月',
    '3月',
    '4月',
    '5月',
    '6月',
    '7月',
    '8月',
    '9月',
    '10月',
    '11月',
    '12月'
  ];

  @override
  final List<String> monthsLong = const [
    '一月',
    '二月',
    '三月',
    '四月',
    '五月',
    '六月',
    '七月',
    '八月',
    '九月',
    '十月',
    '十一月',
    '十二月'
  ];

 @override
  final List<String> daysShort = const [
    '月週',
    '火週',
    '水週',
    '木週',
    '金週',
    '土週',
    '日週'
  ];

  @override
  final List<String> daysLong = const [
    '月曜日',
    '火曜日',
    '水曜日',
    '木曜日',
    '金曜日',
    '土曜日',
    '日曜日'
  ];

  @override
  String get am => "午前";

  @override
  String get pm => "午後";
}