import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pager_flutter/core/constants/app_routes.dart';
import 'package:mobile_pager_flutter/core/presentation/widget/buttons/primary_button.dart';
import 'package:mobile_pager_flutter/core/theme/app_color.dart';
import 'package:mobile_pager_flutter/core/theme/app_padding.dart';
import 'package:mobile_pager_flutter/features/authentication/presentation/providers/auth_providers.dart';
import 'package:mobile_pager_flutter/features/pager/presentation/providers/pager_providers.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

class QRViewPage extends ConsumerWidget {
  const QRViewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildHeader(ref),
        body: const Center(child: Text('Please login as merchant')),
      );
    }

    final temporaryPagersAsync = ref.watch(
      temporaryPagersStreamProvider(user.uid),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildHeader(ref),
      body: SafeArea(
        child: temporaryPagersAsync.when(
          data: (pagers) {
            return _buildContent(context, ref, pagers);
          },
          loading: () {
            return const Center(child: CircularProgressIndicator());
          },
          error: (error, stack) {
            return Center(
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
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, List pagers) {
    final authState = ref.watch(authNotifierProvider);
    final merchantId = authState.user?.uid ?? '';

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
                if (pagers.isEmpty)
                  Text(
                    'No temporary pagers yet. Create one below!',
                    style: GoogleFonts.inter(fontSize: 14, color: Colors.grey),
                  ),
              ],
            ),
          ),
          SizedBox(height: 20),

          // QR Code Display
          if (pagers.isNotEmpty)
            SizedBox(
              height: 520.h,
              child: PageView.builder(
                controller: PageController(viewportFraction: 0.95.w),
                itemCount: pagers.length,
                itemBuilder: (context, index) {
                  final pager = pagers[index];
                  final qrData = jsonEncode({
                    'pagerId': pager.pagerId,
                    'merchantId': merchantId,
                    'number': pager.number,
                  });

                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Container(
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
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        pager.label ?? 'Pager ${pager.displayId}',
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Temporary QR',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Detail Button
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.qrViewDetail,
                                        arguments: pager,
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColor.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.info_outline,
                                        color: AppColor.primary,
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PrettyQrView.data(
                            data: qrData,
                            decoration: const PrettyQrDecoration(
                              quietZone: PrettyQrQuietZone.standart,
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: Text(
                              pager.displayId,
                              textAlign: TextAlign.end,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

          SizedBox(height: 36),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppPadding.p16),
            child: PrimaryButton(
              text: 'Buat QR Instant',
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.addPager);
              },
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildHeader(WidgetRef ref) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      title: Text(
        'QR Management',
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w800,
          color: AppColor.black,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            final authState = ref.read(authNotifierProvider);
            final user = authState.user;
            if (user != null) {
              ref.invalidate(temporaryPagersStreamProvider(user.uid));
            }
          },
          tooltip: 'Refresh QR List',
        ),
      ],
    );
  }
}
