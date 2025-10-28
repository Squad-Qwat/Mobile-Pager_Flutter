export 'package:mobile_pager_flutter/core/dateformat/locale_impl/arabic_locale.dart';
export 'package:mobile_pager_flutter/core/dateformat/locale_impl/english_locale.dart';
export 'package:mobile_pager_flutter/core/dateformat/locale_impl/french_locale.dart';
export 'package:mobile_pager_flutter/core/dateformat/locale_impl/german_locale.dart';
export 'package:mobile_pager_flutter/core/dateformat/locale_impl/indonesian_locale.dart';
export 'package:mobile_pager_flutter/core/dateformat/locale_impl/italian_local.dart';
export 'package:mobile_pager_flutter/core/dateformat/locale_impl/japanese_locale.dart';
export 'package:mobile_pager_flutter/core/dateformat/locale_impl/khmer_locale.dart';
export 'package:mobile_pager_flutter/core/dateformat/locale_impl/korean_locale.dart';
export 'package:mobile_pager_flutter/core/dateformat/locale_impl/lao_locale.dart';
export 'package:mobile_pager_flutter/core/dateformat/locale_impl/portuguese_locale.dart';
export 'package:mobile_pager_flutter/core/dateformat/locale_impl/russian_locale.dart';
export 'package:mobile_pager_flutter/core/dateformat/locale_impl/simp_chinese_locale.dart';
export 'package:mobile_pager_flutter/core/dateformat/locale_impl/spanish_locale.dart';
export 'package:mobile_pager_flutter/core/dateformat/locale_impl/thai_locale.dart';
export 'package:mobile_pager_flutter/core/dateformat/locale_impl/trad_chinese_locale.dart';
export 'package:mobile_pager_flutter/core/dateformat/locale_impl/turkish_locale.dart';
export 'package:mobile_pager_flutter/core/dateformat/locale_impl/vietnamese_locale.dart';

abstract class DateLocale 
{
  List<String> get monthsShort;

  List<String> get monthsLong;

  List<String> get daysShort;

  List<String> get daysLong;

  String get am;

  String get pm;
}