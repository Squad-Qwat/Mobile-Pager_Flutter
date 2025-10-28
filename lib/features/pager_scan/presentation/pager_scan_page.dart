import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pager_flutter/core/providers/navigation_provider.dart';
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

class _PagerScanPageState extends ConsumerState<PagerScanPage> with AutomaticKeepAliveClientMixin {
  late MobileScannerController cameraController;
  bool isScanning = true;
  String? scannedData;
  bool isFlashOn = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() 
  {
    super.initState();
    cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
  }

  @override
  void dispose() 
  {
    cameraController.dispose();
    super.dispose();
  }

  /// Reset scanner when page becomes visible again
  void _ensureScannerReady() 
  {
    if (!isScanning) 
    {
      stdout.write('🔄 [SCANNER] Resetting scanner for new scan');
      setState(() 
      {
        isScanning = true;
        scannedData = null;
      });
      cameraController.start();
    }
  }

  void _onDetect(BarcodeCapture capture) 
  {
    if (!isScanning) {return;}

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) 
    {
      final barcode = barcodes.first;
      if (barcode.rawValue != null) 
      {
        setState(() 
        {
          isScanning = false;
          scannedData = barcode.rawValue;
        });
        cameraController.stop();
        _showScanResult(barcode.rawValue!);
      }
    }
  }

  void _showScanResult(String data) async 
  {
    try 
    {
      final qrData = jsonDecode(data);
      final pagerId = qrData['pagerId'] as String?;
      final merchantId = qrData['merchantId'] as String?;

      if (pagerId == null || merchantId == null) 
      {
        _showErrorDialog(
          'Invalid QR Code',
          'QR code does not contain valid pager data',
        );
        _resetScanner();
        return;
      }

      final authState = ref.read(authNotifierProvider);
      final user = authState.user;

      if (user == null) 
      {
        _showErrorDialog('Not Authenticated', 'Please login to scan pagers');
        _resetScanner();
        return;
      }

      // Prepare customer info
      final customerInfo = <String, String?>
      {
        'name': user.displayName ?? 'Guest',
        if (user.email != null) 'email': user.email,
        if (user.isGuest == true) 'guestId': user.guestId,
      };

      final customerType = user.isGuest == true ? 'guest' : 'registered';

      stdout.write('🔍 Starting pager activation...');
      stdout.write('   PagerId: $pagerId');
      stdout.write('   CustomerId: ${user.uid}');
      stdout.write('   CustomerType: $customerType');

      // Activate pager immediately without confirmation
      await ref
          .read(pagerNotifierProvider.notifier)
          .activatePager(
            pagerId: pagerId,
            customerId: user.uid,
            customerType: customerType,
            customerInfo: customerInfo,
          );

      stdout.write('✅ Pager activation completed successfully');

      if (!mounted) {return;}

      // Navigate to Home page (index 0) to show success
      // Don't use Navigator.pop() because scanner is in bottom nav
      ref.read(navigationIndexProvider.notifier).state = 0;

      // Show success snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pager berhasil diaktifkan! Lihat di Home.',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } 
    catch (e, stackTrace) 
    {
      stderr.write('❌ ERROR activating pager: $e');
      stderr.write('📍 Stack trace: $stackTrace');

      _showErrorDialog(
        'Scan Error',
        'Gagal mengaktifkan pager: ${e.toString()}',
      );
      _resetScanner();
    }
  }

  void _resetScanner() 
  {
    setState(() 
    {
      isScanning = true;
      scannedData = null;
    });
    cameraController.start();
  }

  void _showErrorDialog(String title, String message) 
  {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: Text(message, style: GoogleFonts.inter()),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: GoogleFonts.inter()),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) 
  {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    // Reset scanner when page is rebuilt (user returns to this tab)
    _ensureScannerReady();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildHeader(),
      body: SafeArea(
        child: Column(
          children: <Widget>[
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
                      children: <Widget>[
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

  PreferredSizeWidget _buildHeader() 
  {
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