import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_pager_flutter/core/constants/app_routes.dart';
import 'package:mobile_pager_flutter/core/presentation/widget/buttons/primary_button.dart';
import 'package:mobile_pager_flutter/core/presentation/widget/inputfileds/text_inputfiled.dart';
import 'package:mobile_pager_flutter/core/theme/app_color.dart';
import 'package:mobile_pager_flutter/features/add_pager_page/presentation/add_pager_page.dart';
import 'package:mobile_pager_flutter/features/authentication/presentation/page/authentication_page.dart';
import 'package:mobile_pager_flutter/features/detail_history/presentation/detail_history_page.dart';
import 'package:mobile_pager_flutter/features/pager_history/presentation/pager_history_page.dart';
import 'package:mobile_pager_flutter/features/pager_qr_view/presentation/qr_view_page.dart';
import 'package:mobile_pager_flutter/main_navigation.dart';

void main() {
  runApp(const MyApp());
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
                const DetailHistoryPage(),
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            PrimaryButton(
              text: 'Primary Button',
              onPressed: () {
                // Handle button press
              },
            ),
            TextInputField(label: 'Enter Text'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
