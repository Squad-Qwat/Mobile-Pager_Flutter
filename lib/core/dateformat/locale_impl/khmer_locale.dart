import 'package:mobile_pager_flutter/core/dateformat/locale_abst/common_locale.dart';

class KhmerDateLocale implements DateLocale 
{
  const KhmerDateLocale();

  @override
  final List<String> monthsShort = const [
    'មករា',
    'កុម្ភៈ',
    'មីនា',
    'មេសា',
    'ឧសភា',
    'មិថុនា',
    'កក្កដា',
    'សីហា',
    'កញ្ញា',
    'តុលា',
    'វិច្ឆិកា',
    'ធ្នូ'
  ];

  @override
  final List<String> monthsLong = const [
    'មករា',
    'កុម្ភៈ',
    'មីនា',
    'មេសា',
    'ឧសភា',
    'មិថុនា',
    'កក្កដា',
    'សីហា',
    'កញ្ញា',
    'តុលា',
    'វិច្ឆិកា',
    'ធ្នូ'
  ];

  @override
  final List<String> daysShort = const [
    'ច',
    'អ',
    'ព',
    'ព្រ',
    'សុ',
    'ស',
    'អា'
  ];

  @override
  final List<String> daysLong = const [
    'ច័ន្ទ',
    'អង្គារ',
    'ពុធ',
    'ព្រហស្បតិ៍',
    'សុក្រ',
    'សៅរ៍',
    'អាទិត្យ'
  ];

  @override
  String get am => "ព្រឹក";

  @override
  String get pm => "ល្ងាច";
}