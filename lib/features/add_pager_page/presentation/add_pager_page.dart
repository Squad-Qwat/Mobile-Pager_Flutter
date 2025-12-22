import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pager_flutter/core/presentation/widget/buttons/primary_button.dart';
import 'package:mobile_pager_flutter/core/presentation/widget/inputfields/text_inputfiled.dart';
import 'package:mobile_pager_flutter/core/services/r2_service.dart';
import 'package:mobile_pager_flutter/core/theme/app_color.dart';
import 'package:mobile_pager_flutter/core/theme/app_padding.dart';
import 'package:mobile_pager_flutter/features/authentication/presentation/providers/auth_providers.dart';
import 'package:mobile_pager_flutter/features/pager/presentation/notifiers/pager_notifier.dart';
import 'package:mobile_pager_flutter/features/pager/presentation/providers/pager_providers.dart';

class AddPagerPage extends ConsumerStatefulWidget {
  const AddPagerPage({super.key});

  @override
  ConsumerState<AddPagerPage> createState() => _AddPagerPageState();
}

class _AddPagerPageState extends ConsumerState<AddPagerPage> {
  final TextEditingController _labelController = TextEditingController();
  XFile? _capturedImage;

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  void _openCameraBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CameraBottomSheet(
        onImageCaptured: (XFile image) {
          setState(() {
            _capturedImage = image;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _retakePhoto() {
    _openCameraBottomSheet();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(authNotifierProvider);
    final pagerState = ref.watch(pagerNotifierProvider);

    ref.listen<PagerState>(pagerNotifierProvider, (previous, next) {
      if (next.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: Colors.green,
          ),
        );
        ref.read(pagerNotifierProvider.notifier).clearMessages();
        Navigator.pop(context);
      }

      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
        ref.read(pagerNotifierProvider.notifier).clearMessages();
      }
    });

    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Add Pager',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: AppColor.textPrimary,
          ),
        ),
        backgroundColor: AppColor.white,
        elevation: 0,
      ),
      bottomSheet: Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppPadding.p16),
        decoration: BoxDecoration(
          color: AppColor.white,
          border: Border(top: BorderSide(color: AppColor.grey300, width: 1)),
        ),
        child: PrimaryButton(
          text: pagerState.isLoading ? "Creating..." : "Create Pager",
          onPressed: pagerState.isLoading ? null : _handleCreatePager,
        ),
      ),
      body: Container(
        height: 460,
        margin: EdgeInsets.symmetric(vertical: AppPadding.p24),
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppPadding.p16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextInputField(
                controller: _labelController,
                hint: 'Enter seat number (Optional)',
                label: 'Seat Number',
              ),
              SizedBox(height: AppPadding.p24),
              Text(
                'Snap receipt photo',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColor.textPrimary,
                ),
              ),
              // Image placeholder - tap to open camera bottom sheet
              GestureDetector(
                onTap: _openCameraBottomSheet,
                child: Container(
                  margin: EdgeInsets.only(top: AppPadding.p12),
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColor.grey200,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColor.grey300, width: 1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _capturedImage == null
                        ? _buildPlaceholder()
                        : _buildCapturedImage(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt,
            color: AppColor.grey600,
            size: 40,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap untuk ambil foto',
            style: GoogleFonts.inter(
              color: AppColor.grey600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapturedImage() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.file(
          File(_capturedImage!.path),
          fit: BoxFit.cover,
        ),
        Positioned(
          bottom: 8,
          right: 8,
          child: GestureDetector(
            onTap: _retakePhoto,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.refresh, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Ambil Ulang',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleCreatePager() async {
    final authState = ref.read(authNotifierProvider);
    final user = authState.user;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not authenticated'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final label = _labelController.text.trim();
    String? imageUrl;

    // Upload image to R2 if captured
    if (_capturedImage != null) {
      try {
        final File imageFile = File(_capturedImage!.path);
        final bytes = await imageFile.readAsBytes();
        
        final r2Service = R2Service();
        imageUrl = await r2Service.uploadImage(bytes);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal upload gambar: $e'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // Create pager with image URL
    await ref.read(pagerNotifierProvider.notifier).createPagerWithImage(
      merchantId: user.uid,
      label: label.isEmpty ? null : label,
      invoiceImageUrl: imageUrl,
    );
  }
}

/// Camera bottom sheet widget - portrait mode camera
class _CameraBottomSheet extends StatefulWidget {
  final Function(XFile) onImageCaptured;

  const _CameraBottomSheet({required this.onImageCaptured});

  @override
  State<_CameraBottomSheet> createState() => _CameraBottomSheetState();
}

class _CameraBottomSheetState extends State<_CameraBottomSheet> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isCapturing = false;
  String? _cameraError;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _cameraController = CameraController(
          cameras.first,
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      setState(() {
        _cameraError = 'Gagal menginisialisasi kamera';
      });
    }
  }

  Future<void> _captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    setState(() {
      _isCapturing = true;
    });

    try {
      final XFile image = await _cameraController!.takePicture();
      widget.onImageCaptured(image);
    } catch (e) {
      setState(() {
        _cameraError = 'Gagal mengambil foto';
        _isCapturing = false;
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColor.grey300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ambil Foto Receipt',
                  style: GoogleFonts.inter(
                    color: AppColor.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: AppColor.textPrimary),
                ),
              ],
            ),
          ),
          // Camera preview
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColor.grey200,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildCameraPreview(),
              ),
            ),
          ),
          // Capture button
          Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: GestureDetector(
              onTap: _isCapturing || !_isCameraInitialized ? null : _captureImage,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColor.primary, width: 4),
                ),
                child: Center(
                  child: _isCapturing
                      ? CircularProgressIndicator(color: AppColor.primary)
                      : Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColor.primary,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (_cameraError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.grey, size: 48),
            const SizedBox(height: 8),
            Text(
              _cameraError!,
              style: GoogleFonts.inter(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _initializeCamera,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (!_isCameraInitialized) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Memuat kamera...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    // Portrait camera preview without distortion
    return AspectRatio(
      aspectRatio: 1 / _cameraController!.value.aspectRatio,
      child: CameraPreview(_cameraController!),
    );
  }
}
