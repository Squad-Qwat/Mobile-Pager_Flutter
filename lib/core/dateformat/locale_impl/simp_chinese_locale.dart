import 'package:mobile_pager_flutter/core/dateformat/locale_abst/common_locale.dart';

class SimplifiedChineseDateLocale implements DateLocale 
{
  const SimplifiedChineseDateLocale();

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
    '周一',
    '周二',
    '周三',
    '周四',
    '周五',
    '周六',
    '周日'
  ];

  @override
  final List<String> daysLong = const [
    '星期一',
    '星期二',
    '星期三',
    '星期四',
    '星期五',
    '星期六',
    '星期日'
  ];

  @override
  String get am => "上午";

  @override
  String get pm => "下午";
}