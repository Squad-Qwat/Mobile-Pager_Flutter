import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pager_flutter/core/presentation/widget/buttons/primary_button.dart';
import 'package:mobile_pager_flutter/core/theme/app_color.dart';
import 'package:mobile_pager_flutter/core/theme/app_padding.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

class QRViewPage extends StatefulWidget {
  const QRViewPage({super.key});

  @override
  State<QRViewPage> createState() => _QRViewPageState();
}

class _QRViewPageState extends State<QRViewPage> {
  final List<Map<String, dynamic>> activeQRData = [
    {
      'id': 'QR-001',
      'name': 'Counter 1',
      'createdTime': '10:30, 31 Oct 2025',
      'activeQueues': 5,
      'totalScans': 23,
      'status': 'Aktif',
    },
    {
      'id': 'QR-002',
      'name': 'Counter 2',
      'createdTime': '09:15, 31 Oct 2025',
      'activeQueues': 3,
      'totalScans': 15,
      'status': 'Aktif',
    },
    {
      'id': 'QR-003',
      'name': 'Counter VIP',
      'createdTime': '08:00, 31 Oct 2025',
      'activeQueues': 2,
      'totalScans': 8,
      'status': 'Aktif',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildHeader(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppPadding.p16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [],
                ),
              ),
              SizedBox(height: 20),

              // Statistics Cards - Horizontal Scroll with Snap
              SizedBox(
                height: 520.h,
                child: PageView(
                  controller: PageController(viewportFraction: 0.95.w),
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 8, right: 8),
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
                              child: Text(
                                'QR Dinamis',
                                textAlign: TextAlign.start,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                            PrettyQrView.data(
                              data: 'lorem ipsum dolor sit amet',
                              decoration: const PrettyQrDecoration(
                                quietZone: PrettyQrQuietZone.standart,
                              ),
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: Text(
                                'QR Codes',
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
                    ),
                    Padding(
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
                              child: Text(
                                'QR Statis',
                                textAlign: TextAlign.start,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                            PrettyQrView.data(
                              data: 'lorem ipsum dolor sit amet',
                              decoration: const PrettyQrDecoration(
                                quietZone: PrettyQrQuietZone.standart,
                              ),
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: Text(
                                'Antrian',
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
                    ),
                  ],
                ),
              ),

              SizedBox(height: 36),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppPadding.p16),
                child: PrimaryButton(
                  text: 'Buat QR Instant',
                  onPressed: () {
                    // Handle button press
                  },
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildHeader() {
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
    );
  }
}
