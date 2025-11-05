import 'dart:io'; // untuk stdout.write
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:mobile_pager_flutter/core/constants/app_routes.dart';
import 'package:mobile_pager_flutter/core/theme/app_color.dart';
import 'package:mobile_pager_flutter/core/theme/app_padding.dart';
import 'package:flutter/foundation.dart'; // untuk kDebugMode dan debugPrint()


class HomePage extends StatefulWidget 
{
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> 
{
  final List<Map<String, dynamic>> storeStatisticData = [
    {'number': 60, 'number2': null, 'statisticCount': '23'},
    {'number': 15, 'number2': 20, 'statisticCount': '40'},
  ];

  final List<Map<String, dynamic>> recentActivitiesData = [
    {
      'id': 'EC-230201DDA',
      'time': '07:00, 19 Oct 2023',
      'pagerNum': 'PG-2228',
      'orderType': 'Take Away',
      'tableNum': 09,
      'name': 'Fauzan',
      'remainingTime': '00:40',
    },
    {
      'id': 'EC-230201DDB',
      'time': '07:30, 19 Oct 2023',
      'pagerNum': 'PG-2229',
      'orderType': 'Dine In',
      'tableNum': 10,
      'name': 'Fauzan',
      'remainingTime': '02:00',
    }
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
            children: <Widget>[
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppPadding.p16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Welcome,',
                      style: GoogleFonts.inter(
                        fontSize: 36.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Fauzan!',
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
                  children: <Widget>[
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
                        children: <Widget>[
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
                              '10',
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
                        children: <Widget>[
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
                              '10',
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
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Aktivitas Terkini',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        RichText(text: TextSpan(
                          text: "Lihat semua",
                          style: GoogleFonts.inter(
                            color: AppColor.primary, 
                            fontWeight: FontWeight.w700,
                          ),
                          recognizer: TapGestureRecognizer()..onTap = () => Navigator.pushNamed(
                            context, 
                            AppRoutes.orderList
                          )
                        ))
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: AppPadding.p16),
                itemCount: recentActivitiesData.length,
                itemBuilder: (context, index) {
                  final activity = recentActivitiesData[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.symmetric(vertical: AppPadding.p12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              activity['id'] ?? 'idError',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              activity['time'] ?? 'timeError',
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
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Nomor Pager',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  activity['pagerNum'] ?? '-',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Jenis pesanan',
                                  style: GoogleFonts.inter(
                                    fontSize: 14, 
                                    color: Colors.grey.shade600,
                                  )
                                ),
                                SizedBox(height: 4),
                                Text(
                                  activity['orderType'] ?? 'None',
                                  style: GoogleFonts.inter(
                                    fontSize: 16, 
                                    fontWeight: FontWeight.w700,
                                  ),
                                )
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Nomor meja',
                                  style: GoogleFonts.inter(
                                    fontSize: 14, 
                                    color: Colors.grey.shade600
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${activity['tableNum'] ?? -1}', // Error was here, forgot to format to string first
                                  style: GoogleFonts.inter(
                                    fontSize: 16, 
                                    fontWeight: FontWeight.w700
                                  ),
                                )
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Nama',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  activity['name'] ?? 'Guest',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Divider(
                          color: Colors.grey.shade300, 
                          height: 1
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: <Widget>[
                            Icon(
                              Iconsax.clock,
                              size: 18,
                              color: AppColor.primary,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Sisa waktu: ',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            Text(
                              activity['remainingTime'],
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColor.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
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
      actionsPadding: EdgeInsets.symmetric(horizontal: 16),
      title: Text(
        'Cammo',
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w800,
          color: AppColor.primary,
        ),
      ),
      actions: <Widget>[
        IconButton(
          onPressed: () => (kDebugMode) ? debugPrint('Hello World') : stdout.write('Hello World'),
          icon: Icon(Icons.add),
        ),
        IconButton(
          onPressed: () => (kDebugMode) ? debugPrint('Hello World') : stdout.write('Hello World'),
          icon: Icon(Icons.notifications),
        ),
        GestureDetector(
          onTap: () => Navigator.pushNamed(
            context, 
            AppRoutes.profile
          ),
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