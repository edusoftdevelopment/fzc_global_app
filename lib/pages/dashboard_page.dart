// Import statements for core Flutter functionality
import 'dart:async';

// Import statements for Flutter UI components
import 'package:flutter/material.dart';
// Import statements for local app modules
import 'package:fzc_global_app/pages/barcode_scanner_page.dart';
import 'package:fzc_global_app/pages/scanner_page.dart';
import 'package:fzc_global_app/utils/common_helpers.dart';
import 'package:fzc_global_app/utils/constants.dart';
import 'package:fzc_global_app/utils/secure_storage.dart';
import 'package:fzc_global_app/utils/toast_utils.dart';

// Main Dashboard widget class
class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final SecureStorage secureStorage = SecureStorage();
  String menuType = "Default";

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
    {
      "title": "Box Dispatched Status",
      "icon": Icons.local_shipping,
      "routeUrl": "/box-dispatched-status",
    },
  ];

  @override
  void initState() {
    initLoad();
    super.initState();
  }

  Future<void> initLoad() async {
    await secureStorage.writeSecureData(SecureStorageKeys.customer, "");
    await secureStorage.writeSecureData(SecureStorageKeys.supplier, "");
    await secureStorage.writeSecureData(SecureStorageKeys.supplierOrderId, "");
    await secureStorage.writeSecureData(SecureStorageKeys.dateFrom, "");
    await secureStorage.writeSecureData(SecureStorageKeys.dateTo, "");
  }

  void onScanThroughBarCodeClick(String routeUrl, DispatchType type) async {
    try {
      String selectedDevice = await secureStorage
              .readSecureData(SecureStorageKeys.selectedDevice) ??
          "";

      if (selectedDevice == "zebra_scanner") {
        if (mounted) {
          CommonHelpers.navigateTo(context, ScannerPage(dispatchType: type));
        }
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
      ToastUtils.showErrorToast(message: "$e");
    }
  }

  void onCardTap(String routeUrl) {
    if (routeUrl == "/dispatch-in-box" || routeUrl == "/dispatch-out-box") {
      if (routeUrl == "/dispatch-in-box") {
        onScanThroughBarCodeClick(routeUrl, DispatchType.dispatchIn);
      } else if (routeUrl == "/dispatch-out-box") {
        onScanThroughBarCodeClick(routeUrl, DispatchType.dispatchOut);
      }
    } else {
      Navigator.pushNamed(context, routeUrl);
    }
  }

  Widget cardTile(String title, IconData icon, String routeUrl) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          onCardTap(routeUrl);
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
