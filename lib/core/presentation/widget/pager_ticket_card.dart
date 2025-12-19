import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pager_flutter/core/theme/app_color.dart';
import 'package:mobile_pager_flutter/features/merchant/presentation/providers/merchant_settings_providers.dart';
import 'package:mobile_pager_flutter/features/pager/domain/models/pager_model.dart';
import 'package:mobile_pager_flutter/features/pager/presentation/providers/pager_providers.dart';

class PagerTicketCard extends ConsumerStatefulWidget {
  final PagerModel pager;
  final bool isMerchant;
  final VoidCallback? onTap;

  const PagerTicketCard({
    Key? key,
    required this.pager,
    required this.isMerchant,
    this.onTap,
  }) : super(key: key);

  @override
  ConsumerState<PagerTicketCard> createState() => _PagerTicketCardState();
}

class _PagerTicketCardState extends ConsumerState<PagerTicketCard>
    with TickerProviderStateMixin {
  // Store BuildContext reference for safe access in async methods
  BuildContext? _savedContext;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Save context reference during dependencies phase (safe time)
    _savedContext = context;
  }

  @override
  void dispose() {
    // Clear context reference to avoid using deactivated widget
    _savedContext = null;
    super.dispose();
  }

  Future<void> _updateStatus(BuildContext buttonContext, PagerStatus newStatus) async {
    try {
      // Close the slidable using the button context (which is still valid)
      Slidable.of(buttonContext)?.close();

      final notifier = ref.read(pagerNotifierProvider.notifier);

      await notifier.updatePagerStatus(
        pagerId: widget.pager.pagerId,
        status: newStatus,
      );

      // Use saved context only if widget is still mounted
      if (mounted && _savedContext != null) {
        ScaffoldMessenger.of(_savedContext!).showSnackBar(
          SnackBar(
            content: Text(
              'Status berhasil diubah ke ${_getStatusText(newStatus)}',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // Show error feedback using saved context
      if (mounted && _savedContext != null) {
        ScaffoldMessenger.of(_savedContext!).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal mengubah status: ${e.toString()}',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildMerchantInfo() {
    // Fetch merchant settings to get merchantName
    final merchantSettingsAsync = ref.watch(
      merchantSettingsFutureProvider(widget.pager.merchantId),
    );

    return merchantSettingsAsync.when(
      data: (merchantSettings) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: AppColor.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Iconsax.shop,
                size: 14,
                color: AppColor.primary,
              ),
              SizedBox(width: 6.w),
              Flexible(
                child: Text(
                  merchantSettings.merchantName,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: AppColor.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(width: 6.w),
            Text(
              'Loading...',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      error: (error, stack) => Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Iconsax.shop,
              size: 14,
              color: Colors.grey.shade600,
            ),
            SizedBox(width: 6.w),
            Text(
              'Unknown Merchant',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActionButtons(BuildContext context) {
    final List<SlidableAction> actions = [];

    switch (widget.pager.status) {
      case PagerStatus.waiting:
        actions.addAll([
          SlidableAction(
            onPressed: (ctx) => _updateStatus(ctx, PagerStatus.expired),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.cancel,
            label: 'Expire',
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            spacing: 4,
          ),
          SlidableAction(
            onPressed: (ctx) => _updateStatus(ctx, PagerStatus.ringing),
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
            icon: Icons.notifications_active,
            label: 'Ring',
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            spacing: 4,
          ),
          SlidableAction(
            onPressed: (ctx) => _updateStatus(ctx, PagerStatus.ready),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            icon: Icons.check_circle,
            label: 'Ready',
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            spacing: 4,
          ),
        ]);
        break;

      case PagerStatus.ready:
        actions.addAll([
          SlidableAction(
            onPressed: (ctx) => _updateStatus(ctx, PagerStatus.expired),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.cancel,
            label: 'Expire',
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            spacing: 4,
          ),
          SlidableAction(
            onPressed: (ctx) => _updateStatus(ctx, PagerStatus.ringing),
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
            icon: Icons.notifications_active,
            label: 'Ring',
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            spacing: 4,
          ),
          SlidableAction(
            onPressed: (ctx) => _updateStatus(ctx, PagerStatus.finished),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            icon: Icons.check_circle,
            label: 'Finish',
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            spacing: 4,
          ),
        ]);
        break;

      case PagerStatus.ringing:
        actions.addAll([
          SlidableAction(
            onPressed: (ctx) => _updateStatus(ctx, PagerStatus.expired),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.cancel,
            label: 'Expire',
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            spacing: 4,
          ),
          SlidableAction(
            onPressed: (ctx) => _updateStatus(ctx, PagerStatus.ready),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            icon: Icons.check_circle,
            label: 'Ready',
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            spacing: 4,
          ),
          SlidableAction(
            onPressed: (ctx) => _updateStatus(ctx, PagerStatus.finished),
            backgroundColor: Colors.green.shade700,
            foregroundColor: Colors.white,
            icon: Icons.check_circle_outline,
            label: 'Finish',
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            spacing: 4,
          ),
        ]);
        break;

      default:
        break;
    }

    return actions;
  }

  Widget _buildCardContent(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    final activatedTime = widget.pager.activatedAt != null
        ? timeFormat.format(widget.pager.activatedAt!)
        : 'N/A';

    return Container(
      padding: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        onTap: widget.onTap,
        child: Column(
          children: [
            // Top Section - Info
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row: Display ID & Time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.pager.displayId,
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(widget.pager.status),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _getStatusText(widget.pager.status),
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Merchant Info Section (only for customers)
                  if (!widget.isMerchant) ...[
                    SizedBox(height: 8.h),
                    _buildMerchantInfo(),
                  ],

                  SizedBox(height: 12.h),

                  // Details Row: Queue Number & Label
                  Row(
                    children: [
                      // Queue Number
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Queue',
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              '#${widget.pager.queueNumber ?? widget.pager.number}',
                              style: GoogleFonts.inter(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Label if exists
                      if (widget.pager.label != null)
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Iconsax.location,
                                size: 16,
                                color: AppColor.primary,
                              ),
                              SizedBox(width: 4.w),
                              Expanded(
                                child: Text(
                                  widget.pager.label!,
                                  style: GoogleFonts.inter(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Time
                      Text(
                        activatedTime,
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  // Invoice Image Section (only for customer if available)
                  if (!widget.isMerchant && widget.pager.invoiceImageUrl != null) ...[
                    SizedBox(height: 12.h),
                    GestureDetector(
                      onTap: () => _showInvoiceImageDialog(context),
                      child: Container(
                        height: 120.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.shade100,
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                widget.pager.invoiceImageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.broken_image_outlined,
                                          color: Colors.grey.shade400,
                                          size: 32,
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          'Gagal memuat invoice',
                                          style: GoogleFonts.inter(
                                            fontSize: 10.sp,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  );
                                },
                              ),
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.zoom_in,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        'Lihat Invoice',
                                        style: GoogleFonts.inter(
                                          fontSize: 10.sp,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Perforated Divider
            CustomPaint(
              size: Size(double.infinity, 1),
              painter: DashedLinePainter(),
            ),

            // Bottom Section - Action Indicator & Notes (only for merchant)
            if (widget.isMerchant)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Notes Button
                    GestureDetector(
                      onTap: () => _showNotesBottomSheet(context),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.note_alt_outlined,
                              size: 14,
                              color: Colors.orange.shade700,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'Catatan',
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    // Action Button
                    Builder(
                      builder: (builderContext) {
                        final slidable = Slidable.of(builderContext);

                        return ValueListenableBuilder<ActionPaneType>(
                          valueListenable: slidable?.actionPaneType ?? ValueNotifier(ActionPaneType.none),
                          builder: (context, actionPaneType, child) {
                            final isOpen = actionPaneType != ActionPaneType.none;

                            return GestureDetector(
                              onTap: () {
                                if (isOpen) {
                                  slidable?.close();
                                } else {
                                  slidable?.openEndActionPane();
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColor.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Aksi',
                                      style: GoogleFonts.inter(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppColor.primary,
                                      ),
                                    ),
                                    SizedBox(width: 4.w),
                                    Icon(
                                      isOpen ? Icons.arrow_forward : Icons.arrow_back,
                                      size: 14,
                                      color: AppColor.primary,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              )
            else
              SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If not merchant, return static card
    if (!widget.isMerchant) {
      return _buildCardContent(context);
    }

    // If merchant, wrap with Slidable
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Slidable(
          key: ValueKey(widget.pager.pagerId),
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            extentRatio: 0.65,
            children: _buildActionButtons(context),
            openThreshold: 0.2,
            closeThreshold: 0.5,
          ),
          child: _buildCardContent(context),
        ),
      ),
    );
  }

  Color _getStatusColor(PagerStatus status) {
    switch (status) {
      case PagerStatus.waiting:
        return Colors.orange;
      case PagerStatus.ready:
        return Colors.green;
      case PagerStatus.ringing:
        return Colors.purple;
      case PagerStatus.finished:
        return Colors.grey;
      case PagerStatus.expired:
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  String _getStatusText(PagerStatus status) {
    switch (status) {
      case PagerStatus.waiting:
        return 'WAITING';
      case PagerStatus.ready:
        return 'READY';
      case PagerStatus.ringing:
        return 'RINGING';
      case PagerStatus.finished:
        return 'FINISHED';
      case PagerStatus.expired:
        return 'EXPIRED';
      case PagerStatus.temporary:
        return 'TEMPORARY';
    }
  }

  void _showInvoiceImageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(16.w),
        child: Stack(
          children: [
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.pager.invoiceImageUrl!,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 300.h,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image_outlined,
                              color: Colors.grey.shade400,
                              size: 64,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'Gagal memuat invoice',
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 300.h,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showNotesBottomSheet(BuildContext context) async {
    final TextEditingController notesController = TextEditingController(
      text: widget.pager.notes ?? '',
    );

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Catatan untuk ${widget.pager.displayId}',
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: notesController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Tulis catatan di sini...',
                hintStyle: GoogleFonts.inter(
                  color: Colors.grey.shade400,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColor.primary, width: 2),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    final repository = ref.read(pagerRepositoryProvider);
                    await repository.updatePagerNotes(
                      pagerId: widget.pager.pagerId,
                      notes: notesController.text,
                    );

                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Catatan berhasil disimpan',
                            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                          ),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Gagal menyimpan catatan: ${e.toString()}',
                            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                          ),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Simpan',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}

// Custom painter for dashed line (perforated edge)
class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    const dashWidth = 5.0;
    const dashSpace = 3.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
