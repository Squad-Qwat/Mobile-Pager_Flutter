import 'dart:convert';

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

class _PagerScanPageState extends ConsumerState<PagerScanPage> with WidgetsBindingObserver {
  MobileScannerController? cameraController;
  bool isScanning = true;
  String? scannedData;
  bool isFlashOn = false;
  bool _isPageVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopCamera();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app lifecycle changes
    if (state == AppLifecycleState.resumed && _isPageVisible) {
      _startCamera();
    } else if (state == AppLifecycleState.paused || 
               state == AppLifecycleState.inactive ||
               state == AppLifecycleState.detached) {
      _stopCamera();
    }
  }

  Future<void> _startCamera() async {
    if (cameraController != null) return; // Already started
    
    cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      autoStart: true,
    );
    
    setState(() {
      isScanning = true;
      scannedData = null;
    });
  }

  Future<void> _stopCamera() async {
    if (cameraController == null) return; // Already stopped
    
    await cameraController?.stop();
    await cameraController?.dispose();
    cameraController = null;
  }

  Future<void> _resetScanner() async {
    setState(() {
      isScanning = true;
      scannedData = null;
    });
    
    if (cameraController != null && !cameraController!.value.isRunning) {
      await cameraController?.start();
    }
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
        cameraController?.stop();
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

      await ref
          .read(pagerNotifierProvider.notifier)
          .activatePager(
            pagerId: pagerId,
            customerId: user.uid,
            customerType: customerType,
            customerInfo: customerInfo,
          );

      if (!mounted) return;

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
    } catch (e, stackTrace) {
      _showErrorDialog(
        'Scan Error',
        'Gagal mengaktifkan pager: ${e.toString()}',
      );
      _resetScanner();
    }
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

  @override
  Widget build(BuildContext context) {
    // Start camera when page is visible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isPageVisible) {
        _isPageVisible = true;
        _startCamera();
      }
    });

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
                    child: cameraController == null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                const SizedBox(height: 16),
                                Text(
                                  'Memulai kamera...',
                                  style: GoogleFonts.inter(),
                                ),
                              ],
                            ),
                          )
                        : Stack(
                            children: [
                              MobileScanner(
                                controller: cameraController!,
                                onDetect: _onDetect,
                                errorBuilder: (context, error) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      size: 64,
                                      color: Colors.red.shade300,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Gagal mengakses kamera',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      error.errorDetails?.message ?? 'Pastikan izin kamera sudah diberikan',
                                      style: GoogleFonts.inter(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton.icon(
                                      onPressed: () async {
                                        // Restart camera completely
                                        await _stopCamera();
                                        await _startCamera();
                                      },
                                      icon: const Icon(Icons.refresh),
                                      label: const Text('Coba Lagi'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
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
