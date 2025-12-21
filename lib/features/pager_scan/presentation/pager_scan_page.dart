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

class _PagerScanPageState extends ConsumerState<PagerScanPage>
    with WidgetsBindingObserver {
  MobileScannerController? _controller;
  bool _isScanning = true;
  bool _isCameraReady = false;
  int _cameraKey = 0; // Used to force rebuild MobileScanner widget
  int? _lastNavIndex;

  // Customer navigation: index 1 = Scan page
  static const int _scanPageIndex = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeCamera();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;

    final navIndex = ref.read(navigationIndexProvider);
    final isMerchant = ref.read(authNotifierProvider).isMerchant;

    switch (state) {
      case AppLifecycleState.resumed:
        if (!isMerchant && navIndex == _scanPageIndex) {
          _initializeCamera();
        }
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _disposeCamera();
        break;
    }
  }

  /// Check if camera should be running based on navigation and user type
  void _checkCameraState() {
    final navIndex = ref.read(navigationIndexProvider);
    final isMerchant = ref.read(authNotifierProvider).isMerchant;

    // Camera should be active if: not merchant AND on scan page (index 1)
    final shouldCameraRun = !isMerchant && navIndex == _scanPageIndex;

    if (shouldCameraRun && _controller == null) {
      _initializeCamera();
    } else if (!shouldCameraRun && _controller != null) {
      _disposeCamera();
    }
    
    _lastNavIndex = navIndex;
  }

  Future<void> _initializeCamera() async {
    if (_controller != null) return;

    setState(() {
      _isCameraReady = false;
    });

    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      autoStart: true,
    );

    // Wait a bit for camera to initialize
    await Future.delayed(const Duration(milliseconds: 100));

    if (mounted) {
      setState(() {
        _isCameraReady = true;
        _isScanning = true;
        _cameraKey++; // Force rebuild with new key
      });
    }
  }

  Future<void> _disposeCamera() async {
    final controller = _controller;
    _controller = null;

    if (mounted) {
      setState(() {
        _isCameraReady = false;
      });
    }

    try {
      await controller?.stop();
      await controller?.dispose();
    } catch (e) {
      // Ignore dispose errors
    }
  }

  Future<void> _restartCamera() async {
    await _disposeCamera();
    await _initializeCamera();
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final barcode = barcodes.first;
      if (barcode.rawValue != null) {
        setState(() {
          _isScanning = false;
        });
        _controller?.stop();
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

      final customerInfo = {
        'name': user.displayName ?? 'Guest',
        if (user.email != null) 'email': user.email,
        if (user.isGuest == true) 'guestId': user.guestId,
      };

      final customerType = user.isGuest == true ? 'guest' : 'registered';

      await ref.read(pagerNotifierProvider.notifier).activatePager(
            pagerId: pagerId,
            customerId: user.uid,
            customerType: customerType,
            customerInfo: customerInfo,
          );

      if (!mounted) return;

      ref.read(navigationIndexProvider.notifier).state = 0;

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
    } catch (e) {
      _showErrorDialog(
        'Scan Error',
        'Gagal mengaktifkan pager: ${e.toString()}',
      );
      _resetScanner();
    }
  }

  void _resetScanner() {
    setState(() {
      _isScanning = true;
    });
    _controller?.start();
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
    // Listen to navigation changes to start/stop camera
    final navIndex = ref.watch(navigationIndexProvider);
    final isMerchant = ref.watch(authNotifierProvider).isMerchant;
    
    // Trigger camera check when navigation changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_lastNavIndex != navIndex) {
        _checkCameraState();
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Text(
          'Scan QR Antrian',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w800,
            color: AppColor.black,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: AppPadding.p16)),
            const SizedBox(height: 24),
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
                    child: _buildCameraView(),
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

  Widget _buildCameraView() {
    if (!_isCameraReady || _controller == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Memulai kamera...',
              style: GoogleFonts.inter(),
            ),
          ],
        ),
      );
    }

    return MobileScanner(
      key: ValueKey(_cameraKey),
      controller: _controller!,
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
                  error.errorDetails?.message ??
                      'Pastikan izin kamera sudah diberikan',
                  style: GoogleFonts.inter(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _restartCamera,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
