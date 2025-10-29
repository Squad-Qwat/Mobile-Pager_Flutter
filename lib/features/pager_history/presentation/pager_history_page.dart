import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pager_flutter/core/theme/app_color.dart';
import 'package:mobile_pager_flutter/core/theme/app_padding.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  final List<Map<String, String>> historyData = const [
    {'date': '28 Oktober 2025', 'seat': 'A-12', 'status': 'Selesai'},
    {'date': '27 Oktober 2025', 'seat': 'B-05', 'status': 'Dibatalkan'},
    {'date': '26 Oktober 2025', 'seat': 'C-21', 'status': 'Selesai'},
    {'date': '25 Oktober 2025', 'seat': 'D-15', 'status': 'Selesai'},
    {'date': '24 Oktober 2025', 'seat': 'E-03', 'status': 'Selesai'},
    {'date': '23 Oktober 2025', 'seat': 'F-10', 'status': 'Selesai'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. APP BAR
      appBar: AppBar(
        title: Text(
          'Detail History',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: AppColor.textPrimary,
          ),
        ),
        backgroundColor: AppColor.white,
        elevation: 0,
      ),

      // 2. BODY - Daftar Riwayat
      body: Container(
        color: AppColor.white,
        child: ListView.separated(
          padding: EdgeInsets.symmetric(
            horizontal: AppPadding.p16,
            vertical: AppPadding.p8,
          ),
          itemCount: historyData.length,
          separatorBuilder: (context, index) =>
              Divider(color: AppColor.grey300, height: AppPadding.p16),
          itemBuilder: (context, index) {
            final item = historyData[index];

            return InkWell(
              onTap: () {
                print('Tap pada item riwayat: ${item['seat']}');
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: AppPadding.p8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // FOTO
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColor.grey200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.receipt_long,
                          color: AppColor.grey600,
                          size: 30,
                        ),
                      ),
                    ),

                    SizedBox(width: AppPadding.p16),

                    // DATA TANGGAL DAN NOMOR KURSI
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tanggal
                          Text(
                            item['date']!,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColor.grey600,
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Nomor Kursi
                          Text(
                            'Kursi: ${item['seat']!}',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColor.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppColor.grey400,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
