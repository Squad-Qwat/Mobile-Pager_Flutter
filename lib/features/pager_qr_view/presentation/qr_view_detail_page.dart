import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pager_flutter/core/theme/app_color.dart';
import 'package:mobile_pager_flutter/core/theme/app_padding.dart';
import 'package:mobile_pager_flutter/features/pager/domain/models/pager_model.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:path_provider/path_provider.dart'; 
import 'package:share_plus/share_plus.dart'; 
import 'package:mobile_pager_flutter/core/service/queue_state_service.dart';

class QrDetailPage extends ConsumerStatefulWidget {
  final PagerModel pager;

  const QrDetailPage({super.key, required this.pager});

  @override
  ConsumerState<QrDetailPage> createState() => _QrDetailPageState();
}

class _QrDetailPageState extends ConsumerState<QrDetailPage> {

  @protected
  late QrImage qrImage;
  final _queueService = QueueStateService();

  late bool _isQueueActive; 
  late bool _isFullScreen;

  @override
  void initState() 
  {
    super.initState();

    // Use widget.pager.customerId instead of hardcoded string
    final qrCode = QrCode.fromData(
      data: widget.pager.customerId ?? '', 
      errorCorrectLevel: QrErrorCorrectLevel.H
    );

    qrImage = QrImage(qrCode);
    _isQueueActive = _queueService.isQueueActive.value;
    _isFullScreen = _queueService.isFullScreen.value;
  }

  void poppingButtons() {if (Navigator.canPop(context)) {Navigator.pop(context);}}

  void verifyQueueActivation(bool newValue) 
  {
    setState(() => _isQueueActive = newValue);
    _queueService.setQueueActive(newValue);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(newValue ? "Antrian Aktif" : "Antrian Kosong"),
      duration: const Duration(milliseconds: 500),
    ));
  }
  void verifyFullScreenActivation(bool newValue) {
    setState(() => _isFullScreen = newValue);
    _queueService.setFullScreen(newValue);
    
    // Logic to hide status bar and navigation bar (Immersive Mode)
    if (newValue) {SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);} // Hides both bars, swipes bring them back temporarily 
    // Restore standard UI (Show status bar and navigation bar)
    else {SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);}

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(newValue ? 'Mode Layar Penuh Aktif' : 'Mode Layar Penuh Mati'),
        duration: const Duration(milliseconds: 500),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  // Belum ada implementasi yang bagus
  void printQR() => stdout.write("QR has been printed");

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

  void callShareQR() async => await shareQR();
  void callDownloadQR() async => await downloadQR();

  String _formatDateTime(DateTime dateTime) => DateFormat('dd MMM yyyy, HH:mm').format(dateTime);

  String _getStatusText(PagerStatus status) 
  {
    switch (status) 
    {
      case PagerStatus.temporary:
        return 'Belum Diaktifkan';
      case PagerStatus.waiting:
        return 'Menunggu';
      case PagerStatus.ready:
        return 'Siap';
      case PagerStatus.ringing:
        return 'Sedang Dipanggil';
      case PagerStatus.finished:
        return 'Selesai';
      case PagerStatus.expired:
        return 'Kadaluarsa';
    }
  }

  Color _getStatusColor(PagerStatus status) 
  {
    switch (status) 
    {
      case PagerStatus.temporary:
        return Colors.grey;
      case PagerStatus.waiting:
        return AppColor.warning;
      case PagerStatus.ready:
        return AppColor.success;
      case PagerStatus.ringing:
        return AppColor.accent;
      case PagerStatus.finished:
        return AppColor.primary;
      case PagerStatus.expired:
        return AppColor.error;
    }
  }



  @override
  Widget build(BuildContext context) 
  {
    final pager = widget.pager;
    
    final qrData = jsonEncode({
      'pagerId': pager.pagerId,
      'merchantId': pager.merchantId,
      'number': pager.number,
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detail QR',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppColor.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Iconsax.arrow_left_copy,
            color: AppColor.textPrimary,
          ),
          onPressed: poppingButtons,
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      backgroundColor: AppColor.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppPadding.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Pager ID Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColor.primary, AppColor.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    pager.displayId,
                    style: GoogleFonts.poppins(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: _getStatusColor(pager.status).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _getStatusText(pager.status),
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // QR Code Section
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: <Widget>[
                  Text(
                    'Scan untuk Aktivasi',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColor.textPrimary,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColor.grey200, width: 2),
                    ),
                    child: SizedBox(
                      width: 200.w,
                      height: 200.w,
                      child: PrettyQrView.data(
                        data: qrData,
                        decoration: const PrettyQrDecoration(
                          quietZone: PrettyQrQuietZone.standart,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    pager.label ?? 'Pager #${pager.number}',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: AppColor.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            Container(
              padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4)
                  )
                ]
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _buildActionButton(
                    ic: Iconsax.printer, 
                    label: "Print QR", 
                    onTap: printQR
                  ),
                  _buildVerticalDivider(),
                  _buildActionButton(
                    ic: Iconsax.share, 
                    label: "Share QR", 
                    onTap: callShareQR
                  ),
                  _buildVerticalDivider(),
                  _buildActionButton(
                    ic: Iconsax.document_download, 
                    label: "Save QR", 
                    onTap: callDownloadQR
                  )
                ],
              ),
            ),
            SizedBox(height: 20.h),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4)
                  )
                ]
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SwitchListTile(
                    title: Text(
                      "Activate Queue",
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColor.textPrimary
                      ),
                    ),
                    secondary: Icon(
                      Iconsax.task_square,
                      color: AppColor.primary,
                    ),
                    value: _isQueueActive, 
                    onChanged: (val) => verifyQueueActivation(val),
                    activeThumbColor: AppColor.primary
                  ),
                  Divider(
                    height: 1, 
                    color: AppColor.grey200
                  ),
                  SwitchListTile(
                    title: Text(
                      "Full Screen Mode",
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColor.primary
                      ),
                    ),
                    secondary: Icon(
                      Iconsax.maximize_circle,
                      color: AppColor.primary
                    ),
                    value: _isFullScreen, 
                    onChanged: (val) => verifyFullScreenActivation(val),
                    activeThumbColor: AppColor.primary,
                  )
                ],
              ),
            ),
            SizedBox(height: 20.h),
            // Info Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informasi Pager',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColor.textPrimary,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  
                  // Label/Name
                  _buildInfoRow(
                    icon: Iconsax.tag_copy,
                    title: 'Label',
                    value: pager.label ?? '-',
                  ),
                  Divider(height: 24.h, color: AppColor.grey200),
                  
                  // Pager Number
                  _buildInfoRow(
                    icon: Iconsax.hashtag,
                    title: 'Nomor Pager',
                    value: '#${pager.number}',
                  ),
                  Divider(height: 24.h, color: AppColor.grey200),
                  
                  // Created At
                  _buildInfoRow(
                    icon: Iconsax.calendar_add,
                    title: 'Dibuat pada',
                    value: _formatDateTime(pager.createdAt),
                  ),
                  
                  // Activated At (if available)
                  if (pager.activatedAt != null) ...[
                    Divider(height: 24.h, color: AppColor.grey200),
                    _buildInfoRow(
                      icon: Iconsax.tick_circle,
                      title: 'Diaktifkan pada',
                      value: _formatDateTime(pager.activatedAt!),
                      valueColor: AppColor.success,
                    ),
                  ],
                  
                  // Expires At (if available)
                  if (pager.expiresAt != null) ...[
                    Divider(height: 24.h, color: AppColor.grey200),
                    _buildInfoRow(
                      icon: Iconsax.timer_1,
                      title: 'Kadaluarsa pada',
                      value: _formatDateTime(pager.expiresAt!),
                      valueColor: AppColor.warning,
                    ),
                  ],
                  
                  // Notes (if available)
                  if (pager.notes != null && pager.notes!.isNotEmpty) ...[
                    Divider(height: 24.h, color: AppColor.grey200),
                    _buildInfoRow(
                      icon: Iconsax.note,
                      title: 'Catatan',
                      value: pager.notes!,
                    ),
                  ],
                  
                  // Ringing Count (if > 0)
                  if (pager.ringingCount > 0) ...[
                    Divider(height: 24.h, color: AppColor.grey200),
                    _buildInfoRow(
                      icon: Iconsax.notification,
                      title: 'Jumlah Panggilan',
                      value: '${pager.ringingCount}x',
                      valueColor: AppColor.accent,
                    ),
                  ],
                  
                  // Scanned By (if available)
                  if (pager.scannedBy != null) ...[
                    Divider(height: 24.h, color: AppColor.grey200),
                    _buildInfoRow(
                      icon: Iconsax.user,
                      title: 'Discan oleh',
                      value: pager.scannedBy!['name'] ?? pager.scannedBy!['email'] ?? 'Customer',
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // Invoice Image Preview (if available)
            if (pager.invoiceImageUrl != null) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(Iconsax.receipt_item, size: 20, color: AppColor.grey700),
                        SizedBox(width: 8.w),
                        Text(
                          'Struk/Invoice',
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColor.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        pager.invoiceImageUrl!,
                        width: double.infinity,
                        height: 150.h,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) 
                        {
                          if (loadingProgress == null) {return child;}
                          return Container(
                            height: 150.h,
                            color: AppColor.grey100,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) 
                        {
                          return Container(
                            height: 150.h,
                            color: AppColor.grey100,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(Iconsax.image, size: 40, color: AppColor.grey400),
                                  SizedBox(height: 8.h),
                                  Text(
                                    'Gagal memuat gambar',
                                    style: GoogleFonts.inter(
                                      fontSize: 12.sp,
                                      color: AppColor.grey500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
            ],

            SizedBox(height: 24.h),
          ],
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
      children: <Widget>[
        Icon(icon, size: 20, color: AppColor.grey600),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: AppColor.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
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

  Widget _buildActionButton({
    required IconData ic, 
    required String label, 
    required VoidCallback onTap
  })
  {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsetsGeometry.symmetric(vertical: 8.h, horizontal: 16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              ic, 
              color: AppColor.primary, 
              size: 24
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColor.primary
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalDivider() => Container(
    height: 20.h,
    width: 1,
    color: AppColor.background,
  );
}