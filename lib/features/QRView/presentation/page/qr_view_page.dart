import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pager_flutter/core/constants/app_routes.dart';
import 'package:mobile_pager_flutter/core/presentation/widget/buttons/primary_button.dart';
import 'package:mobile_pager_flutter/core/theme/app_color.dart';
import 'package:mobile_pager_flutter/core/theme/app_padding.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart'; 

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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card to create a new QR Pager
            Card(
              elevation: 2,
              shadowColor: AppColor.shadow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: AppColor.surface,
              child: Padding(
                padding: const EdgeInsets.all(AppPadding.p16),
                child: Column(
                  children: [
                    Text(
                      'Buat QR Pager Baru',
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColor.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppPadding.p16),
                    PrimaryButton(
                      text: "Buat QR Pager",
                      icon: Iconsax.add_square_copy,
                      onPressed: () {
                        Navigator.of(context).pushNamed(AppRoutes.addPager);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppPadding.p24),

            // Card to show a list of active QRs and link to the Detail Page
            Card(
              elevation: 2,
              shadowColor: AppColor.shadow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: AppColor.surface,
              child: Padding(
                padding: const EdgeInsets.all(AppPadding.p16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Daftar QR Aktif',
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColor.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppPadding.p16),
                    // Example item linking to the detail page
                    PrimaryButton(
                      text: "Lihat Contoh QR (Counter 1)",
                      icon: Iconsax.scan_barcode_copy,
                      backgroundColor: AppColor.primaryLight,
                      onPressed: () {
                        // Navigates to the QrDetailPage
                        Navigator.of(context).pushNamed(AppRoutes.qrViewDetail);
                      },
                    ),
                    // In a real app, this would be a ListView.builder
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}