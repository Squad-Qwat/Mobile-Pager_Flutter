import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pager_flutter/core/theme/app_color.dart';
import 'package:mobile_pager_flutter/core/theme/app_padding.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class PagerScanPage extends StatefulWidget {
  const PagerScanPage({super.key});

  @override
  State<PagerScanPage> createState() => _PagerScanPageState();
}

class _PagerScanPageState extends State<PagerScanPage> {
  late MobileScannerController cameraController;
  bool isScanning = true;
  String? scannedData;
  bool isFlashOn = false;

  @override
  void initState() {
    super.initState();
    cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (!isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final barcode = barcodes.first;
      if (barcode.rawValue != null) {
        setState(() {
          isScanning = false;
          scannedData = barcode.rawValue;
        });
        cameraController.stop();
        _showScanResult(barcode.rawValue!);
      }
    }
  }

  void _showScanResult(String data) {
    print('Scanned QR Code Data: $data');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildHeader(),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20),
            Padding(padding: EdgeInsets.symmetric(horizontal: AppPadding.p16)),
            SizedBox(height: 24),

            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppPadding.p16),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.grey.shade100,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        MobileScanner(
                          controller: cameraController,
                          onDetect: _onDetect,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: AppPadding.p24),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildHeader() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      title: Text(
        'Scan QR Antrian',
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w800,
          color: AppColor.black,
        ),
      ),
    );
  }
}
