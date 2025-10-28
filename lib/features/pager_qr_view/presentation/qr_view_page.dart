import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pager_flutter/core/theme/app_color.dart';

class QRViewPage extends StatelessWidget {
  const QRViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'QR Pager',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.bold,
            color: AppColor.textPrimary,
          ),
        ),
        backgroundColor: AppColor.white,
        elevation: 0,
      ),
      body: Center(
        child: Text(
          'QR Pager',
          style: GoogleFonts.dmSans(fontSize: 18, color: AppColor.textPrimary),
        ),
      ),
    );
  }
}
