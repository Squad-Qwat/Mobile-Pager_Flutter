import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pager_flutter/core/constants/app_routes.dart';
import 'package:mobile_pager_flutter/core/presentation/widget/pager_ticket_card.dart';
import 'package:mobile_pager_flutter/core/providers/navigation_provider.dart';
import 'package:mobile_pager_flutter/core/theme/app_color.dart';
import 'package:mobile_pager_flutter/core/theme/app_padding.dart';
import 'package:mobile_pager_flutter/features/analytics/presentation/widgets/analytics_grid.dart';
import 'package:mobile_pager_flutter/features/authentication/presentation/providers/auth_providers.dart';
import 'package:mobile_pager_flutter/features/notifications/presentation/providers/notification_providers.dart';
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
    return RefreshIndicator(
      onRefresh: () async {
        // Trigger refresh by invalidating the provider
        ref.invalidate(user.isMerchant
            ? activePagersStreamProvider(user.uid)
            : customerPagersStreamProvider(user.uid));
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          SizedBox(height: 24.h),
          // Analytics Grid (only for merchants)
          if (user.isMerchant)
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppPadding.p16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.analytics_outlined,
                        size: 20.sp,
                        color: AppColor.primary,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Statistik',
                        style: GoogleFonts.inter(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                AnalyticsGrid(merchantId: user.uid),
                SizedBox(height: 24.h),
              ],
            ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppPadding.p16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.local_activity,
                          size: 20.sp,
                          color: AppColor.primary,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Aktivitas Terkini',
                          style: GoogleFonts.inter(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Only show "Lihat Semua" for merchants
                  if (user.isMerchant)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppPadding.p16),
                      child: GestureDetector(
                        onTap: () {
                          // Switch ke tab Active Pagers (index 1) di bottom navigation
                          ref.read(navigationIndexProvider.notifier).state = 1;
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
                    ),
                ],
              ),
            ],
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
                    return PagerTicketCard(
                      pager: pagers[index],
                      isMerchant: user.isMerchant,
                    );
                  },
                ),
          SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildHeader(BuildContext context, WidgetRef ref) {
    // make initial for user name (contains 2)
    final user = ref.watch(authNotifierProvider.select((state) => state.user));
    String initial = '';
    if (user != null && user.displayName != null) {
      List<String> nameParts = user.displayName!.split(' ');
      if (nameParts.length >= 2) {
        initial = nameParts[0][0].toUpperCase() + nameParts[1][0].toUpperCase();
      } else if (nameParts.isNotEmpty) {
        initial = nameParts[0][0].toUpperCase();
      }
    }

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
        // Notification icon with badge
        _buildNotificationBadge(ref, user),
        SizedBox(width: 8.w),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.profile);
          },
          child: CircleAvatar(
            radius: 14.w,
            backgroundColor: AppColor.primary,
            child: Text(
              initial,
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

  Widget _buildNotificationBadge(WidgetRef ref, user) {
    if (user == null) {
      return IconButton(
        onPressed: () {},
        icon: Icon(Icons.notifications),
      );
    }

    final unreadCountAsync = ref.watch(unreadNotificationCountProvider(user.uid));

    return unreadCountAsync.when(
      data: (count) => Stack(
        children: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(ref.context, AppRoutes.notifications);
            },
            icon: Icon(Icons.notifications),
          ),
          if (count > 0)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  count > 99 ? '99+' : count.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      loading: () => IconButton(
        onPressed: () {},
        icon: Icon(Icons.notifications),
      ),
      error: (_, __) => IconButton(
        onPressed: () {
          Navigator.pushNamed(ref.context, AppRoutes.notifications);
        },
        icon: Icon(Icons.notifications),
      ),
    );
  }
}
