import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pager_flutter/core/constants/app_routes.dart';
import 'package:mobile_pager_flutter/core/presentation/widget/pager_ticket_card.dart';
import 'package:mobile_pager_flutter/core/theme/app_color.dart';
import 'package:mobile_pager_flutter/core/theme/app_padding.dart';
import 'package:mobile_pager_flutter/features/authentication/presentation/providers/auth_providers.dart';
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
                        Navigator.pushNamed(context, AppRoutes.activePagers);
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
                    return PagerTicketCard(
                      pager: pagers[index],
                      isMerchant: user.isMerchant,
                    );
                  },
                ),
          SizedBox(height: 20),
        ],
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
        initial =
            nameParts[0][0].toUpperCase() + nameParts[1][0].toUpperCase();
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
}
