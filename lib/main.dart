import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_pager_flutter/core/constants/app_routes.dart';
import 'package:mobile_pager_flutter/core/services/fcm_service.dart';
import 'package:mobile_pager_flutter/core/theme/app_color.dart';
import 'package:mobile_pager_flutter/features/about/presentation/about_page.dart';
import 'package:mobile_pager_flutter/features/active_pagers/presentation/active_pagers_page.dart';
import 'package:mobile_pager_flutter/features/add_pager_page/presentation/add_pager_page.dart';
import 'package:mobile_pager_flutter/features/authentication/presentation/page/authentication_page.dart';
import 'package:mobile_pager_flutter/features/detail_history/presentation/detail_history_page.dart';
import 'package:mobile_pager_flutter/features/merchant/presentation/pages/merchant_settings_page.dart';
import 'package:mobile_pager_flutter/features/notifications/presentation/pages/notification_history_page.dart';
import 'package:mobile_pager_flutter/features/pager_history/presentation/pages/customer_detail_page.dart';
import 'package:mobile_pager_flutter/features/pager_qr_view/presentation/qr_view_detail_page.dart';
import 'package:mobile_pager_flutter/features/pager_qr_view/presentation/qr_view_page.dart';
import 'package:mobile_pager_flutter/features/profile/presentation/profile_page.dart';
import 'package:mobile_pager_flutter/firebase_options.dart';
import 'package:mobile_pager_flutter/main_navigation.dart';

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Handling background message: ${message.messageId}');
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Set up FCM background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize FCM service
  await FCMService().initialize();

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
            AppRoutes.merchantSettings: (context) => const MerchantSettingsPage(),
            AppRoutes.notifications: (context) => const NotificationHistoryPage(),
            AppRoutes.about: (context) => const AboutPage(),
          },
          onGenerateRoute: (settings) {
            // Handle customer detail page with arguments
            if (settings.name == AppRoutes.customerDetail) {
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (context) => CustomerDetailPage(
                  merchantId: args['merchantId'] as String,
                  customerId: args['customerId'] as String,
                  customerName: args['customerName'] as String,
                ),
              );
            }
            return null;
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
