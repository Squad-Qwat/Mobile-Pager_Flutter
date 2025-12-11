import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pager_flutter/core/theme/app_color.dart';
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
  Future<void> _updateStatus(BuildContext context, PagerStatus newStatus) async {
    try {
      // Close the slidable first
      Slidable.of(context)?.close();

      final notifier = ref.read(pagerNotifierProvider.notifier);

      await notifier.updatePagerStatus(
        pagerId: widget.pager.pagerId,
        status: newStatus,
      );

      // Show success feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
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
      // Show error feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
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
                ],
              ),
            ),

            // Perforated Divider
            CustomPaint(
              size: Size(double.infinity, 1),
              painter: DashedLinePainter(),
            ),

            // Bottom Section - Action Indicator (only for merchant)
            if (widget.isMerchant)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
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
