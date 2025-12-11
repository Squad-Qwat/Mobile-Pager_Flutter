import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pager_flutter/core/presentation/widget/pager_ticket_card.dart';
import 'package:mobile_pager_flutter/core/theme/app_color.dart';
import 'package:mobile_pager_flutter/core/theme/app_padding.dart';
import 'package:mobile_pager_flutter/features/authentication/presentation/providers/auth_providers.dart';
import 'package:mobile_pager_flutter/features/pager/presentation/providers/pager_providers.dart';

class ActivePagersPage extends ConsumerWidget {
  const ActivePagersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: _buildHeader(context),
        body: const Center(child: Text('Please login')),
      );
    }

    // Get appropriate stream based on user role
    final activePagersAsync = user.isMerchant
        ? ref.watch(activePagersStreamProvider(user.uid))
        : ref.watch(customerPagersStreamProvider(user.uid));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildHeader(context),
      body: activePagersAsync.when(
        data: (pagers) {
          if (pagers.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              // Refresh is handled automatically by stream
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: ListView.builder(
              padding: EdgeInsets.symmetric(
                horizontal: AppPadding.p16,
                vertical: 16.h,
              ),
              itemCount: pagers.length,
              itemBuilder: (context, index) {
                return PagerTicketCard(
                  pager: pagers[index],
                  isMerchant: user.isMerchant,
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                'Error loading pagers',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
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
    );
  }

  PreferredSizeWidget _buildHeader(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Text(
        'Active Pagers',
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w800,
          color: AppColor.black,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 100.w, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text(
            'Tidak Ada Pager Aktif',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Belum ada pager yang aktif saat ini',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
