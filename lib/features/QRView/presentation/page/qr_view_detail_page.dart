import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:mobile_pager_flutter/core/presentation/widget/buttons/primary_button.dart';
import 'package:mobile_pager_flutter/core/theme/app_color.dart';
import 'package:mobile_pager_flutter/core/theme/app_padding.dart';

class QrDetailPage extends StatefulWidget 
{
  const QrDetailPage({super.key});

  @override
  State<QrDetailPage> createState() => _QrDetailPageState();
}

class _QrDetailPageState extends State<QrDetailPage> 
{
  bool _isQueueActive = true;
  bool _isFullScreen = false;

  void poppingButtons(){if (Navigator.canPop(context)) {Navigator.pop(context);}}

  // Karena belum integrasi ke fungsi lain, sementara ini dulu
  void verifyQueueActivation(bool newValue){setState(() {_isQueueActive = newValue;});}
  void verifyFullScreenActivation(bool newValue){setState(() {_isFullScreen = newValue;});}

  // Belum ada implementasi yang bagus
  void printQR(){stdout.write("QR has been printed");}
  void shareQR(){stdout.write("QR has been shared");}
  void downloadQR(){stdout.write("QR has been downloaded");}


  @override
  Widget build(BuildContext context) 
  {
    // Contoh Data QR View
    const String restaurantName = "Restoran Seafood Enak";
    const int currentQueue = 12;
    const int estimatedWaitTime = 28;
    const String qrLabel = "Counter 1 (Dine-in)";
    const String qrCategory = "Regular Queue (antrian biasa)";

    // Placeholder untuk gambar QR (Pakai link untuk sementara)
    const String qrImageUrl ="https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=YourQueueDataHere";

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detail Antrian',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: AppColor.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_copy,
              color: AppColor.textPrimary),
          onPressed: poppingButtons
        ),
        centerTitle: true,
        elevation: 1,
        backgroundColor: AppColor.surface,
      ),
      backgroundColor: AppColor.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppPadding.p24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                restaurantName,
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColor.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppPadding.p12),

              Text(
                "Scan untuk Join Antrian",
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColor.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppPadding.p24),

              Container(
                padding: const EdgeInsets.all(AppPadding.p12),
                decoration: BoxDecoration(
                  color: AppColor.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColor.border, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.shadow,
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Image.network(
                  qrImageUrl,
                  width: 250,
                  height: 250,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) 
                  {
                    if (loadingProgress == null){return child;}
                    return SizedBox(
                      width: 250,
                      height: 250,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          color: AppColor.primary,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) 
                  {
                    return Container(
                      width: 250,
                      height: 250,
                      color: AppColor.grey100,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Iconsax.danger_copy,
                              color: AppColor.error, size: 60),
                          const SizedBox(height: AppPadding.p8),
                          Text(
                            "Gagal memuat QR",
                            style: GoogleFonts.inter(
                                color: AppColor.textSecondary),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppPadding.p32),

              Card(
                elevation: 2,
                shadowColor: AppColor.shadow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: AppColor.surface,
                child: Padding(
                  padding: const EdgeInsets.all(AppPadding.p24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        icon: Iconsax.user_tick_copy,
                        title: "Jumlah antrian saat ini:",
                        value: "$currentQueue orang menunggu",
                        valueColor: AppColor.info,
                      ),
                      const Divider(
                          height: AppPadding.p24,
                          thickness: 0.5,
                          color: AppColor.divider),
                      _buildInfoRow(
                        icon: Iconsax.clock_copy,
                        title: "Estimasi waktu tunggu:",
                        value: "$estimatedWaitTime menit",
                        valueColor: AppColor.warning,
                      ),
                      const Divider(
                          height: AppPadding.p24,
                          thickness: 0.5,
                          color: AppColor.divider),
                      _buildInfoRow(
                        icon: Iconsax.tag_copy,
                        title: "Nama QR/Label:",
                        value: qrLabel,
                      ),
                      const Divider(
                          height: AppPadding.p24,
                          thickness: 0.5,
                          color: AppColor.divider),
                      _buildInfoRow(
                        icon: Iconsax.category_copy,
                        title: "Kategori/Tipe:",
                        value: qrCategory,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppPadding.p24),

              Card(
                elevation: 2,
                shadowColor: AppColor.shadow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: AppColor.surface,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    children: [
                      _buildToggleRow(
                        icon: Iconsax.activity_copy,
                        title: "Antrian Aktif",
                        subtitle: "Matikan sementara jika penuh",
                        value: _isQueueActive,
                        onChanged: verifyQueueActivation
                      ),
                      const Divider(
                          height: AppPadding.p16,
                          thickness: 0.5,
                          color: AppColor.divider),
                      _buildToggleRow(
                        icon: Iconsax.maximize_copy,
                        title: "Full Screen Mode",
                        subtitle: "Untuk display di TV/tablet",
                        value: _isFullScreen,
                        onChanged: verifyFullScreenActivation
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppPadding.p32),

              PrimaryButton(
                text: "Download QR",
                icon: Iconsax.document_download_copy,
                backgroundColor: AppColor.primary,
                onPressed: downloadQR,
              ),
              const SizedBox(height: AppPadding.p16),
              PrimaryButton(
                text: "Print QR",
                icon: Iconsax.printer_copy,
                backgroundColor: AppColor.primaryDark,
                onPressed: printQR,
              ),
              const SizedBox(height: AppPadding.p16),
              PrimaryButton(
                text: "Share Link",
                icon: Iconsax.share_copy,
                backgroundColor: AppColor.accent,
                onPressed: shareQR,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) 
  {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColor.grey700),
        const SizedBox(width: AppPadding.p16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColor.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? AppColor.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToggleRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) 
  {
    return Row(
      children: [
        Icon(icon, size: 22, color: AppColor.grey700),
        const SizedBox(width: AppPadding.p16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColor.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColor.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppPadding.p16),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColor.primary,
          inactiveTrackColor: AppColor.grey300,
        ),
      ],
    );
  }
}