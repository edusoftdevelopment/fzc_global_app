import "dart:io";

import "package:fzc_global_app/components/bottom_navigaton_bar.dart";
import "package:fzc_global_app/pages/barcode_scanner_page.dart";
import "package:fzc_global_app/pages/box_allotment_page.dart";
import "package:fzc_global_app/pages/box_allotment_with_itemcode_page.dart";
import "package:fzc_global_app/pages/choose_scan_option_page.dart";
import "package:fzc_global_app/pages/itemcode_scanner_page.dart";

import "package:fzc_global_app/pages/login_page.dart";
import "package:fzc_global_app/pages/zebra_touch_computer_scanner_page.dart";
import "package:fzc_global_app/screens/splash_screen.dart";
import "package:fzc_global_app/utils/constants.dart";
import "package:flutter/material.dart";

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "FZC Global App",
      debugShowCheckedModeBanner: false,
      initialRoute: "/",
      theme: ThemeData(
          bottomSheetTheme: const BottomSheetThemeData(
            backgroundColor: Constants.bgColor,
          ),
          scaffoldBackgroundColor: Constants.bgColor,
          textTheme: const TextTheme(
              bodyMedium: TextStyle(color: Constants.whiteColor)),
          appBarTheme: const AppBarTheme(
              backgroundColor: Constants.secondaryColor,
              titleTextStyle: TextStyle(
                  color: Constants.whiteColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
              centerTitle: true,
              iconTheme: IconThemeData(color: Constants.whiteColor))),
      routes: {
        "/": (context) => const CustomSplashScreen(),
        "/dashboard": (context) => const CustomBottomNavigationBar(),
        "/auth/login": (context) => const LoginPage(),
        "/barcodescanner": (context) => const BarcodeScannerPage(),
        "/boxallotment": (context) => const BoxAllotmentPage(),
        "/chooseoptions": (context) => const ChooseScanOptionPage(),
        "/itemcodescanner": (context) => const ItemcodeScannerPage(),
        "/itemcodeboxallotment": (context) =>
            const BoxAllotmentWithItemcodePage(),
        "/zebratouchcomputerscanner": (context) =>
            const ZebraTouchComputerScannerPage(),
      },
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
