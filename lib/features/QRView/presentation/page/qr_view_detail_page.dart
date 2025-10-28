import 'dart:io';
import 'dart:ui'; // untuk menggunakan ImageByteFormat
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:mobile_pager_flutter/core/presentation/widget/buttons/primary_button.dart';
import 'package:mobile_pager_flutter/core/theme/app_color.dart';
import 'package:mobile_pager_flutter/core/theme/app_padding.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart'; // Merevisi implementasi QR saat ini
import 'package:path_provider/path_provider.dart'; // Merevisi implementasi unduh QR
import 'package:share_plus/share_plus.dart'; // Merevisi implementasi bagi QR
import 'package:mobile_pager_flutter/core/service/queue_state_service.dart';

class QrDetailPage extends StatefulWidget 
{
  const QrDetailPage({super.key});

  @override
  State<QrDetailPage> createState() => _QrDetailPageState();
}

class _QrDetailPageState extends State<QrDetailPage> 
{

  @protected
  late QrImage qrImage;
  final String qrData = "My QR";
  final _queueService = QueueStateService();

  void poppingButtons(){if (Navigator.canPop(context)) {Navigator.pop(context);}}

  void verifyQueueActivation(bool newValue) {_queueService.setQueueActive(newValue);}
  void verifyFullScreenActivation(bool newValue) {_queueService.setFullScreen(newValue);}

  // Belum ada implementasi yang bagus
  void printQR(){stdout.write("QR has been printed");}

  // Membagikan QR
  Future<void> shareQR() async
  {
    stdout.write("Menyiapkan QR untuk dibagikan...");
    try 
    {
      final qrImagesBytes = await qrImage.toImageAsBytes(
        size: 512,
        format: ImageByteFormat.png,
        decoration: const PrettyQrDecoration(
          image: PrettyQrDecorationImage(
            image: NetworkImage('url'),
            scale: 0.25,
            padding: EdgeInsetsGeometry.symmetric(vertical: 2.0, horizontal: 8.0)
          ),
          quietZone: PrettyQrQuietZone.standart,
          background: Colors.white
        ));
      
      if (qrImagesBytes == null) 
      {
        stdout.write("Gagal menghasilkan bytes gambar QR");
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/queue_qr.png';
      // Menulis byte ke file
      await File(path).writeAsBytes(qrImagesBytes.buffer.asUint8List());
      
      // Membagikan file dengan share_plus
      await SharePlus.instance.share(ShareParams(
        files: [XFile(path)],
        text: "Scan this QR to join the queue!",
        subject: "Queue QR Code",
      ));

      /*
      Pengganti fungsi ini, karena menurut flutter, fungsi ini usang:
      await Share.shareXFiles(
        [XFile(path)], 
        text: "Scan this QR to join the queue!", 
        subject: "Queue QR Code"
      );
      */
      stdout.write("Berhasil membagikan QR.");
    } 
    catch (e) {stderr.write("$e");}
  }

  // Mengunduh dan menyimpan file QR
  Future<void> downloadQR() async 
  {
    stdout.write("Menghasilkan byte gambar QR...");
    try 
    {
      final qrImagesBytes = await qrImage.toImageAsBytes(
        size: 512,
        format: ImageByteFormat.png,
        decoration: const PrettyQrDecoration(
          image: PrettyQrDecorationImage(
            image: NetworkImage('url'),
            scale: 0.25,
            padding: EdgeInsetsGeometry.symmetric(vertical: 2.0, horizontal: 8.0)
          ),
          quietZone: PrettyQrQuietZone.standart,
          background: Colors.white
        ));

      if (qrImagesBytes == null) 
      {
        stdout.write("Gagal menghasilkan bytes gambar QR");
        return;
      }
      
      final directory = await getApplicationDocumentsDirectory();

      final fileName = "qr_queue_${DateTime.now().millisecondsSinceEpoch}.png";
      final path = "${directory.path}/$fileName";

      final file = File(path);

      await file.writeAsBytes(qrImagesBytes.buffer.asUint8List());
      stdout.write("Bytes gambar QR berhasil dibuat (${qrImagesBytes.lengthInBytes} bytes).");
    } 
    catch (e) {stderr.write("Terjadi kesalahan saat menghasilkan kode QR: $e");}  
  }

  void callShareQR() async {await shareQR();}
  void callDownloadQR() async {await downloadQR();}

  @override
  void initState() 
  {
    super.initState();

    final qrCode = QrCode.fromData(
      data: qrData, 
      errorCorrectLevel: QrErrorCorrectLevel.H
    );

    qrImage = QrImage(qrCode);
  }


  @override
  Widget build(BuildContext context) 
  {
    // Contoh Data QR View
    const String restaurantName = "Restoran Seafood Enak";
    const int currentQueue = 12;
    const int estimatedWaitTime = 28;
    const String qrLabel = "Counter 1 (Dine-in)";
    const String qrCategory = "Regular Queue (antrian biasa)";

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
            children: <Widget>[
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
                    color: AppColor.border, 
                    width: 1.5
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppColor.shadow,
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: PrettyQrView(
                  qrImage: qrImage,
                  decoration: const PrettyQrDecoration(
                    image: PrettyQrDecorationImage(
                      image: NetworkImage('url'),
                      scale: 0.25,
                      padding: EdgeInsetsGeometry.symmetric(vertical: 2.0, horizontal: 8.0)
                    ),
                    quietZone: PrettyQrQuietZone.standart,
                    background: Colors.white
                  ),
                ),
              ),
              const SizedBox(height: AppPadding.p32),

              Card(
                elevation: 2,
                shadowColor: AppColor.shadow,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: AppColor.surface,
                child: Padding(
                  padding: const EdgeInsets.all(AppPadding.p24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
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
                    children: <Widget>[
                      _buildToggleRow(
                        icon: Iconsax.activity_copy,
                        title: "Antrian Aktif",
                        subtitle: _queueService.isQueueActive.value ? "Antrian sedang berjalan" : "Antrian ditutup sementara",
                        value: _queueService.isQueueActive.value,
                        onChanged: verifyQueueActivation
                      ),
                      const Divider(
                          height: AppPadding.p16,
                          thickness: 0.5,
                          color: AppColor.divider),
                      _buildToggleRow(
                        icon: Iconsax.maximize_copy,
                        title: "Full Screen Mode",
                        subtitle: _queueService.isFullScreen.value ? "Mode tampilan penuh aktif" : "Untuk display di TV/tablet",
                        value: _queueService.isFullScreen.value,
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
                onPressed: callDownloadQR,
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
                onPressed: callShareQR,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String title, required String value, Color? valueColor}) 
  {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(
          icon, 
          size: 20, 
          color: AppColor.grey700
        ),
        const SizedBox(width: AppPadding.p16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
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
      children: <Widget>[
        Icon(icon, size: 22, color: AppColor.grey700),
        const SizedBox(width: AppPadding.p16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
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