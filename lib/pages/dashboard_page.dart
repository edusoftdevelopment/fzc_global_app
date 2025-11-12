// Import statements for core Flutter functionality
import 'dart:async';
import 'dart:io';

// Import statements for Flutter UI components
import 'package:flutter/material.dart';
// Import statements for external packages
import 'package:flutter_datawedge/flutter_datawedge.dart';
import 'package:fluttertoast/fluttertoast.dart';
// Import statements for local app modules
import 'package:fzc_global_app/pages/barcode_scanner_page.dart';
import 'package:fzc_global_app/utils/constants.dart';
import 'package:fzc_global_app/utils/secure_storage.dart';

// Main Dashboard widget class
class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  // Service instances and dependencies
  final SecureStorage secureStorage = SecureStorage();
  late FlutterDataWedge fdw;

  // Stream subscription for barcode scanning
  late final StreamSubscription<ScanResult> scanResultSubscription;

  // Scanner initialization state
  bool? initScannerResult;
  String menuType = "Default";

  // Dashboard menu items configuration
  final List<Map<String, dynamic>> items = [
    {
      "title": "Scanner",
      "icon": Icons.barcode_reader,
      "routeUrl": "/chooseoptions",
    },
    {
      "title": "Dispatch In Box",
      "icon": Icons.inbox,
      "routeUrl": "/dispatch-in-box",
      "dispatchType": DispatchType.dispatchIn,
    },
    {
      "title": "Dispatch Out Box",
      "icon": Icons.outbox,
      "routeUrl": "/dispatch-out-box",
      "dispatchType": DispatchType.dispatchOut,
    },
  ];

  // Widget lifecycle methods
  @override
  void initState() {
    initLoad();
    super.initState();
  }

  @override
  void dispose() {
    scanResultSubscription.cancel();
    super.dispose();
  }

  // Initialization methods
  Future<void> initLoad() async {
    // // Clear secure storage data on dashboard load
    // await secureStorage.writeSecureData(SecureStorageKeys.customer, "");
    // await secureStorage.writeSecureData(SecureStorageKeys.supplier, "");
    // await secureStorage.writeSecureData(SecureStorageKeys.supplierOrderId, "");
    // await secureStorage.writeSecureData(SecureStorageKeys.dateFrom, "");
    // await secureStorage.writeSecureData(SecureStorageKeys.dateTo, "");

    // Initialize scanner after microtask
    Future.microtask(() async {
      initScannerResult = await initScanner();

      if (initScannerResult == true) {
        scanResultSubscription = fdw.onScanResult.listen(onScanResult);
      }

      Fluttertoast.showToast(
        msg: (initScannerResult == true)
            ? "Device Ready"
            : "Couldn't connect device",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.blueAccent,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    });
  }

  // Scanner configuration and initialization
  Future<bool> initScanner() async {
    if (Platform.isAndroid) {
      fdw = FlutterDataWedge();
      await fdw.initialize();
      await fdw.createDefaultProfile(profileName: "FZC Global App");
      return true;
    } else {
      return false;
    }
  }

  // Barcode scan result handler
  void onScanResult(ScanResult event) {
    String barcode = event.data;

    Fluttertoast.showToast(
      msg: "Scanned Barcode: $barcode",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.blueAccent,
      textColor: Colors.white,
      fontSize: 16.0,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => BarcodeScannerPage(
                barcode: barcode,
                dispatchType: menuType == "Default"
                    ? DispatchType.normal
                    : menuType == "Dispatch In"
                        ? DispatchType.dispatchIn
                        : DispatchType.dispatchOut,
              )),
    );
  }

  // Navigation and interaction handlers
  void onScanThroughBarCodeClick(String routeUrl) async {
    try {
      String selectedDevice = await secureStorage
              .readSecureData(SecureStorageKeys.selectedDevice) ??
          "";

      if (selectedDevice == "zebra_scanner") {
        fdw.scannerControl(true);
      } else if (selectedDevice == "mobile") {
        if (mounted) {
          Navigator.of(context).pushNamed(routeUrl);
        }
      } else {
        if (mounted) {
          Navigator.of(context).pushNamed(routeUrl);
        }
      }
    } catch (e) {
      // Show error toast for navigation failures
      Fluttertoast.showToast(
        msg: "$e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: const Color.fromARGB(255, 238, 4, 16),
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  // UI widget builders
  Widget cardTile(String title, IconData icon, String routeUrl) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          if (routeUrl == "/dispatch-in-box" ||
              routeUrl == "/dispatch-out-box") {
            if (routeUrl == "/dispatch-in-box") {
              // Sirf in-box ke liye
              menuType = "Dispatch In";
              setState(() {});
              onScanThroughBarCodeClick(routeUrl);
            } else if (routeUrl == "/dispatch-out-box") {
              // Sirf out-box ke liye
              menuType = "Dispatch Out";
              setState(() {});
              onScanThroughBarCodeClick(routeUrl);
            }
          } else {
            Navigator.pushNamed(context, routeUrl);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Constants.secondaryColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Constants.whiteColor,
                size: 50,
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style:
                    const TextStyle(color: Constants.whiteColor, fontSize: 18),
              ),
            ],
          )),
        ),
      ),
    );
  }

  // Main build method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.bgColor,
        title: const Text("Dashboard"),
      ),
      body: Container(
          padding: const EdgeInsets.all(10),
          child: GridView.builder(
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                mainAxisExtent: 150),
            itemBuilder: (BuildContext context, int index) {
              return cardTile(items[index]["title"], items[index]["icon"],
                  items[index]["routeUrl"]);
            },
          )),
    );
  }
}
