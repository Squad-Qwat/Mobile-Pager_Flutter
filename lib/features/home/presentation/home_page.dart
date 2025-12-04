import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mobile_pager_flutter/core/constants/app_routes.dart';
import 'package:mobile_pager_flutter/core/theme/app_color.dart';
import 'package:mobile_pager_flutter/core/theme/app_padding.dart';
import 'package:mobile_pager_flutter/features/authentication/presentation/providers/auth_providers.dart';
import 'package:mobile_pager_flutter/features/pager/domain/models/pager_model.dart';
import 'package:mobile_pager_flutter/features/pager/presentation/providers/pager_providers.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildHeader(context, ref),
        body: const Center(child: Text('Please login')),
      );
    }

    final activePagersAsync = user.isMerchant
        ? ref.watch(activePagersStreamProvider(user.uid))
        : ref.watch(customerPagersStreamProvider(user.uid));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildHeader(context, ref),
      body: SafeArea(
        child: activePagersAsync.when(
          data: (pagers) => _buildContent(context, ref, user, pagers),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error loading pagers',
                  style: GoogleFonts.inter(fontSize: 16, color: Colors.red),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, user, List pagers) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppPadding.p16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome,',
                  style: GoogleFonts.inter(
                    fontSize: 36.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  user.displayName ?? 'User',
                  style: GoogleFonts.inter(
                    fontSize: 36.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          SizedBox(
            height: 170.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(left: AppPadding.p16),
              children: [
                Container(
                  width: 330.w,
                  margin: EdgeInsets.only(right: AppPadding.p16),
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          'Antrian aktif hari ini',
                          textAlign: TextAlign.start,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          '${pagers.length}',
                          textAlign: TextAlign.end,
                          style: GoogleFonts.inter(
                            fontSize: 52.sp,
                            color: AppColor.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          'Antrian',
                          textAlign: TextAlign.end,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 330.w,
                  margin: EdgeInsets.only(right: AppPadding.p16),
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          'Antrian aktif hari ini',
                          textAlign: TextAlign.start,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          '${pagers.length}',
                          textAlign: TextAlign.end,
                          style: GoogleFonts.inter(
                            fontSize: 52.sp,
                            color: AppColor.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          'Antrian',
                          textAlign: TextAlign.end,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 36),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppPadding.p16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Aktivitas Terkini',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // TODO: Navigate to full list
                      },
                      child: Text(
                        'Lihat Semua',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          color: AppColor.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          pagers.isEmpty
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppPadding.p16),
                  child: Center(
                    child: Text(
                      'No active pagers yet',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: AppPadding.p16),
                  itemCount: pagers.length,
                  itemBuilder: (context, index) {
                    final pager = pagers[index];
                    final timeFormat = DateFormat('HH:mm, dd MMM yyyy');
                    final activatedTime = pager.activatedAt != null
                        ? timeFormat.format(pager.activatedAt!)
                        : 'N/A';

                    return Container(
                      margin: EdgeInsets.only(bottom: 12),
                      padding: EdgeInsets.symmetric(vertical: AppPadding.p12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppPadding.p12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  pager.displayId,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  activatedTime,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Queue Number',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '#${pager.queueNumber ?? '-'}',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Status',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(pager.status),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        _getStatusText(pager.status),
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (pager.label != null) ...[
                              SizedBox(height: 12),
                              Divider(color: Colors.grey.shade300, height: 1),
                              SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    Iconsax.location,
                                    size: 18,
                                    color: AppColor.primary,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    pager.label!,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
          SizedBox(height: 20),
        ],
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

  PreferredSizeWidget _buildHeader(BuildContext context, WidgetRef ref) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      actionsPadding: EdgeInsets.symmetric(horizontal: 16),
      title: Text(
        'Cammo',
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w800,
          color: AppColor.primary,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => print('Hello World'),
          icon: Icon(Icons.add),
        ),
        IconButton(
          onPressed: () => print('Hello World'),
          icon: Icon(Icons.notifications),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.profile);
          },
          child: CircleAvatar(
            radius: 14.w,
            backgroundColor: AppColor.primary,
            child: Text(
              'FC',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
