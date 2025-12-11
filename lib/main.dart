import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_pager_flutter/core/constants/app_routes.dart';
import 'package:mobile_pager_flutter/core/theme/app_color.dart';
import 'package:mobile_pager_flutter/features/active_pagers/presentation/active_pagers_page.dart';
import 'package:mobile_pager_flutter/features/add_pager_page/presentation/add_pager_page.dart';
import 'package:mobile_pager_flutter/features/authentication/presentation/page/authentication_page.dart';
import 'package:mobile_pager_flutter/features/detail_history/presentation/detail_history_page.dart';
import 'package:mobile_pager_flutter/features/pager_qr_view/presentation/qr_view_detail_page.dart';
import 'package:mobile_pager_flutter/features/pager_qr_view/presentation/qr_view_page.dart';
import 'package:mobile_pager_flutter/features/profile/presentation/profile_page.dart';
import 'package:mobile_pager_flutter/firebase_options.dart';
import 'package:mobile_pager_flutter/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(412, 915),
      minTextAdapt: true,

      builder: (context, child) {
        return MaterialApp(
          title: 'Mobile Pager',
          debugShowCheckedModeBanner: false,
          initialRoute: AppRoutes.authentication,
          routes: {
            AppRoutes.home: (context) => const MainNavigation(),
            AppRoutes.qrView: (context) => const QRViewPage(),
            AppRoutes.addPager: (context) => const AddPagerPage(),
            AppRoutes.authentication: (context) => const AuthenticationPage(),
            AppRoutes.detailPagerHistory: (context) =>
                const DetailHistoryPage(pagerId: "a"),
            AppRoutes.qrViewDetail: (context) => const QrDetailPage(),
            AppRoutes.profile: (context) => const ProfilePage(),
            AppRoutes.activePagers: (context) => const ActivePagersPage(),
          },
          theme: ThemeData(
            useMaterial3: true,
            primaryColor: AppColor.primary,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColor.primary,
              primary: AppColor.primary,
            ),
            scaffoldBackgroundColor: AppColor.background,
          ),
        );
      },
    );
  }
}
