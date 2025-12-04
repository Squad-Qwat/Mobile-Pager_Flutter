import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pager_flutter/core/theme/app_color.dart';
import 'package:mobile_pager_flutter/core/theme/app_padding.dart';
import 'package:mobile_pager_flutter/features/authentication/presentation/providers/auth_providers.dart';
import 'package:mobile_pager_flutter/features/pager/presentation/providers/pager_providers.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class PagerScanPage extends ConsumerStatefulWidget {
  const PagerScanPage({super.key});

  @override
  ConsumerState<PagerScanPage> createState() => _PagerScanPageState();
}

class _PagerScanPageState extends ConsumerState<PagerScanPage> {
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

  void _showScanResult(String data) async {
    try {
      final qrData = jsonDecode(data);
      final pagerId = qrData['pagerId'] as String?;
      final merchantId = qrData['merchantId'] as String?;

      if (pagerId == null || merchantId == null) {
        _showErrorDialog(
          'Invalid QR Code',
          'QR code does not contain valid pager data',
        );
        _resetScanner();
        return;
      }

      final authState = ref.read(authNotifierProvider);
      final user = authState.user;

      if (user == null) {
        _showErrorDialog('Not Authenticated', 'Please login to scan pagers');
        _resetScanner();
        return;
      }

      // Prepare customer info
      final customerInfo = {
        'name': user.displayName ?? 'Guest',
        if (user.email != null) 'email': user.email,
        if (user.isGuest == true) 'guestId': user.guestId,
      };

      final customerType = user.isGuest == true ? 'guest' : 'registered';

      // Show confirmation dialog
      final confirmed = await _showConfirmationDialog(
        'Activate Pager',
        'Do you want to activate this pager?',
      );

      if (!confirmed) {
        _resetScanner();
        return;
      }

      // Activate pager
      await ref
          .read(pagerNotifierProvider.notifier)
          .activatePager(
            pagerId: pagerId,
            customerId: user.uid,
            customerType: customerType,
            customerInfo: customerInfo,
          );

      if (!mounted) return;

      _showSuccessDialog(
        'Pager Activated',
        'Your pager has been activated successfully!',
      );
    } catch (e) {
      _showErrorDialog(
        'Scan Error',
        'Failed to process QR code: ${e.toString()}',
      );
      _resetScanner();
    }
  }

  void _resetScanner() {
    setState(() {
      isScanning = true;
      scannedData = null;
    });
    cameraController.start();
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: Text(message, style: GoogleFonts.inter()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: GoogleFonts.inter()),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        content: Text(message, style: GoogleFonts.inter()),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetScanner();
            },
            child: Text('OK', style: GoogleFonts.inter()),
          ),
        ],
      ),
    );
  }

  Future<bool> _showConfirmationDialog(String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: Text(message, style: GoogleFonts.inter()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.inter()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Activate', style: GoogleFonts.inter()),
          ),
        ],
      ),
    );

    return result ?? false;
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
