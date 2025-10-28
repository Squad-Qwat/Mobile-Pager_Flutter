import 'package:mobile_pager_flutter/core/dateformat/locale_abst/common_locale.dart';

class ThaiDateLocale implements DateLocale 
{
  const ThaiDateLocale();

  @override
  final List<String> monthsShort = const [
    'มกร', // Má-gon
    'กุมภ์', // Kump̣h̒
    'มีน', // Mīn
    'เมษ', // Mâs̄ʹ
    'พฤษภ', // Phréut-s̄'òp̣h
    'มิถุน', // Mí-t̄hŭn
    'กรกฎ', // Kor-rá-kòḍ
    'สิงห์', // S̄ĭngh̄̒
    'กันย์', // Kạny̒
    'ตุล', // Dtùl
    'พฤศจิก', // Phréut-ṣ̄à-cìk
    'ธนู' // Ṭhá-nū
  ];

  @override
  final List<String> monthsLong = const [
    'มกราคม', // Mók-kà-rā khom
    'กุมภาพันธ์', // Kum-p̣hāphạnṭh̒
    'มีนาคม', // Mī-nā khom
    'เมษายน', // mĕy-s̄'ā-yon
    'พฤษภาคม', // Phréut-s̄à-p̣hā khom
    'มิถุนายน', // Mí-t̄hù-nā-yon
    'กรกฎาคม', // Kà-rá-kà-ḍā-khom
    'สิงหาคม', // S̄ĭng h̄ăa khom
    'กันยายน', // Kạn-yā-yon
    'ตุลาคม', // Dtù-lā khom
    'พฤศจิกายน', // Phréut-ṣ̄à-cì-kā-yon
    'ธันวาคม' // Ṭhạn-wā khom
  ];

  @override
  final List<String> daysShort = const [
    'จันทร์', // Cạnthr̒
    'อังคาร', // Xạngkhār
    'พุธ', // Phúṭh
    'พฤหัสบดี', // Phá-réu-h̄àt-s̄à-bor-dī
    'ศุกร์', // Ṣ̄ùkr̒
    'เสาร์', // S̄eār̒
    'อาทิตย์' // Xāthity̒
  ];

  @override
  final List<String> daysLong = const [
    'วันจันทร์', // wan cạnthr̒
    'วันอังคาร', // wan xạngkhār
    'วันพุธ', // wan phúṭh
    'วันพฤหัสบดี', // wan phá-réu-h̄àt-s̄à-bor-dī
    'วันศุกร์', // wan ṣ̄ùkr̒
    'วันเสาร์', // wan s̄ĕār̒
    'วันอาทิตย์' // wan xāthity̒
  ];

  @override
  String get am => "ก่อนเที่ยง"; // K̀on thîī̀yang

  @override
  String get pm => "ในช่วงบ่าย"; // Nı ch̀wng b̀āy
}