import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pager_flutter/core/constants/app_routes.dart';
import 'package:mobile_pager_flutter/core/presentation/widget/buttons/primary_button.dart';
import 'package:mobile_pager_flutter/core/theme/app_color.dart';
import 'package:mobile_pager_flutter/core/theme/app_padding.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

class QRViewPage extends StatefulWidget 
{
  const QRViewPage({super.key});

  @override
  State<QRViewPage> createState() => _QRViewPageState();
}

class _QRViewPageState extends State<QRViewPage> 
{
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
  Widget build(BuildContext context) 
  {
    return Scaffold(
      appBar: _buildHeader(),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppPadding.p16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Card to create a new QR Pager
              Card(
                elevation: 2,
                shadowColor: AppColor.shadow,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: AppColor.surface,
                child: Padding(
                  padding: EdgeInsets.all(AppPadding.p16),
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Buat QR Pager Baru',
                        style: GoogleFonts.dmSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColor.textPrimary,
                        ),
                      ),
                      SizedBox(height: AppPadding.p16),
                      Padding(padding: EdgeInsets.symmetric(horizontal: AppPadding.p16),
                        child: PrimaryButton(
                          text: 'Buat QR Instant',
                          onPressed: () => Navigator.pushNamed(context, AppRoutes.addPager)
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: AppPadding.p24),
        
              // Card to show a list of active QRs and link to the Detail Page
              Card(
                elevation: 2,
                shadowColor: AppColor.shadow,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),),
                color: AppColor.surface,
                child: Padding(
                  padding: EdgeInsets.all(AppPadding.p16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        'Daftar QR Aktif',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColor.textPrimary,
                        ),
                      ),
                      SizedBox(height: AppPadding.p16),
                      Padding(
                        padding: EdgeInsets.only(
                          left: 8, 
                          right: 8
                        ),
                        child: Container(
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
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
                                decoration: const PrettyQrDecoration(quietZone: PrettyQrQuietZone.standart),
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
                      SizedBox(height: AppPadding.p16),
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
                            children: <Widget>[
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
                                decoration: const PrettyQrDecoration(quietZone: PrettyQrQuietZone.standart),
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
                      SizedBox(height: AppPadding.p16),
                      // Example item linking to the detail page
                      PrimaryButton(
                        text: "Lihat Contoh QR (Counter 1)",
                        icon: Iconsax.scan_barcode_copy,
                        backgroundColor: AppColor.primaryLight,
                        // Navigates to the QrDetailPage
                        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.qrViewDetail),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildHeader() 
  {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        'QR Pager Management',
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w800,
          color: AppColor.black,
        ),
      ),
    );
  }
}