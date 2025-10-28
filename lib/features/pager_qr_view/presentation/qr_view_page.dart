import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pager_flutter/core/presentation/widget/buttons/primary_button.dart';
import 'package:mobile_pager_flutter/core/theme/app_color.dart';
import 'package:mobile_pager_flutter/core/theme/app_padding.dart';

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
      body: Padding(
        padding: const EdgeInsets.all(AppPadding.p16),
        child: Column(
          children: [
            Text(
              'QR Pager',
              style: GoogleFonts.dmSans(
                fontSize: 18,
                color: AppColor.textPrimary,
              ),
            ),
            PrimaryButton(text: "Buat QR Pager", onPressed: () {
              
            }),
          ],
        ),
      ),
    );
  }
}
