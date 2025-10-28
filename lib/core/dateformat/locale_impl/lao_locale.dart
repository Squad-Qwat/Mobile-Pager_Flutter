import 'package:mobile_pager_flutter/core/dateformat/locale_abst/common_locale.dart';

class LaoDateLocale implements DateLocale 
{
  const LaoDateLocale();

  @override
  final List<String> monthsShort = const [
    'ມັງ',
    'ກຸມ',
    'ມີນາ',
    'ເມສາ',
    'ພຶດ',
    'ມີຖ',
    'ກໍລ',
    'ສິງ',
    'ກັນ',
    'ຕຸລາ',
    'ພະຈິກ',
    'ທັນ'
  ];

  @override
  final List<String> monthsLong = const [
    'ມັງກອນ',
    'ກຸມພາ',
    'ມີນາ',
    'ເມສາ',
    'ພຶດສະພາ',
    'ມີຖຸນາ',
    'ກໍລະກົດ',
    'ສິງຫາ',
    'ກັນຍາ',
    'ຕຸລາ',
    'ພະຈິກ',
    'ທັນວາ'
  ];

  @override
  final List<String> daysShort = const [
    'ຈັນ',
    'ຄານ',
    'ພຸດ',
    'ພະຫັດ',
    'ສຸກ',
    'ເສົາ',
    'ທິດ'
  ];

  @override
  final List<String> daysLong = const [
    'ວັນຈັນ',
    'ວັນອັງຄານ',
    'ວັນພຸດ',
    'ວັນພະຫັດ',
    'ວັນສຸກ',
    'ວັນເສົາ',
    'ວັນອາທິດ'
  ];

  @override
  String get am => "ກ່ອນສວາຍ";

  @override
  String get pm => "ໃນຕອນບ່າຍ";
}