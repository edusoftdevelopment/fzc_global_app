import "package:fzc_global_app/components/bottom_navigaton_bar.dart";
import "package:fzc_global_app/pages/barcode_scanner_page.dart";

import "package:fzc_global_app/pages/box_allotment_with_itemcode_page.dart";
import "package:fzc_global_app/pages/choose_scan_option_page.dart";
import "package:fzc_global_app/pages/itemcode_scanner_page.dart";

import "package:fzc_global_app/pages/login_page.dart";
import "package:fzc_global_app/pages/zebra_touch_computer_scanner_page.dart";
import "package:fzc_global_app/providers/common_data_provider.dart";
import "package:fzc_global_app/screens/splash_screen.dart";
import "package:fzc_global_app/utils/constants.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => CommonDataProvider()..fetchData(),
    child: const MyApp(),
  ));
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
          datePickerTheme:
              const DatePickerThemeData(backgroundColor: Colors.white),
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
        "/dispatch-in-box": (context) =>
            const BarcodeScannerPage(dispatchType: DispatchType.dispatchIn,),
        "/dispatch-out-box": (context) =>
            const BarcodeScannerPage(dispatchType: DispatchType.dispatchOut),
        "/zebratouchcomputerscanner": (context) => const ChooseScanOptionPage(),
        "/itemcodescanner": (context) => const ItemcodeScannerPage(),
        "/itemcodeboxallotment": (context) =>
            const BoxAllotmentWithItemcodePage(),
        "/chooseoptions": (context) => const ZebraTouchComputerScannerPage(),
      },
    );
  }
}
